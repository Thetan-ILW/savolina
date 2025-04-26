local class = require("class")

---@class svnplug.EventDispatcher
---@operator call: svnplug.EventDispatcher
---@field listeners {[table]: fun(self: table, event: svnplug.Event)}
local EventDispatcher = class()

function EventDispatcher:new()
	self.listeners = {}
end

---@param instance table
---@param f fun(self: table, event: svnplug.Event)
function EventDispatcher:listen(instance, f)
	self.listeners[instance] = f
end

---@param instance table
function EventDispatcher:stop(instance)
	self.listeners[instance] = nil
end

---@param event svnplug.Event
function EventDispatcher:dispatch(event)
	for instance, f in pairs(self.listeners) do
		f(instance, event)
	end
end

return EventDispatcher
