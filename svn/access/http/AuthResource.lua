local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")
local json = require("web.json")

local User = require("svn.access.User")

---@class svn.AuthResource : web.IResource
---@operator call: svn.AuthResource
local AuthResource = IResource + {}

AuthResource.routes = {
	{ "/register", {
		POST = "register"
	}},
	{ "/login", {
		POST = "login"
	}}
}

---@param users svn.Users
---@param sessions web.Sessions
function AuthResource:new(users, sessions)
	self.users = users
	self.sessions = sessions
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx svn.RequestContext
function AuthResource:register(req, res, ctx)
	local payload, err = http_util.get_json(req)

	if not payload then
		res.status = 400
		return
	end

	local user = User()
	user.name = payload.name
	user.email = payload.email
	user.password = payload.password

	local success, errs = user:validateRegister()

	if not success then
		---@cast errs string[]
		res:send(table.concat(errs, ","))
		return
	end

	local su, err = self.users:register(user, ctx.ip, ctx.time)

	if not su then
		---@cast err string
		res:send(err)
		return
	end

	self.sessions:set(res.headers, { id = su.session.id })

	payload = json.encode(su.user)
	res.headers:set("Content-Type", "application/json")
	res:set_length(payload:len())
	res:send(payload)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx svn.RequestContext
function AuthResource:login(req, res, ctx)
	local payload, err = http_util.get_json(req)

	if not payload then
		res.status = 400
		return
	end

	local user = User()
	user.email = payload.email
	user.password = payload.password

	local success, errs = user:validateLogin()

	if not success then
		---@cast errs string[]
		res:send(table.concat(errs, ","))
		return
	end

	local su, err = self.users:login(user, ctx.ip, ctx.time)

	if not su then
		---@cast err string
		res:send(err)
		return
	end

	self.sessions:set(res.headers, { id = su.session.id })

	payload = json.encode(su.user)
	res.headers:set("Content-Type", "application/json")
	res:set_length(payload:len())
	res:send(payload)
end

return AuthResource
