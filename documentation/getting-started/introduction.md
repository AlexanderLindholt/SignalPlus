# Introduction

When you require the module, it will return a function, which you can use to create signals.\
For example:

```lua
local SignalPlus = require(script.SignalPlus)

local signal = SignalPlus() -- Creates a new signal.
```



You can then use methods to control and fire connections on the signal — just like BindableEvents.

{% hint style="warning" %}
The order in which connections are fired is reliable (consistent), but backwards.
{% endhint %}
