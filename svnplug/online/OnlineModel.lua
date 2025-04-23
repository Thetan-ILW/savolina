local class = require("class")

local StateChangedEvent = require("svnplug.online.Event.StateChangedEvent")
local MessageEvent = require("svnplug.online.Event.Message")
local InventoryUpdateEvent = require("svnplug.online.Event.InventoryUpdateEvent")

---@alias svnplug.online.State "connecting" | "reconnecting" | "auth_required" | "authentication" | "ready"

---@class svnplug.OnlineModel
---@operator call: svnplug.OnlineModel
---@field state svnplug.online.State
local OnlineModel = class()

---@param svn_client svnplug.SvnClient
function OnlineModel:new(svn_client)
	self.svn_client = svn_client
	self.connected = false
	self.session_active = false
	self.state = "connecting"
	self.event_listeners = {} ---@type {[table]: fun(self: table, event: svnplug.online.Event)}
end

---@param instance table
---@param f fun(self: table, event: svnplug.online.Event)
function OnlineModel:listenForEvents(instance, f)
	self.event_listeners[instance] = f
end

---@param instance table
function OnlineModel:stopListeningForEvents(instance)
	self.event_listeners[instance] = nil
end

---@param event svnplug.online.Event
function OnlineModel:sendEvent(event)
	for instance, f in pairs(self.event_listeners) do
		f(instance, event)
	end
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

	local event = StateChangedEvent()
	event.state = self.state
	self:sendEvent(event)
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
	local cookie, err = self.svn_client.remote.auth:login(email, password)

	if cookie then
		self:saveCookie(cookie)
		self.session_active = true
	else
		---@cast err string
		local msg = MessageEvent()
		msg.message = err
		msg.type = "error"
		self:sendEvent(msg)
	end
	self:onlineStateUpdated()
end

---@param name string
---@param email string
---@param password string
function OnlineModel:register(name, email, password)
	local cookie, err = self.svn_client.remote.auth:register(name, email, password)

	if cookie then
		self:saveCookie(cookie)
		self.session_active = true
	else
		---@cast err string
		local msg = MessageEvent()
		msg.message = err
		msg.type = "error"
		self:sendEvent(msg)
	end
	self:onlineStateUpdated()
end

---@param score svn.Score
function OnlineModel:submitScore(score)
	local reward = self.svn_client.remote.submission:submitScore(score)

	if not reward then
		return
	end

	local e = InventoryUpdateEvent()
	e.changed_items = reward.changed_items
	self:sendEvent(e)
end

return OnlineModel
