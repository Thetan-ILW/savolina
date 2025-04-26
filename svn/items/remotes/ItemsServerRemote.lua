local class = require("class")

---@class svn.ItemsServerRemote : svn.IServerRemote
---@operator call: svn.ItemsServerRemote
local ItemsServerRemote = class()

---@param items svn.Items
function ItemsServerRemote:new(items)
	self.items = items
end

---@return svn.InventoryEntry[]
function ItemsServerRemote:getInventory()
	if not self.ctx.user then
		return {}
	end

	return self.items:getInventory(self.ctx.user.id)
end

return ItemsServerRemote
