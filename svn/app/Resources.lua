local class = require("class")

local ItemResource = require("svn.items.http.ItemResource")

local ServerRemote = require("svn.app.remotes.ServerRemote")
local WebsocketResource = require("svn.shared.http.WebsocketResource")

---@class svn.Resources
---@operator call: svn.Resources
local Resources = class()

---@param domain svn.Domain
---@param sessions web.Sessions
function Resources:new(domain, sessions)

	self.items = ItemResource(domain.items)

	local server_remote_handler = ServerRemote(domain, sessions)
	self.websocket = WebsocketResource(server_remote_handler)
end

function Resources:getList()
	return {
		self.items,
		self.websocket
	}
end

return Resources
