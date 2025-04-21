local class = require("class")

local UsersRepo = require("svn.access.repos.UsersRepo")
local ItemsRepo = require("svn.items.repos.ItemsRepo")

---@class svn.Repos
---@operator call: svn.Repos
local Repos = class()

---@param models rdb.Models
---@param template_registry svn.TemplateRegistry
function Repos:new(models, template_registry)
	self.users_repo = UsersRepo(models)
	self.items_repo = ItemsRepo(models, template_registry)
end

return Repos
