local class = require("class")
local bcrypt = require("bcrypt")

local User = require("svn.access.User")
local Session = require("svn.access.Session")

---@class svn.Users
---@operator call: svn.Users
local Users = class()

---@param users_repo svn.UsersRepo
function Users:new(users_repo)
	self.users_repo = users_repo
end

---@param id integer
---@return svn.User?
function Users:getUser(id)
	return self.users_repo:getUser(id)
end

---@param user_values svn.User
---@param ip string
---@param time integer
---@return { user: svn.User, session: svn.Session }?
---@return string? err
function Users:register(user_values, ip, time)
	local user = self.users_repo:findUserByName(user_values.name)

	if user then
		return nil, "Username is already taken"
	end

	user = self.users_repo:findUserByEmail(user_values.email)

	if user then
		return nil, "Email is already in use"
	end


	local log_rounds = 9

	local digest = bcrypt.digest(user_values.password, log_rounds)

	user = User()
	user.name = user_values.name
	user.email = user_values.email
	user.password = digest
	user.creation_date = time
	user = self.users_repo:createUser(user)

	local session = Session()
	session.ip = ip
	session.user_id = user.id
	session.active = true
	session.created_at = time
	session.updated_at = time
	session = self.users_repo:createSession(session)

	user:hideConfidential()
	return { user = user, session = session }
end

---@param user_values svn.User
---@param ip string
---@param time integer
---@return { user: svn.User, session: svn.Session }?
---@return string? err
function Users:login(user_values, ip, time)
	local user = self.users_repo:findUserByEmail(user_values.email)

	if not user then
		return nil, "Failed to log in, invalid credentials"
	end

	local success = bcrypt.verify(user_values.password, user.password)

	if not success then
		return nil, "Failed to log in, incorrect password"
	end

	local session = Session()
	session.ip = ip
	session.user_id = user.id
	session.active = true
	session.created_at = time
	session.updated_at = time
	session = self.users_repo:createSession(session)

	user:hideConfidential()
	return { user = user, session = session }
end

---@param id integer
---@return svn.Session?
function Users:getSession(id)
	return self.users_repo:getSession(id)
end

return Users
