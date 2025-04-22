local class = require("class")

---@class svnplug.Fever
---@operator call: svnplug.Fever
local Fever = class()

---@param note_count number
---@param chart_duration number
function Fever:new(note_count, chart_duration)
	self.fill_rate = 0.28
	self.max_duration = 0.16
	self.multiplier = 3 -- Score multiplier
	self.miss_duration_punishment = 0.1

	self.required_fill = math.floor(note_count * self.fill_rate)
	self.current_fill = 0

	self.duration = chart_duration * self.max_duration
	self.end_time = -math.huge -- Indicates the time at which the current fever will end.
end

---@param current_time number
---@return boolean
function Fever:isActive(current_time)
	return current_time <= self.end_time
end

---@param current_time number
---@return number
function Fever:getRemainingTime(current_time)
	return self.end_time - current_time
end

---@param current_time number
---@return number
function Fever:getScoreMultiplier(current_time)
	if self:isActive(current_time) then
		return self.multiplier
	end
	return 1
end

---@param counter svn.Counter
---@param current_time number
function Fever:hit(counter, current_time)
	if self:isActive(current_time) then
		return
	end

	local fill = 0

	if counter == "marvelous" then
		fill = 1
	elseif counter == "perfect" then
		fill = 0.75
	elseif counter == "great" then
		fill = 0.5
	end

	self.current_fill = self.current_fill + fill

	if self.current_fill >= self.required_fill then
		self.current_fill = 0
		self.end_time = current_time + self.duration
	end
end

function Fever:miss()
	self.end_time = self.end_time - (self.duration * self.miss_duration_punishment)
end

return Fever
