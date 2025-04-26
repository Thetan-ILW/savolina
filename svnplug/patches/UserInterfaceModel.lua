local UserInterfaceModel = require("sphere.models.UserInterfaceModel")
local SvnClient = require("svnplug.online.SvnClient")
local OnlineModel = require("svnplug.models.OnlineModel")
local InventoryModel = require("svnplug.models.InventoryModel")
local TemplateRegistry = require("svn.TemplateRegistry")
local ItemDefinitions = require("svn.ItemDefinitions")

local base_load = UserInterfaceModel.load
function UserInterfaceModel:load(...)
	base_load(self, ...) ---@diagnostic disable-line

	---@diagnostic disable-next-line
	local game = self.game ---@type table
	game.svn_client = SvnClient(game)
	game.svn_client.session_cookie = love.filesystem.read("userdata/savolina")
	game.svn_client:load("http://127.0.0.1:8081/ws")

	game.template_registry = TemplateRegistry()
	ItemDefinitions(game.template_registry)

	game.svn_inventory_model = InventoryModel(game.template_registry, game.svn_client)
	game.svn_online_model = OnlineModel(game.svn_client)

	-- EWWWW
	game.gameplayController.svn_client = game.svn_client
	game.gameplayController.svn_inventory_model = game.svn_inventory_model
end
