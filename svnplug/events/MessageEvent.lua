local Event = require("svnplug.events.Event")

---@class svnplug.MessageEvent : svnplug.Event
---@operator call: svnplug.MessageEvent
---@field message string
---@field type "error" | "info"
local MessageEvent = Event + {}

return MessageEvent
