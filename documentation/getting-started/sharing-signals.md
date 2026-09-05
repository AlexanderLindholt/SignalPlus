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
  tags:
    visible: true
  actions:
    visible: true
---

# Sharing signals

There are two main ways to share signals between scripts:

{% tabs %}
{% tab title="Modules" %}
You can return a table of signals in a ModuleScript, which multiple other scripts can then require and thereby access the same signals and communicate.

Scripts can also add or remove signals from the ModuleScript at any time.

\
Example:

{% code title="Signals (ModuleScript)" %}
```lua
local Signal = require(script.SignalPlus)

return {
	CoolSignal = Signal()
	SuperCoolSignal = Signal() :: Signal.Signal<number> -- Custom type :D
}
```
{% endcode %}

{% code title="Some script" %}
```lua
local signals = require(script.Signals)
local coolSignal = signals.CoolSignal

task.wait(5)

coolSignal:Fire()
```
{% endcode %}

{% code title="Some other script" %}
```lua
local signals = require(script.Signals)
local coolSignal = signals.CoolSignal

coolSignal:Connect(function()
	print("CoolSignal fired!")
end)
```
{% endcode %}
{% endtab %}

{% tab title="Built-in shared table" %}
You can store signals in the built-in Roblox shared table, which multiple scripts can access and thereby communicate.

Any script can add or remove signals from the shared table at any time.

\
Example:

{% code title="Some script" %}
```lua
local Signal = require(script.SignalPlus)
shared.CoolSignal = Signal()

task.wait(5)

shared.CoolSignal:Fire()
```
{% endcode %}

{% code title="Some other script" %}
```lua
-- Just make sure that this part runs after
-- the signal has been added to the shared table.
shared.CoolSignal:Connect(function()
	print("CoolSignal fired!")
end)
```
{% endcode %}
{% endtab %}
{% endtabs %}
