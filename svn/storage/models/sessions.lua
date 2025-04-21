local Session = require("svn.access.Session")

---@type rdb.ModelOptions
local sessions = {}

sessions.metatable = Session

sessions.types = {
	active = "boolean",
}

return sessions
