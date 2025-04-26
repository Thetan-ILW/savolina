local Event = require("svnplug.events.Event")

---@class svnplug.GiftEvent : svnplug.Event
---@operator call: svnplug.GiftEvent
---@field items svn.Item[]
local GiftEvent = Event + {}

return GiftEvent
