local class = require("class")

---@class svn.IClientRemote
---@field remote svn.ServerRemote

---@class svn.ClientRemote
---@operator call: svn.ClientRemote
local ClientRemote = class()

---@param game sphere.GameplayController
function ClientRemote:new(game)
end

return ClientRemote
