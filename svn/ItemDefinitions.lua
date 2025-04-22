local Item = require("svn.items.Item")
local Wearable = require("svn.items.Wearable")
local PowerElement = require("svn.PowerElement")

---@return svn.Item
local function Resource()
	return Item({ type = Item.Type.Resource })
end

---@return svn.Item
local function Consumable()
	return Item({ type = Item.Type.Consumable })
end

---@param tr svn.TemplateRegistry
return function (tr)
	tr:add("red_gem", Resource()) -- ID 1
	tr:add("blue_gem", Resource()) -- ID 2
	tr:add("white_gem", Resource()) -- ID 3
	tr:add("shit_item_gacha", Consumable()) -- ID 4
end
