local class = require("class")
local LsTcpSocket = require("web.luasocket.LsTcpSocket")
local Websocket = require("web.ws.Websocket")
local WebsocketClient = require("web.ws.WebsocketClient")
local Subprotocol = require("web.ws.Subprotocol")

---@class svnplug.SvnWebsocket
---@operator call: svnplug.SvnWebsocket
local SvnWebsocket = class()

function SvnWebsocket:new()
	self.protocol = Subprotocol()
end

---@param url string
---@param header_params {[string]: string}?
---@return true?
---@return string?
function SvnWebsocket:connect(url, header_params)
	self.soc = LsTcpSocket(4)

	local ws_client = WebsocketClient(self.soc)
	local re, err = ws_client:connect(url)
	if not re then
		return nil, err
	end

	if header_params then
		for key, value in pairs(header_params) do
			re.req.headers:add(key, value)
		end
	end

	self.ws = Websocket(self.soc, re.req, re.res, "client")
	self.ws.protocol = self.protocol
	return self.ws:handshake()
end

---@return web.WebsocketState
function SvnWebsocket:getState()
	local ws = self.ws
	return ws and ws:getState() or "connecting"
end

function SvnWebsocket:update()
	if not self.soc or not self.ws then
		return
	end
	while self.soc:selectreceive(0) do
		if not self.ws:step() then
			break
		end
	end
end

return SvnWebsocket
