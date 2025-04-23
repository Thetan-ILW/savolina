local class = require("class")

---@class svn.ItemsRepo
---@operator call: svn.ItemsRepo
local ItemsRepo = class()

---@param models rdb.Models
---@param template_registry svn.TemplateRegistry
function ItemsRepo:new(models, template_registry)
	self.models = models
	self.template_registry = template_registry
end

---@param id integer
---@return svn.InventoryEntry?
function ItemsRepo:getItem(id)
	return self.models.inventory_entries:find({ id = assert(id) })
end

---@param owner_id integer
---@param template_id integer
---@return svn.InventoryEntry?
function ItemsRepo:getOwnerItemByTemplateId(owner_id, template_id)
	return self.models.inventory_entries:find({ template_id = assert(template_id), owner_id = assert(owner_id) })
end

---@param owner_id integer
---@return svn.InventoryEntry[]
function ItemsRepo:getOwnerItems(owner_id)
	return self.models.inventory_entries:select({ owner_id = assert(owner_id) })
end

---@param item svn.Item
---@return svn.Item
function ItemsRepo:createItem(item)
	assert(item.owner_id)
	local inserted_item = self.models.items:create(item)

	if item.type == item.Type.Wearable then
		self.models.wearable_params:create(item)
	end

	item.id = inserted_item.id
	return item
end

---@param item svn.Item
---@return svn.Item
function ItemsRepo:updateItem(item)
	self.models.items:update(item, { id = item.id })

	if item.type == item.Type.Wearable then
		self.models.wearable_params:update(item, { id = item.id })
	end

	return item
end

return ItemsRepo
