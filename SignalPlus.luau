--!optimize 2

--[[

           +++                                                                                      
       ++++++++   ===                                                                               
    ++++++++++   ====                                                  ====                         
     ++++++                                                            ====                         
       +++++     ====     ====== =====  ==== =======      ========     ====        ====             
        +++++    ====    =============  =============    ===========   ====        ====             
         ++++    ====   ====     =====  =====    ====           ====   ====        ====             
         ++++    ====   ====     =====  =====    ====     ==========   ====    =============        
         ++++    ====   ====     =====  =====    ====   ======  ====   ====    =============        
       ++++++    ====   =====   ======  =====    ====  ====     ====   ====        ====    +++++++++
   ++++++++++    ====    =============  =====    ====   ============   ====   ++++ ==== ++++++++++++
  +++++++        ====            =====  ====     ====   + ====  ====   ==== ++++++++  ++++++++      
 +++++                  ==== +++ ==== +++++++++++++++++++++++++++++++++++++++++++++++++++++         
 ++++        +++++++++++ =========== +++++++++++++++++++++++++++++++++++++++      ++++++            
+++++++++++++++++++++++++++                                                         +               
 +++++++++++++++++++++++++                                                                          
      +++++                                                                                         

v3.5.0

An insanely fast, lightweight, fully typed and documented
open-source signal module for Roblox, with dynamic types.


GitHub:
https://github.com/AlexanderLindholt/SignalPlus

DevForum:
https://devforum.roblox.com/t/3552231


--------------------------------------------------------------------------------
MIT License

Copyright (c) 2025 Alexander Lindholt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--------------------------------------------------------------------------------

]]--

-- Types.
export type Connection = {
	Connected: boolean,
	Disconnect: typeof(
		-- Erases the connection.
		function(connection: Connection) end
	)
}
export type Signal<Parameters...> = {
	Connect: typeof(
		-- Connects a function.
		function(signal: Signal<Parameters...>, callback: (Parameters...) -> ()): Connection end
	),
	Once: typeof(
		-- Connects a function, then auto-disconnects after the first call.
		function(signal: Signal<Parameters...>, callback: (Parameters...) -> ()): Connection end
	),
	Wait: typeof(
		-- Yields the calling thread until the next fire.
		function(signal: Signal<Parameters...>): Parameters... end
	),
	
	Fire: typeof(
		-- Runs all connected functions, and resumes all waiting threads.
		function(signal: Signal<Parameters...>, ...: Parameters...) end
	),
	
	DisconnectAll: typeof(
		-- Erases all connections.<br>
		-- <em>Much faster than calling <code>Disconnect</code> on each.</em>
		function(signal: Signal<Parameters...>) end
	),
	Destroy: typeof(
		-- Erases all connections and methods, making the signal unusable.<br>
		-- Remove references to the signal to delete it completely.
		function(signal: Signal<Parameters...>) end
	)
}
type CreateSignal = typeof(
	-- Creates a new signal.
	function(): Signal end
)

-- Setup thread recycling.
local threads = {}
local function reusableThreadCall(callback, thread, ...)
	callback(...)
	table.insert(threads, thread)
end
local function reusableThread()
	while true do
		reusableThreadCall(coroutine.yield())
	end
end

-- Connection methods.
local Connection = {}
Connection.__index = Connection

Connection.Disconnect = function(connection)
	-- Verify connection.
	if not connection.Connected then return end
	
	-- Remove connection.
	connection.Connected = false
	
	local signal = connection.Signal
	local previous = connection.Previous
	local next = connection.Next
	if previous then
		previous.Next = next
	else
		signal.Tail = next
	end
	if next then
		next.Previous = previous
	else
		signal.Head = previous
	end
end

-- Signal methods.
local Signal = {}
Signal.__index = Signal

Signal.Connect = function(signal, callback)
	-- Cache linked list head.
	local head = signal.Head
	
	-- Create connection.
	local connection = {
		Signal = signal,
		
		Previous = head,
		Callback = callback,
		
		Connected = true
	}
	
	-- Add connection.
	if head then
		head.Next = connection
	else
		signal.Tail = connection
	end
	signal.Head = connection
	
	-- Return connection.
	return setmetatable(connection, Connection)
end
Signal.Once = function(signal, callback)
	-- Cache linked list head.
	local head = signal.Head
	
	-- Create connection.
	local connection = nil
	connection = {
		Signal = signal,
		
		Previous = head,
		Callback = function(...)
			-- Verify connection.
			if not connection.Connected then return end
			
			-- Remove connection.
			connection.Connected = false
			
			local previous = connection.Previous
			local next = connection.Next
			if previous then
				previous.Next = next
			else
				signal.Tail = next
			end
			if next then
				next.Previous = previous
			else
				signal.Head = previous
			end
			
			-- Fire callback.
			callback(...)
		end,
		
		Connected = true
	}
	
	-- Add connection.
	if head then
		head.Next = connection
	else
		signal.Tail = connection
	end
	signal.Head = connection
	
	-- Return connection.
	return setmetatable(connection, Connection)
end
Signal.Wait = function(signal)
	-- Save this thread to resume later.
	local thread = coroutine.running()
	
	-- Cache linked list head.
	local head = signal.Head
	
	-- Create connection.
	local connection = nil
	connection = {
		Signal = signal,
		
		Previous = head,
		Callback = function(...)
			-- Remove connection.
			connection.Connected = false
			
			local previous = connection.Previous
			local next = connection.Next
			if previous then
				previous.Next = next
			else
				signal.Tail = next
			end
			if next then
				next.Previous = previous
			else
				signal.Head = previous
			end
			
			-- Resume the thread.
			if coroutine.status(thread) == "suspended" then -- To avoid errors.
				local _, err = coroutine.resume(thread, ...)
				if err then error(err, 2) end
			end
		end,
		
		Connected = true
	}
	
	-- Add connection.
	if head then
		head.Next = connection
	else
		signal.Tail = connection
	end
	signal.Head = connection
	
	-- Yield until the next fire, and return the arguments on resume.
	return coroutine.yield()
end

Signal.Fire = function(signal, ...)
	local connection = signal.Tail -- Start from the tail (back) of the list.
	while connection do
		-- Find or create a thread, and run the callback in it.
		local length = #threads
		if length == 0 then
			local thread = coroutine.create(reusableThread)
			coroutine.resume(thread)
			task.defer(thread, connection.Callback, thread, ...)
		else
			local thread = threads[length]
			threads[length] = nil -- Remove from free threads list.
			task.defer(thread, connection.Callback, thread, ...)
		end
		
		-- Traverse.
		connection = connection.Next
	end
end

Signal.DisconnectAll = function(signal)
	-- Remove references, so that the connections will be garbage collected.
	signal.Tail = nil
	signal.Head = nil
end
Signal.Destroy = function(signal)
	-- Remove references, so that the connections will be garbage collected.
	signal.Tail = nil
	signal.Head = nil
	-- Unlink signal methods.
	setmetatable(signal, nil)
end

-- Signal creation function.
return function()
	return setmetatable({}, Signal) -- New, blank metatable with the methods attached.
end :: CreateSignal
