local class = require("class")
local table_util = require("table_util")

local EventDispatcher = require("svnplug.events.EventDispatcher")
local InventoryLoadedEvent = require("svnplug.events.InventoryLoadedEvent")
local InventoryUpdateEvent = require("svnplug.events.InventoryUpdateEvent")

---@class svnplug.InventoryModel
---@operator call: svnplug.InventoryModel
---@field items {[integer]: svn.Item}
---@field last_changes svn.Item[]
---@field state "not_loaded" | "loading" | "loaded"
local InventoryModel = class()

---@param template_registry svn.TemplateRegistry
---@param svn_client svnplug.SvnClient
function InventoryModel:new(template_registry, svn_client)
	self.template_registry = template_registry
	self.svn_client = svn_client
	self.events = EventDispatcher()

	self.items = {}
	self.last_changes = {}
	self.state = "not_loaded"
end

function InventoryModel:loadInventoryFromServer()
	self.state = "loading"

	coroutine.wrap(function ()
		local items = self.svn_client.remote.items:getInventory()
		self.state = "loaded"
		self:updateInventory(items, true)
	end)()
end

---@param changed_item svn.InventoryEntry
---@param track_changes boolean
---@private
function InventoryModel:replaceItem(changed_item, track_changes)
	local item_id = changed_item.id ---@cast item_id integer
	local item = self.items[item_id]

	if item then
		if track_changes then
			local template = self.template_registry:createById(changed_item.template_id)
			template.amount = changed_item.amount - item.amount
			table.insert(self.last_changes, template)
		end

		table_util.copy(changed_item, item)
		return
	end

	local template = self.template_registry:createById(changed_item.template_id)
	table_util.copy(changed_item, template)
	self.items[item_id] = template
end

---@param changed_items svn.InventoryEntry[]
---@param full_update boolean Removes all items from the current inventory to replace with the new ones
function InventoryModel:updateInventory(changed_items, full_update)
	if full_update then
		self.items = {}
	end

	self.last_changes = {}

	for _, changed_item in ipairs(changed_items) do
		if changed_item.id then
			self:replaceItem(changed_item, not full_update)
		else
			print("Got unknown item from the server")
		end
	end

	if full_update then
		self.events:dispatch(InventoryLoadedEvent())
		return
	end

	local e = InventoryUpdateEvent()
	e.changed_items = self.last_changes
	self.events:dispatch(e)
end

---@return number
function InventoryModel:getAmountOfCoins()
	local coins = self.template_registry:createByName("coins")
	assert(coins)

	for _, item in pairs(self.items) do
		if item.template_id == coins.template_id then
			return item.amount
		end
	end

	return 0
end

return InventoryModel
