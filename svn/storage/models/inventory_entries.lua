local Item = require("svn.items.Item")
local Wearable = require("svn.items.Wearable")

---@type rdb.ModelOptions
local inventory_entries = {}

---@class svn.InventoryEntry : svn.Item, svn.Wearable
local InventoryEntry = Item + Wearable

inventory_entries.metatable = InventoryEntry

return inventory_entries
