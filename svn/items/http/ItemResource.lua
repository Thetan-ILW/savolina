local IResource = require("web.framework.IResource")

local json = require("web.json")

---@class svn.ItemResource : web.IResource
---@operator call: svn.ItemResource
local ItemResource = IResource + {}

ItemResource.routes = {
	{ "/inventory/:user_id", {
		GET = "getInventory"
	}}
}

---@param items svn.Items
function ItemResource:new(items)
	self.items = items
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx svn.RequestContext
function ItemResource:getInventory(req, res, ctx)
	if not ctx.session_user then
		res.status = 401
		return
	end

	local target_user_id = tonumber(ctx.path_params.user_id)

	if not target_user_id then
		res.status = 400
		return
	end

	if target_user_id ~= ctx.session_user.id then
		res.status = 403
		return
	end

	local items = self.items:getInventory(target_user_id)
	local payload = json.encode(items)

	res.headers:set("Content-Type", "application/json")
	res:set_length(payload:len())
	res:send(payload)
end

return ItemResource
