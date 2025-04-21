local class = require("class")

local Users = require("svn.access.Users")
local Items = require("svn.items.Items")

---@class svn.Domain
---@operator call: svn.Domain
local Domain = class()

---@param repos svn.Repos
function Domain:new(repos)
	self.users = Users(repos.users_repo)
	self.items = Items(repos.items_repo)
end

return Domain
