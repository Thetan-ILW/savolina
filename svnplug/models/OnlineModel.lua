local class = require("class")

local EventDispatcher = require("svnplug.events.EventDispatcher")
local StateChangeEvent = require("svnplug.events.StateChangeEvent")
local MessageEvent = require("svnplug.events.MessageEvent")

---@alias svnplug.OnlineState "connecting" | "reconnecting" | "auth_required" | "authentication" | "ready"

---@class svnplug.OnlineModel
---@operator call: svnplug.OnlineModel
---@field state svnplug.OnlineState
local OnlineModel = class()

---@param svn_client svnplug.SvnClient
function OnlineModel:new(svn_client)
	self.svn_client = svn_client
	self.events = EventDispatcher()

	self.connected = false
	self.session_active = false
	self.state = "connecting"
end

function OnlineModel:onlineStateUpdated()
	self.connected = self.svn_client.connected

	local prev_state = self.state

	if not self.svn_client.connected and not self.svn_client.reconnecting then
		self.state = "connecting"
	elseif not self.svn_client.connected then
		self.session_active = false
		self.state = "reconnecting"
	elseif self.svn_client.connected and not self.session_active then
		self.state = "authentication"
		if prev_state == "connecting" or prev_state == "reconnecting" then
			coroutine.wrap(function()
				self:checkSession()
			end)()
		else
			self.state = "auth_required"
		end
	elseif self.svn_client.connected and self.session_active then
		self.state = "ready"
	end

	local event = StateChangeEvent()
	event.state = self.state
	self.events:dispatch(event)
end

function OnlineModel:update()
	if self.connected ~= self.svn_client.connected then
		self:onlineStateUpdated()
	end
end

function OnlineModel:checkSession()
	self.session_active = self.svn_client.remote.auth:isSessionActive()
	self:onlineStateUpdated()
end

---@param cookie string
function OnlineModel:saveCookie(cookie)
	love.filesystem.write("userdata/savolina", cookie)
end

---@param email string
---@param password string
function OnlineModel:login(email, password)
	if not self.connected then
		return
	end

	local cookie, err = self.svn_client.remote.auth:login(email, password)

	if cookie then
		self:saveCookie(cookie)
		self.session_active = true
		self:onlineStateUpdated()
	else
		---@cast err string
		local msg = MessageEvent()
		msg.message = err
		msg.type = "error"
		self.events:dispatch(msg)
	end

end

---@param name string
---@param email string
---@param password string
function OnlineModel:register(name, email, password)
	if not self.connected then
		return
	end

	local cookie, err = self.svn_client.remote.auth:register(name, email, password)

	if cookie then
		self:saveCookie(cookie)
		self.session_active = true
		self:onlineStateUpdated()
	else
		---@cast err string
		local msg = MessageEvent()
		msg.message = err
		msg.type = "error"
		self.events:dispatch(msg)
	end
end

return OnlineModel
