require("preload")
local App = require("svn.app.App")

local app = App()

---@param req web.IRequest
---@param res web.IResponse
---@param ip string
local function handler(req, res, ip)
	app:handle(req, res, ip)
end

return handler
