local class = require("class")

local User = require("svn.access.User")
local Headers = require("web.http.Headers")

---@class svn.AuthServerRemote : svn.IServerRemote
---@operator call: svn.AuthServerRemote
local AuthServerRemote = class()

---@param users svn.Users
---@param sessions web.Sessions
function AuthServerRemote:new(users, sessions)
	self.users = users
	self.sessions = sessions
end

---@param email string
---@param password string
---@return string? cookie
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

	local h = Headers()
	self.sessions:set(h, { id = su.session.id })

	self.ctx.user = su.user
	return h:get("Set-Cookie")
end

---@param name string
---@param email string
---@param password string
---@return string? cookie
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

	local su, err = self.users:register(user, self.ctx.ip, os.time())

	if not su then
		---@cast err string
		return nil, err
	end

	local h = Headers()
	self.sessions:set(h, { id = su.session.id })

	self.ctx.user = su.user
	return h:get("Set-Cookie")
end

---@return boolean
function AuthServerRemote:isSessionActive()
	return self.ctx.user ~= nil
end

return AuthServerRemote
