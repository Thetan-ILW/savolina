local class = require("class")

---@alias svnplug.OnlineState "connecting" | "reconnecting" | "auth_required" | "authentication" | "ready"

---@class svnplug.OnlineModel
---@operator call: svnplug.OnlineModel
---@field state svnplug.OnlineState
---@field session_user svn.User?
local OnlineModel = class()

---@enum svnplug.online.EventType
OnlineModel.EventTypes = {
	StateUpdated = 1,
	Message = 2,
	InventoryUpdate = 3,
	Gift = 4,
}

---@class svnplug.online.Event
---@field type svnplug.online.EventType

---@class svnplug.online.MessageEvent : svnplug.online.Event
---@field message string
---@field type "error" | "info"

---@class svnplug.online.InventoryUpdateEvent : svnplug.online.Event
---@field changed_items svn.Item[]

---@class svnplug.online.GiftEvent : svnplug.online.Event
---@field items svn.Item[]

---@param svn_client svnplug.SvnClient
function OnlineModel:new(svn_client)
	self.svn_client = svn_client
	self.connected = false
	self.session_cookie = ""
	self.state = "connecting"
	self.stateListeners = {} ---@type {[table]: fun(self: table, state: svnplug.OnlineState)}
	self.messageListeners = {} ---@type {[table]: fun(self: table, text: string, type: svnplug.OnlineMessageType)}
end

function OnlineModel:listenForStateChanges(instance, f)
	self.stateListeners[instance] = f
	f(instance, self.state)
end

function OnlineModel:listenForMessages(instance, f)
	self.messageListeners[instance] = f
end

function OnlineModel:stopListeningForStateChanges(instance)
	self.stateListeners[instance] = nil
end

function OnlineModel:stopListeningForMessages(instance)
	self.messageListeners[instance] = nil
end

function OnlineModel:onlineStateUpdated()
	local new_state ---@type svnplug.OnlineState

	self.connected = self.svn_client.connected

	if not self.svn_client.connected and not self.svn_client.reconnecting then
		new_state = "connecting"
	elseif not self.svn_client.connected then
		new_state = "reconnecting"
	elseif self.svn_client.connected and not self.session_user then
		if not self.session_cookie or self.session_cookie == "" then
			new_state = "auth_required"
		else
			new_state = "authentication"
			self:getSession()
		end
	elseif self.svn_client.connected and self.session_user then
		new_state = "ready"
	end

	self.state = new_state

	for instance, f in pairs(self.stateListeners) do
		f(instance, self.state)
	end
end

function OnlineModel:update()
	if self.connected ~= self.svn_client.connected then
		self:onlineStateUpdated()
	end
end

---@alias svnplug.OnlineMessageType "error" | "server_info" | "info" | "good_news"

---@param text string
---@param type svnplug.OnlineMessageType
function OnlineModel:message(text, type)
	for instance, f in pairs(self.messageListeners) do
		f(instance, text, type)
	end
end

function OnlineModel:getSession()
	coroutine.wrap(function()
		if not self.svn_client.connected then
			return
		end
		local ok, err = self.svn_client.remote.auth:getSession(self.session_cookie)
	end)()
end

---@param email string
---@param password string
function OnlineModel:login(email, password)
	coroutine.wrap(function()
		local user = self.svn_client.remote.auth:login(email, password)

		if user then
			self.session_user = user
		else
			self:message("Could not log in. Make sure you entered the correct email/password", "error")
		end
		self:onlineStateUpdated()
	end)()
end

---@param name string
---@param email string
---@param password string
function OnlineModel:register(name, email, password)
	coroutine.wrap(function()
		local user, err = self.svn_client.remote.auth:register(name, email, password)

		if user then
			self.session_user = user
		else
			---@cast err string
			self:message(err, "error")
		end
		self:onlineStateUpdated()
	end)()
end

---@param score svn.Score
function OnlineModel:submitScore(score)
	coroutine.wrap(function()
		local reward = self.svn_client.remote.submission:submitScore(score)

		if reward then
			for _, item in ipairs(reward.changed_items) do
				if item.template_id == 5 then
					self:message(("Total coins: %i"):format(item.amount), "good_news")
				end
			end
		end
	end)()
end

return OnlineModel
