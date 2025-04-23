local Event = require("svnplug.online.Event")

---@class svnplug.online.GiftEvent : svnplug.online.Event
---@operator call: svnplug.online.GiftEvent
---@field items svn.Item[]
local GiftEvent = Event + {}

return GiftEvent
