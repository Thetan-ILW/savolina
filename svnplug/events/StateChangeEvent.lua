local Event = require("svnplug.events.Event")

---@class svnplug.StateChangeEvent : svnplug.Event
---@operator call: svnplug.StateChangeEvent
---@field state svnplug.OnlineState
local StateChangeEvent = Event + {}

return StateChangeEvent
