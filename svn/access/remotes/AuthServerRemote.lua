local class = require("class")

---@class svn.AuthServerRemote : svn.IServerRemote
---@operator call: svn.AuthServerRemote
local AuthServerRemote = class()

---@param users svn.Users
function AuthServerRemote:new(users)
	self.users = users
end

---@return string
function AuthServerRemote:getHello()
	return "hello from server!"
end

return AuthServerRemote
