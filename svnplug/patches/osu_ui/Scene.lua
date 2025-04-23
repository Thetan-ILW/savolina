local Scene = require("osu_ui.Scene")
local SavolinaLoadout = require("svnplug.views.osu.SavolinaLoadout")

local MessageEvent = require("svnplug.online.Event.Message")

local base_load = Scene.load
function Scene:load()
	base_load(self)
	self.screens.savolinaLoadout = SavolinaLoadout({ z = 0.05 })
	self.game.svn_online_model:listenForEvents(self, self.handleSvnEvent)
end

---@param event svnplug.online.Event
function Scene:handleSvnEvent(event) ---@diagnostic disable-line
	if MessageEvent * event then
		---@cast event svnplug.online.MessageEvent
		local color = "error"

		if event.type == "info" then
			color = "orange"
		end

		self.popupContainer:add(event.message, color)
	end
end
