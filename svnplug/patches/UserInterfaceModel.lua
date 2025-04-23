local UserInterfaceModel = require("sphere.models.UserInterfaceModel")
local SvnClient = require("svnplug.online.SvnClient")
local OnlineModel = require("svnplug.online.OnlineModel")
local socket_url = require("socket.url")

local base_load = UserInterfaceModel.load
function UserInterfaceModel:load(...)
	base_load(self, ...) ---@diagnostic disable-line

	local game = self.game ---@diagnostic disable-line
	game.svn_client = SvnClient(game) ---@diagnostic disable-line
	game.svn_client.session_cookie = love.filesystem.read("userdata/savolina")
	game.svn_client:load("http://127.0.0.1:8081/ws")
	game.svn_online_model = OnlineModel(game.svn_client) ---@diagnostic disable-line
	game.gameplayController.svn_online_model = game.svn_online_model ---@diagnostic disable-line
end
