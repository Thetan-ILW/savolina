local Scene = require("osu_ui.Scene")
local Savolina = require("svnplug.views.osu.Savolina")

local MessageEvent = require("svnplug.events.MessageEvent")
local InventoryUpdateEvent = require("svnplug.events.InventoryUpdateEvent")

local base_load = Scene.load
function Scene:load()
	base_load(self)
	self.screens.savolina = Savolina({ z = 0.05 })
	self.game.svn_online_model.events:listen(self, self.handleSvnEvent)
	self.game.svn_inventory_model.events:listen(self, self.handleSvnEvent)
end

---@param event svnplug.Event
function Scene:handleSvnEvent(event) ---@diagnostic disable-line
	if MessageEvent * event then
		---@cast event svnplug.MessageEvent
		local color = "error"

		if event.type == "info" then
			color = "orange"
		end

		self.popupContainer:add(event.message, color)
	elseif InventoryUpdateEvent * event then
		---@cast event svnplug.InventoryUpdateEvent
		self.popupContainer:add("Score submitted", "green")
	end
end
