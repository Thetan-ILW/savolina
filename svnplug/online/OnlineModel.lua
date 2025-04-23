local class = require("class")

local StateChangedEvent = require("svnplug.online.Event.StateChangedEvent")
local MessageEvent = require("svnplug.online.Event.Message")
local InventoryUpdateEvent = require("svnplug.online.Event.InventoryUpdateEvent")

---@alias svnplug.online.State "connecting" | "reconnecting" | "auth_required" | "authentication" | "ready"

---@class svnplug.OnlineModel
---@operator call: svnplug.OnlineModel
---@field state svnplug.online.State
---@field session_user svn.User?
local OnlineModel = class()

---@param svn_client svnplug.SvnClient
function OnlineModel:new(svn_client)
	self.svn_client = svn_client
	self.connected = false
	self.session_cookie = ""
	self.state = "connecting"
	self.eventListeners = {} ---@type {[table]: fun(self: table, event: svnplug.online.Event)}
end

---@param instance table
---@param f fun(self: table, event: svnplug.online.Event)
function OnlineModel:listenForEvents(instance, f)
	self.eventListeners[instance] = f
end

---@param instance table
function OnlineModel:stopListeningForEvents(instance)
	self.eventListeners[instance] = nil
end

---@param event svnplug.online.Event
function OnlineModel:sendEvent(event)
	for instance, f in pairs(self.eventListeners) do
		f(instance, event)
	end
end

function OnlineModel:onlineStateUpdated()
	self.connected = self.svn_client.connected

	if not self.svn_client.connected and not self.svn_client.reconnecting then
		self.state = "connecting"
	elseif not self.svn_client.connected then
		self.state = "reconnecting"
	elseif self.svn_client.connected and not self.session_user then
		if not self.session_cookie or self.session_cookie == "" then
			self.state = "auth_required"
		else
			self.state = "authentication"
			self:getSession()
		end
	elseif self.svn_client.connected and self.session_user then
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

function OnlineModel:getSession()
	local ok, err = self.svn_client.remote.auth:getSession(self.session_cookie)
end

---@param email string
---@param password string
function OnlineModel:login(email, password)
	local user = self.svn_client.remote.auth:login(email, password)

	if user then
		self.session_user = user
	else
		local msg = MessageEvent()
		msg.message = "Could not log in. Make sure you entered the correct email/password"
		msg.type = "error"
		self:sendEvent(msg)
	end
	self:onlineStateUpdated()
end

---@param name string
---@param email string
---@param password string
function OnlineModel:register(name, email, password)
	local user, err = self.svn_client.remote.auth:register(name, email, password)

	if user then
		self.session_user = user
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
