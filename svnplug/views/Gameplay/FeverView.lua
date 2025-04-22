local class = require("class")
local transform = require("gfx_util").transform

local Path = require("Path")

---@class svnplug.FeverView
---@operator call: svnplug.FeverView
local FeverView = class()

function FeverView:load()
	self.tf = transform(self.transform)

	---@type sphere.GameController
	local game = self.game

	local svn_pkg = game.packageManager:getPackage("svnplug")

	if not svn_pkg then
		self.update = function () end
		self.draw = function () end
		print("svn plugin is not installed")
		return
	end

	---@type svn.Scoring
	local svn = game.rhythmModel.scoreEngine.scoreSystem.Savolina


	self.width = self.width or 200
	self.height = self.height or 20
	---@type svn.Fever
	self.fever = svn.judge.fever
	---@type sphere.TimeEngine
	self.time_engine = self.game.rhythmModel.timeEngine
end

function FeverView:draw()
	love.graphics.replaceTransform(self.tf)
	love.graphics.translate(self.x, self.y)

	local current_time = self.time_engine.currentTime
	local fever_percent = 0

	if self.fever:isActive(current_time) then
		fever_percent = self.fever:getRemainingTime(current_time) / self.fever.duration
		love.graphics.setColor(0.6, 0.91, 1)
	else
		fever_percent = self.fever.current_fill / self.fever.required_fill
		love.graphics.setColor(1, 1, 1)
	end

	love.graphics.setLineWidth(2)
	love.graphics.rectangle("fill", 0, 0, self.width * fever_percent, self.height)
	love.graphics.rectangle("line", 0, 0, self.width, self.height)
end

return FeverView
