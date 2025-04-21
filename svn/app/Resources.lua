local class = require("class")

local AuthResource = require("svn.access.http.AuthResource")
local ItemResource = require("svn.items.http.ItemResource")

local ServerRemote = require("svn.app.remotes.ServerRemote")
local WebsocketResource = require("svn.shared.http.WebsocketResource")

---@class svn.Resources
---@operator call: svn.Resources
local Resources = class()

---@param domain svn.Domain
---@param sessions web.Sessions
function Resources:new(domain, sessions)

	self.auth = AuthResource(domain.users, sessions)
	self.items = ItemResource(domain.items)

	local server_remote_handler = ServerRemote(domain)
	self.websocket = WebsocketResource(server_remote_handler)
end

function Resources:getList()
	return {
		self.auth,
		self.items,
		self.websocket
	}
end

return Resources
