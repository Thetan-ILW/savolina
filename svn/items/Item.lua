local class = require("class")
local table_util = require("table_util")

---@class svn.Item
---@operator call: svn.Item
---@field id integer? ID in the database
---@field template_id integer Index in the ItemRegistry, should never be changed manually
---@field owner_id integer? User ID
---@field amount number
---@field type svn.ItemType
local Item = class()

---@enum svn.ItemType
Item.Type = {
	Resource = 1,
	Wearable = 2,
	Consumable = 3
}

---@param params { [string]: any }?
function Item:new(params)
	params = params or {}

	for key, value in pairs(params) do
		self[key] = value ---@diagnostic disable-line
	end

	self.amount = self.amount or 1
end

function Item:copy()
	local t = {}
	table_util.copy(self, t)
	setmetatable(t, getmetatable(self))
	return t
end

---@return boolean
function Item:canStack()
	return self.type ~= Item.Type.Wearable
end

return Item
