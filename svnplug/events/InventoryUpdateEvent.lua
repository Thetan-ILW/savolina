local Event = require("svnplug.events.Event")

---@class svnplug.InventoryUpdateEvent : svnplug.Event
---@operator call: svnplug.InventoryUpdateEvent
---@field changed_items svn.InventoryEntry[]
local InventoryUpdateEvent = Event + {}

return InventoryUpdateEvent
