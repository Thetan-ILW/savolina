local Event = require("svnplug.online.Event")

---@class svnplug.online.InventoryUpdateEvent : svnplug.online.Event
---@operator call: svnplug.online.InventoryUpdateEvent
---@field changed_items svn.Item[]
local InventoryUpdateEvent = Event + {}

return InventoryUpdateEvent
