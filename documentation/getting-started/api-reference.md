---
icon: list
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

# API Reference

## Signal:

| Name          | Type   | Description                                                                                                                               |
| ------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Connect       | Method | <p>Connects a function.<br>​<br><strong>Returns:</strong> <em>Connection</em></p>                                                         |
| Once          | Method | <p>Connects a function, then auto-disconnects after the first call.<br>​<br><strong>Returns:</strong> <em>Connection</em></p>             |
| Wait          | Method | Yields the calling thread until the next fire.                                                                                            |
| Fire          | Method | Runs all connected functions, and resumes all waiting threads.                                                                            |
| DisconnectAll | Method | <p>Erases all connections.<br></p><p><strong>Much faster than calling <code>Disconnect</code> on each.</strong></p>                       |
| Destroy       | Method | <p>Erases all connections and methods, making the signal unusable.</p><p><br>Remove references to the signal to delete it completely.</p> |

## Connection:

| Name       | Type     | Description                                  |
| ---------- | -------- | -------------------------------------------- |
| Disconnect | Method   | Erases the connection.                       |
| Connected  | Property | A boolean representing the connection state. |
