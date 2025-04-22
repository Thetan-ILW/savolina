local class = require("class")

local User = require("svn.access.User")

---@class svn.AuthServerRemote : svn.IServerRemote
---@operator call: svn.AuthServerRemote
local AuthServerRemote = class()

---@param users svn.Users
function AuthServerRemote:new(users)
	self.users = users
end

---@param email string
---@param password string
---@return svn.User?
---@return string? error
function AuthServerRemote:login(email, password)
	if self.ctx.user then
		return nil, "Already logged in"
	end

	local user = User()
	user.email = email
	user.password = password

	local success, errs = user:validateLogin()

	if not success then
		---@cast errs string[]
		return nil, table.concat(errs, ", ")
	end

	local su, err = self.users:login(user, self.ctx.ip, self.ctx.time)

	if not su then
		return nil, err
	end

	return su.user
end

---@param name string
---@param email string
---@param password string
---@return svn.User?
---@return string? error
function AuthServerRemote:register(name, email, password)
	if self.ctx.user then
		return nil, "Already logged in"
	end

	local user = User()
	user.name = name
	user.email = email
	user.password = password

	local success, errs = user:validateRegister()

	if not success then
		---@cast errs string[]
		return nil, table.concat(errs, ", ")
	end

	local su, err = self.users:register(user, self.ctx.ip, self.ctx.time)

	if not su then
		---@cast err string
		return nil, err
	end

	return su.user
end

---@param cookie string
---@return svn.User?
function AuthServerRemote:getSession(cookie)
	return nil
end

return AuthServerRemote
