local class = require("class")

local AuthResource = require("svn.access.http.AuthResource")
local ItemResource = require("svn.items.http.ItemResource")

---@class svn.Resources
---@operator call: svn.Resources
local Resources = class()

---@param domain svn.Domain
---@param sessions web.Sessions
function Resources:new(domain, sessions)
	self.auth = AuthResource(domain.users, sessions)
	self.items = ItemResource(domain.items)
end

function Resources:getList()
	return {
		self.auth,
		self.items
	}
end

return Resources
