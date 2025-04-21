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

	tr:add("character_1", Wearable({ -- ID 4
		slot = Wearable.Slot.Waifu,
		power_element = PowerElement.Blue,
		fever_fill_rate = 10,
		combo_multiplier = 3,
		blue_power = 30,
	}))

	tr:add("character_2", Wearable({ -- ID 5
		slot = Wearable.Slot.Waifu,
		power_element = PowerElement.White,
		fever_time = 9,
		fever_multiplier = 5,
		white_points = 20,
	}))

	tr:add("hat", Wearable({ -- ID 6
		slot = Wearable.Slot.Head,
		combo_multiplier = 3,
		blue_points = 2,
		red_points = 1,
	}))

	tr:add("stick", Wearable({ -- ID 7
		slot = Wearable.Slot.Hands,
		red_points = 30,
	}))

	tr:add("star_charm", Wearable({ -- ID 8
		slot = Wearable.Slot.Charm,
		fever_fill_rate = 5,
		fever_time = 3,
		fever_multiplier = 10,
	}))

	tr:add("meat", Consumable()) -- ID 9
	tr:add("waifu_consumable", Consumable()) -- ID 10
end
