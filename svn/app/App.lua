local class = require("class")
local socket_url = require("socket.url")

local TemplateRegistry = require("svn.TemplateRegistry")
local ItemDefinitions = require("svn.ItemDefinitions")
local Database = require("svn.storage.Database")
local Repos = require("svn.app.Repos")
local Domain = require("svn.app.Domain")
local Resources = require("svn.app.Resources")
local Router = require("web.framework.router.Router")
local Sessions = require("web.framework.Sessions")

---@class svn.App
---@operator call: svn.App
local App = class()

function App:new()
	local template_registry = TemplateRegistry()
	ItemDefinitions(template_registry)

	self.db = Database()
	self.db:load()

	self.sessions = Sessions("savolina", "security...? what is this?")
	self.repos = Repos(self.db.models, template_registry)
	self.domain = Domain(self.repos, template_registry)
	self.resources = Resources(self.domain, self.sessions)
	self.router = Router()
	self.router:route(self.resources:getList())
end

---@class svn.RequestContext
---@field [any] any
---@field ip string
---@field time integer
---@field path_params {[string]: string}
---@field parsed_uri string
---@field session_user svn.User?

---@param req web.IRequest
---@param ctx svn.RequestContext
function App:handleSession(req, ctx)
	---@type {id: integer}?
	local t = self.sessions:get(req.headers)

	if not t or not t.id then
		return
	end

	local session = self.domain.users:getSession(t.id)
	if not session or not session.active then
		return
	end

	ctx.session = session
	ctx.session_user = self.domain.users:getUser(session.user_id)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ip string
function App:handle(req, res, ip)
	local parsed_uri = socket_url.parse(req.uri)

	local resource, path_params, methods = self.router:getResource(parsed_uri.path)

	if not resource or not path_params or not methods then
		res.status = 404
		res:set_chunked_encoding()
		res:send("not found")
		res:send("")
		return
	end

	local method = req.method
	local _method = methods[method]

	if method ~= method:upper() or not resource[_method] then
		res.status = 403
		res:set_chunked_encoding()
		res:send("invalid method")
		res:send("")
		return
	end

	---@type svn.RequestContext
	local ctx = {
		parsed_uri = parsed_uri,
		path_params = path_params,
		ip = ip,
		time = os.time(),
	}

	self:handleSession(req, ctx)

	local ok, err = xpcall(resource[_method], debug.traceback, resource, req, res, ctx)

	if not ok then
		local body = ("<pre>%s</pre>"):format(err)
		res.status = 500
		res:set_chunked_encoding()
		res:send(body)
		res:send("")
		return
	end

	res:send("")
end

return App
