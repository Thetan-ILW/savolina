local class = require("class")

---@class svn.User
---@operator call: svn.User
---@field id integer
---@field name string
---@field email string
---@field password string
---@field creation_date integer
---@field level integer
---@field experience integer
---@field coins number
local User = class()

function User:new()
	self.level = 0
	self.experience = 0
	self.coins = 0
end

function User:hideConfidential()
	self.email = nil
	self.password = nil
end

---@return boolean success
---@return string[]? errors
function User:validateLogin()
	local errs = {}

	local email = self.email
	if type(email) ~= "string" or not email:find("@") then
		table.insert(errs, "invalid email")
	end

	local password = self.password
	if type(password) ~= "string" or #password == 0 then
		table.insert(errs, "invalid password")
	end

	if #errs > 0 then
		return false, errs
	end

	return true
end

---@return boolean success
---@return string[]? errors
function User:validateRegister()
	local _, errs = self:validateLogin()

	errs = errs or {}

	local name = self.name
	if type(name) ~= "string" or #name == 0 then
		table.insert(errs, "invalid name")
	end

	if #errs > 0 then
		return false, errs
	end

	return true
end

---@param target_user_id integer?
---@return boolean
function User:isOwner(target_user_id)
	if not target_user_id then
		return false
	end

	if target_user_id ~= self.id then
		return false
	end

	return true
end

return User
