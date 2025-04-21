local Item = require("svn.items.Item")

---@class svn.Wearable : svn.Item
---@operator call: svn.Wearable
---@field slot svn.WearableSlot
---@field upgrade_count number
---@field marvelous_points number
---@field combo_multiplier number
---@field fever_fill_rate number
---@field fever_multiplier number
---@field fever_time number
---@field red_points number
---@field blue_points number
---@field white_points number
local Wearable = Item + {}

Wearable.type = Item.Type.Wearable

---@enum svn.WearableSlot
Wearable.Slot = {
	Waifu = 1,
	Head = 2,
	Hands = 3,
	Charm = 4,
}

---@param params { [string]: any }
function Wearable:new(params)
	Item.new(self, params)

	self.upgrade_count = self.upgrade_count or 0
	self.marvelous_points = self.marvelous_points or 0
	self.combo_multiplier = self.combo_multiplier or 0
	self.fever_fill_rate = self.fever_fill_rate or 0
	self.fever_multiplier = self.fever_multiplier or 0
	self.fever_time = self.fever_time or 0
	self.red_points = self.red_points or 0
	self.blue_points = self.blue_points or 0
	self.white_points = self.white_points or 0
end

return Wearable
