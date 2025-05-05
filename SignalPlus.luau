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

v3.3.1

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
		-- Disconnects the connection.
		-- To reconnect, make a new connection.
		function(connection: Connection) end
	),
}
export type Signal<Parameters...> = {
	Connect: typeof(
		-- Connects the given function.
		function(signal: Signal<Parameters...>, callback: (Parameters...) -> ()): Connection end
	),
	Once: typeof(
		-- Connects the given function, but disconnects after first fire.
		function(signal: Signal<Parameters...>, callback: (Parameters...) -> ()): Connection end
	),
	Wait: typeof(
		-- Yields the current thread until the next fire.
		function(signal: Signal<Parameters...>): Parameters... end
	),
	
	Fire: typeof(
		-- Fires all callbacks and resumes all waiting threads.
		function(signal: Signal<Parameters...>, ...: Parameters...) end
	),
	
	DisconnectAll: typeof(
		-- Disconnects all connections.
		function(signal: Signal<Parameters...>) end
	),
	Destroy: typeof(
		-- Disconnects all connections, and makes the signal unusable.
		function(signal: Signal<Parameters...>) end
	),
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

-- Connection functions.
local Connection = {}
Connection.__index = Connection

Connection.Disconnect = function(connection)
	-- Verify connection.
	if not connection.Connected then return end
	
	-- Remove connection.
	connection.Connected = false
	
	local previous = connection.Previous
	local next = connection.Next
	previous.Next = next
	if next then
		next.Previous = previous
	end
end

-- Signal functions.
local Signal = {}
Signal.__index = Signal

Signal.Connect = function(signal, callback)
	-- Cache linked list next.
	local next = signal.Next
	
	-- Create connection.
	local connection = {
		Previous = signal,
		Next = next,
		Callback = callback,
		
		Connected = true
	}
	
	-- Add connection.
	if next then
		next.Previous = connection
	end
	signal.Next = connection
	
	-- Return connection.
	return setmetatable(connection, Connection)
end
Signal.Once = function(signal, callback)
	-- Cache linked list next.
	local next = signal.Next
	
	-- Create connection.
	local connection = nil
	connection = {
		Previous = signal,
		Next = next,
		Callback = function(...)
			-- Remove connection.
			connection.Connected = false
			
			local previous = connection.Previous
			local next = connection.Next
			previous.Next = next
			if next then
				next.Previous = previous
			end
			
			-- Fire callback.
			callback(...)
		end,
		
		Connected = true
	}
	
	-- Add connection.
	if next then
		next.Previous = connection
	end
	signal.Next = connection
	
	-- Return connection.
	return setmetatable(connection, Connection)
end
Signal.Wait = function(signal)
	-- Save this thread to resume later.
	local thread = coroutine.running()
	
	-- Cache linked list next.
	local next = signal.Next
	
	-- Create connection.
	local connection = nil
	connection = {
		Previous = signal,
		Next = next,
		Callback = function(...)
			-- Remove connection.
			connection.Connected = false
			
			local previous = connection.Previous
			local next = connection.Next
			previous.Next = next
			if next then
				next.Previous = previous
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
	if next then
		next.Previous = connection
	end
	signal.Next = connection
	
	-- Yield until the next fire, and return the arguments on resume.
	return coroutine.yield()
end

Signal.Fire = function(signal, ...)
	local connection = signal.Next
	while connection do
		-- Find or create a thread, and run the callback in it.
		local length = #threads
		if length == 0 then
			local thread = coroutine.create(reusableThread)
			coroutine.resume(thread)
			task.spawn(thread, connection.Callback, thread, ...)
		else
			local thread = threads[length]
			threads[length] = nil -- Remove from free threads list.
			task.spawn(thread, connection.Callback, thread, ...)
		end
		
		-- Traverse.
		connection = connection.Next
	end
end

Signal.DisconnectAll = function(signal)
	signal.Next = nil
end
Signal.Destroy = function(signal)
	signal.Next = nil -- Disconnect all connections.
	setmetatable(signal, nil) -- Unlink methods.
end

-- Return signal creation function.
return function()
	return setmetatable({}, Signal)
end :: CreateSignal
