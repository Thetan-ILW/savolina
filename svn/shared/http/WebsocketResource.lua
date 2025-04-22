local WebsocketPeer = require("icc.WebsocketPeer")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")
local IResource = require("web.framework.IResource")
local Websocket = require("web.ws.Websocket")

---@class svn.WebsocketResource: web.IResource
---@operator call: svn.WebsocketResource
local WebsocketResource = IResource + {}

WebsocketResource.routes = {
	{"/ws", {
		GET = "server",
	}},
}

local function remote_handler_transform(_, th, peer, obj, ...)
	local _obj = setmetatable({}, {__index = obj})
	_obj.remote = Remote(th, peer) --[[@as svn.ClientRemote]]
	_obj.ctx = (...) --[[@as svn.WebsocketContext ]]
	---@cast _obj +svn.IServerRemote
	return _obj, select(2, ...)
end

---@param server_handler sea.ServerRemote
function WebsocketResource:new(server_handler)
	self.remote_handler = RemoteHandler(server_handler)
	self.remote_handler.transform = remote_handler_transform
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketResource:server(req, res, ctx)
	local ws = Websocket(req.soc, req, res, "server")
	local peer = WebsocketPeer(ws)
	local task_handler = TaskHandler(self.remote_handler)

	---@type svn.WebsocketContext
	--- Not really the best thing... Only used for login
	local ws_ctx = {
		user = ctx.session_user,
		ip = ctx.ip
	}

	---@param msg icc.Message
	local function handle_msg(msg)
		if msg.ret then
			task_handler:handleReturn(msg)
		else
			msg:insert(ws_ctx, 3)
			task_handler:handleCall(peer, msg)
		end
	end

	function ws.protocol:text(payload, fin)
		if not fin then return end

		local msg = peer:decode(payload)
		if not msg then return end

		local ok, err = xpcall(handle_msg, debug.traceback, msg)
		if not ok then
			print("icc error ", err)
		end
	end

	local ok, err = ws:handshake()
	if not ok then
		res:send(tostring(err))
		return
	end

	local ok, err = ws:loop()
	if not ok then
		print(err)
	end
end

return WebsocketResource
