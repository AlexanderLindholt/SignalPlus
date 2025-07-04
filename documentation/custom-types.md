---
icon: fill-drip
---

# Custom types

It's super easy to define custom types for your signals with Signal+.\
This means you can have autocompletion for the [parameters](https://create.roblox.com/docs/tutorials/fundamentals/coding-2/use-parameters-and-events) in your signals:

<div align="left"><figure><img src=".gitbook/assets/Custom type example.png" alt="Parameter autocompletion example"><figcaption></figcaption></figure></div>

You can provide your own parameters as shown in the screenshot above:

```lua
local mySignal = SignalPlus() :: SignalPlus.Signal<PARAMETERS_HERE>
```

All methods ( `Connect`, `Once`, `Wait` and `Fire`) will display your desired parameters.

