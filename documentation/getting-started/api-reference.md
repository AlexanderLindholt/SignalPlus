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

| Name          | Type   | Description                                                                                                                 |
| ------------- | ------ | --------------------------------------------------------------------------------------------------------------------------- |
| Connect       | Method | <p>Connects the given function.<br>​<br><strong>Returns:</strong> <em>Connection</em></p>                                   |
| Once          | Method | <p>Connects the given function, but disconnects after first fire.<br>​<br><strong>Returns:</strong> <em>Connection</em></p> |
| Wait          | Method | Yields the calling thread until the next fire.                                                                              |
| Fire          | Method | Fires all callbacks and resumes all waiting threads.                                                                        |
| DisconnectAll | Method | Disconnects all connections.                                                                                                |
| Destroy       | Method | Disconnects all connections, and makes the signal unusable.                                                                 |

## Connection:

| Name       | Type     | Description                                                    |
| ---------- | -------- | -------------------------------------------------------------- |
| Disconnect | Method   | Disconnects the connection.                                    |
| Connected  | Property | A boolean representing the connection state of the connection. |
