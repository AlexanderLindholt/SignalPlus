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
  tags:
    visible: true
  actions:
    visible: true
---

# Introduction

The module returns a function, which you can use to create signals:

```lua
local Signal = require(script.SignalPlus)

local coolSignal = Signal() -- Creates a new signal.
```

You can then use methods to control and fire connections on the signal — just like BindableEvents and other signal alternatives.

See the full API on the next page.
