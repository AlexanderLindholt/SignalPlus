---
icon: globe
layout:
  width: default
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
  metadata:
    visible: true
---

# Sharing signals

Should you be in doubt, here are the main ways to share signals between scripts:

<details>

<summary>Modules</summary>

You can return a table of signals in a ModuleScript, which multiple other scripts can then require and thereby access the same signals and communicate.

Scripts can also add or remove signals from the ModuleScript at any time.



Example:

```lua
-- "Signals" (ModuleScript)
local Signal = require(script.SignalPlus)

return {
	CoolSignal = Signal()
	SuperCoolSignal = Signal() :: Signal.Signal<number> -- Custom type :D
}
```

```lua
-- Some script
local signals = require(script.Signals)
local coolSignal = signals.CoolSignal

task.wait(5)

coolSignal:Fire()
```

```lua
-- Some other script
local signals = require(script.Signals)
local coolSignal = signals.CoolSignal

coolSignal:Connect(function()
	print("CoolSignal fired!")
end)
```

</details>

<details>

<summary>Built-in shared table</summary>

You can store signals in the built-in shared table, which multiple other scripts can then access and thereby access the same signals and communicate.

Scripts can also add or remove signals from the shared table at any time.



Example:

```lua
-- Some script
local Signal = require(script.SignalPlus)
shared.CoolSignal = Signal()

task.wait(5)

shared.CoolSignal:Fire()
```

```lua
-- Some other script

-- Just make sure that this part runs after
-- the signal has been added to the shared table.
shared.CoolSignal:Connect(function()
	print("CoolSignal fired!")
end)
```

</details>
