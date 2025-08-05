---
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

# Introduction

When you require the module, it will return a function, which you can use to create signals.\
For example:

```lua
local Signal = require(path.to.SignalPlus)

local signal = Signal() -- Creates a new signal.
```

You can then use methods to control and fire connections on the signal — just like BindableEvents and other signal alternatives.
