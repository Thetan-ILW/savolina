local Event = require("svnplug.events.Event")

---@class svnplug.InventoryLoadedEvent : svnplug.Event
---@operator call: svnplug.InventoryLoadedEvent
local InventoryLoadedEvent = Event + {}

return InventoryLoadedEvent
