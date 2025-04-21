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

return Items
