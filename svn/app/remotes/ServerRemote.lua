local class = require("class")

local AuthServerRemote = require("svn.access.remotes.AuthServerRemote")

---@class svn.IServerRemote
---@field user svn.User
---@field remote svn.ClientRemote

---@class svn.ServerRemote
---@operator call: svn.ServerRemote
local ServerRemote = class()

---@param domain svn.Domain
function ServerRemote:new(domain)
	self.auth = AuthServerRemote(domain.users)
end

---@param msg string
---@return string
function ServerRemote:ping(msg)
	return msg .. "world" .. self.user.id
end

return ServerRemote
