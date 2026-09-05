---
icon: gear-code
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

# Generic types

It’s super easy to define types for your signals with Signal+.\
This means you can have autocompletion for the [parameters](https://create.roblox.com/docs/tutorials/fundamentals/coding-2/use-parameters-and-events) in your signals:

<figure><img src="../.gitbook/assets/Custom type example.png" alt=""><figcaption></figcaption></figure>



You can provide your own parameters as shown in the screenshot above:

```lua
local mySignal = Signal() :: Signal.Signal<PARAMETERS_HERE>
```

{% hint style="success" %}
All methods (`Connect`, `Once`, `Wait`, and `Fire`) will display your desired parameters.
{% endhint %}
