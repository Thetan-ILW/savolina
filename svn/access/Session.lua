local class = require("class")

---@class svn.Session
---@operator call: svn.Session
---@field id integer
---@field user_id integer
---@field active boolean
---@field ip string
---@field created_at integer
---@field updated_at integer
local Session = class()

return Session
