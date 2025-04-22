local Scene = require("osu_ui.Scene")
local SavolinaLoadout = require("svnplug.views.osu.SavolinaLoadout")

local base_load = Scene.load
function Scene:load()
	base_load(self)
	self.screens.savolinaLoadout = SavolinaLoadout({ z = 0.05 })
	self.game.svn_online_model:listenForMessages(self, self.svnMessage)
end

---@param text string
function Scene:svnMessage(text) ---@diagnostic disable-line
	self.popupContainer:add(text, "error")
end
