local Event = require("svnplug.online.Event")

---@class svnplug.online.MessageEvent : svnplug.online.Event
---@operator call: svnplug.online.MessageEvent
---@field message string
---@field type "error" | "info"
local MessageEvent = Event + {}

return MessageEvent
