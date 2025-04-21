local class = require("class")

---@class svn.UsersRepo
---@operator call: svn.UsersRepo
local UsersRepo = class()

---@param models rdb.Models
function UsersRepo:new(models)
	self.models = models
end

---@param id integer
---@return svn.User?
function UsersRepo:getUser(id)
	return self.models.users:find({ id = assert(id) })
end

---@param name string
---@return svn.User?
function UsersRepo:findUserByName(name)
	return self.models.users:find({ name = assert(name) })
end

---@param email string
---@return svn.User?
function UsersRepo:findUserByEmail(email)
	return self.models.users:find({ email = assert(email) })
end

---@return svn.User[]
function UsersRepo:getUsers()
	return self.models.users:select()
end

---@param user svn.User
---@return svn.User
function UsersRepo:createUser(user)
	return self.models.users:create(user)
end

---@param user svn.User
---@return svn.User
function UsersRepo:updateUser(user)
	return self.models.users:update(user, { id = assert(user.id) })[1]
end

------------------------------------------------------------------------------

---@param id number
---@return svn.Session?
function UsersRepo:getSession(id)
	return self.models.sessions:find({ id = assert(id) })
end

---@param session svn.Session
---@return svn.Session
function UsersRepo:createSession(session)
	return self.models.sessions:create(session)
end

---@param session svn.Session
---@return svn.Session?
function UsersRepo:updateSession(session)
	return self.models.sessions:update(session, { id = assert(session.id) })
end

return UsersRepo

