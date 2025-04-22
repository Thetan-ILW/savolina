local class = require("class")

---@alias svnplug.OnlineState "connecting" | "reconnecting" | "auth_required" | "authentication" | "ready"

---@class svnplug.OnlineModel
---@operator call: svnplug.OnlineModel
---@field state svnplug.OnlineState
---@field session_user svn.User?
local OnlineModel = class()

---@param svn_client svnplug.SvnClient
function OnlineModel:new(svn_client)
	self.svn_client = svn_client
	self.connected = false
	self.session_cookie = ""
	self.state = "connecting"
	self.stateListeners = {} ---@type {[table]: fun(self: table, state: svnplug.OnlineState)}
	self.messageListeners = {} ---@type {[table]: fun(self: table, text: string)}
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

function OnlineModel:message(text)
	for instance, f in pairs(self.messageListeners) do
		f(instance, text)
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
			self:message("Could not log in. Make sure you entered the correct email/password")
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
			self:message(err)
		end
		self:onlineStateUpdated()
	end)()
end

---@param score svn.Score
function OnlineModel:submitScore(score)
	coroutine.wrap(function()
		local reward = self.svn_client.remote.submission:submitScore(score)

		if reward then
			print(require("inspect")(reward))
		else
			print("noob")
		end
	end)()
end

return OnlineModel
