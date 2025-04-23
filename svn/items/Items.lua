local class = require("class")

---@class svn.Items
---@operator call: svn.Items
local Items = class()

---@param items_repo svn.ItemsRepo
function Items:new(items_repo)
	self.items_repo = items_repo
end

---@param owner_id integer
function Items:getInventory(owner_id)
	return self.items_repo:getOwnerItems(owner_id)
end

---@param item svn.Item
---@return svn.Item?
function Items:addItem(item)
	if not item.owner_id then
		return
	end

	if not item:canStack() then
		return self.items_repo:createItem(item)
	end

	local existing_item = self.items_repo:getOwnerItemByTemplateId(item.owner_id, item.template_id)

	if not existing_item then
		return self.items_repo:createItem(item)
	end

	existing_item.amount = existing_item.amount + item.amount
	return self.items_repo:updateItem(existing_item)
end

return Items
