local Event = require("svnplug.online.Event")

---@class svnplug.online.StateChangedEvent : svnplug.online.Event
---@operator call: svnplug.online.StateChangedEvent
---@field state svnplug.online.State
local StateChangedEvent = Event + {}

return StateChangedEvent
