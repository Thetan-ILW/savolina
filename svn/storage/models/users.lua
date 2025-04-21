local User = require("svn.access.User")

---@type rdb.ModelOptions
local users = {}

users.metatable = User

return users
