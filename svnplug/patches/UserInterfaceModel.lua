local UserInterfaceModel = require("sphere.models.UserInterfaceModel")
local SvnClient = require("svnplug.online.SvnClient")

local base_load = UserInterfaceModel.load
function UserInterfaceModel:load(...)
	base_load(self, ...) ---@diagnostic disable-line

	local game = self.game ---@diagnostic disable-line
	game.svnClient = SvnClient(game) ---@diagnostic disable-line
	game.svnClient:load("http://127.0.0.1:8081/ws")
end
