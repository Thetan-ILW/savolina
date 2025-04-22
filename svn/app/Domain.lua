local class = require("class")

local Users = require("svn.access.Users")
local Items = require("svn.items.Items")
local Scores = require("svn.scores.Scores")

---@class svn.Domain
---@operator call: svn.Domain
local Domain = class()

---@param repos svn.Repos
---@param template_registry svn.TemplateRegistry
function Domain:new(repos, template_registry)
	self.users = Users(repos.users_repo)
	self.items = Items(repos.items_repo)
	self.scores = Scores(repos.users_repo, repos.items_repo, template_registry)
end

return Domain
