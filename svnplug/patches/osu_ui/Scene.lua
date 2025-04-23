local Scene = require("osu_ui.Scene")
local SavolinaLoadout = require("svnplug.views.osu.SavolinaLoadout")

local base_load = Scene.load
function Scene:load()
	base_load(self)
	self.screens.savolinaLoadout = SavolinaLoadout({ z = 0.05 })
	self.game.svn_online_model:listenForMessages(self, self.svnMessage)
end

---@param text string
---@param message_type svnplug.OnlineMessageType
function Scene:svnMessage(text, message_type) ---@diagnostic disable-line
	local color = "error"

	if message_type == "server_info" then
		color = "orange"
	elseif message_type == "info" then
		color = "purple"
	elseif message_type == "good_news" then
		color = "green"
	end

	self.popupContainer:add(text, color)
end
