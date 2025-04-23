local class = require("class")
local delay = require("delay")
local ThreadRemote = require("threadremote.ThreadRemote")

local SvnWebsocket = require("svnplug.online.SvnWebsocket")

local Subprotocol = require("web.ws.Subprotocol")

local WebsocketPeer = require("icc.WebsocketPeer")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")

local ClientRemote = require("svn.app.remotes.ClientRemote")

---@class svnplug.SvnClient
---@operator call: svnplug.SvnClient
---@field session_cookie string?
local SvnClient = class()

SvnClient.threaded = true
SvnClient.reconnect_interval = 30

---@param game sphere.GameController
function SvnClient:new(game)
	self.game = game

	self.protocol = Subprotocol()
	self.remote_handler = RemoteHandler(ClientRemote(self.game))

	function self.remote_handler:transform(th, peer, obj, ...)
		local _obj = setmetatable({}, {__index = obj})
		_obj.remote = Remote(th, peer) --[[@as sea.ServerRemote]]
		---@cast _obj +sea.IClientRemote
		return _obj, ...
	end

	local server_peer = WebsocketPeer({send = function() end})
	self.server_peer = server_peer

	local task_handler = TaskHandler(self.remote_handler)
	self.task_handler = task_handler

	local remote = Remote(self.task_handler, self.server_peer)
	---@cast remote -icc.Remote, +svn.ServerRemote
	self.remote = remote

	function self.protocol:text(payload, fin)
		if not fin then return end

		local msg = server_peer:decode(payload)
		if not msg then return end

		if msg.ret then
			task_handler:handleReturn(msg)
		else
			task_handler:handleCall(server_peer, msg)
		end
	end

	self.reconnecting = false
	self.connected = false
end

function SvnClient:load(url)
	self.url = url

	if not self.threaded then
		self.sphws = SvnWebsocket()
		self.sphws.protocol = self.protocol
		self.sphws_ret = self.sphws
	else
		local thread_remote = ThreadRemote("svnwebsocket", self.protocol)
		self.thread_remote = thread_remote
		thread_remote:start(function(protocol)
			local SvnWebsocket = require("svnplug.online.SvnWebsocket")
			local sphws = SvnWebsocket()
			sphws.protocol = -protocol --[[@as web.Subprotocol]]
			return sphws
		end)
		local sphws = -thread_remote.remote
		local sphws_ret = thread_remote.remote
		---@cast sphws -icc.Remote, +svnplug.SvnWebsocket
		---@cast sphws_ret -icc.Remote, +svnplug.SvnWebsocket
		self.sphws = sphws
		self.sphws_ret = sphws_ret
	end

	self.reconnect_thread = coroutine.create(function()
		while true do
			local state = self.sphws_ret:getState()
			if state ~= "open" then
				local ok, err = self.sphws_ret:connect(url, {
					cookie = self.session_cookie
				})
				if not ok then
					self.reconnecting = true
					self.connected = false
					delay.sleep(self.reconnect_interval)
				else
					self.connected = true
					self.server_peer.ws = self.sphws.ws
				end
			end
			delay.sleep(1)
		end
	end)
	assert(coroutine.resume(self.reconnect_thread))

	self.ping_thread = coroutine.create(function()
		while true do
			local state = self.sphws_ret:getState()
			if state == "open" then
				self.sphws_ret.ws:send("ping")
			end
			delay.sleep(10)
		end
	end)
	assert(coroutine.resume(self.ping_thread))
end

function SvnClient:update()
	if self.thread_remote then
		self.thread_remote:update()
	end
	if self.sphws then
		self.sphws:update()
	end
end

return SvnClient
