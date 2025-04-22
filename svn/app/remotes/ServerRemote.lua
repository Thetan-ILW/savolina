local class = require("class")

local AuthServerRemote = require("svn.access.remotes.AuthServerRemote")
local SubmissionServerRemote = require("svn.scores.remotes.SubmissionServerRemote")

---@class svn.WebsocketContext
---@field user svn.User
---@field ip string

---@class svn.IServerRemote
---@field ctx svn.WebsocketContext
---@field remote svn.ClientRemote

---@class svn.ServerRemote
---@operator call: svn.ServerRemote
local ServerRemote = class()

---@param domain svn.Domain
function ServerRemote:new(domain)
	self.auth = AuthServerRemote(domain.users)
	self.submission = SubmissionServerRemote(domain.scores)
end

---@param msg string
---@return string
function ServerRemote:ping(msg)
	return msg .. "world" .. self.user.id
end

return ServerRemote
