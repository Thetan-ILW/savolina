local class = require("class")

---@class svn.TemplateRegistry 
---@operator call: svn.TemplateRegistry
---@field registry svn.Item[] An array of items of any type. Index is the ID
---@field names { [string]: svn.Item }
---@field error_item svn.Item
local TemplateRegistry = class()

function TemplateRegistry:new()
	self.registry = {}
	self.names = {}
end

---@param name string
---@param item svn.Item
function TemplateRegistry:add(name, item)
	assert(type(name) == "string", "Expected string for a name")

	if self.names[name] then
		error(("Item with the name '%s' already exists in the registry"):format(name))
	end

	self.names[name] = item
	table.insert(self.registry, item)
	item.template_id = #self.registry
end

---@param id integer
---@return svn.Item?
function TemplateRegistry:createById(id)
	local item = self.registry[id]
	return item and item:copy()
end

---@param name string 
---@return svn.Item?
function TemplateRegistry:createByName(name)
	local item = self.names[name]
	return item and item:copy()
end

return TemplateRegistry
