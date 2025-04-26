local Page = require("svnplug.views.osu.Page")
local InventoryLoadedEvent = require("svnplug.events.InventoryLoadedEvent")
local InventoryUpdateEvent = require("svnplug.events.InventoryUpdateEvent")

local Label = require("ui.Label")

---@class svnplug.osu.MainPage : svnplug.osu.Page
---@operator call: svnplug.osu.MainPage
local MainPage = Page + {}

function MainPage:load()
	Page.load(self)

	self.scene = self:findComponent("scene") ---@cast osu.ui.Scene
	self.fonts = self.scene.fontManager
	self.inventory_model = self.scene.game.svn_inventory_model ---@type svnplug.InventoryModel
	self.inventory_model.events:listen(self, self.handleEvent)

	local coins_text = ""

	if self.inventory_model.state == "not_loaded" then
		self.inventory_model:loadInventoryFromServer()
	elseif self.inventory_model.state == "loaded" then
		coins_text = ("Coins: %i"):format(self.inventory_model:getAmountOfCoins())
	end

	self:addChild("coins", Label({
		boxWidth = self.width,
		boxHeight = self.height,
		alignX = "center",
		alignY = "center",
		font = self.fonts:loadFont("Regular", 34),
		text = coins_text
	}))
end

---@param event svnplug.Event
function MainPage:handleEvent(event)
	if InventoryUpdateEvent * event or InventoryLoadedEvent * event then
		local coins = self:getChild("coins") ---@cast coins ui.Label
		coins:replaceText(("Coins: %i"):format(self.inventory_model:getAmountOfCoins()))
	end
end

return MainPage
