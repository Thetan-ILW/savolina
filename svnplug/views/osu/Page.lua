local Component = require("ui.Component")

local flux = require("flux")

---@class svnplug.osu.Page : ui.Component
---@operator call: svnplug.osu.Page
---@field transitInTween table?
---@field transitOutTween table?
local Page = Component + {}

function Page:load()
	self.width, self.height = self.parent:getDimensions()
	self.x = self.width / 2
	self.y = self.height / 2
	self.origin = { x = 0.5, y = 0.5 }
	self.alpha = 0
	self.handleEvents = false
	self.transitInTween = flux.to(self, 0.2, { alpha = 1 }):ease("sineout"):oncomplete(function ()
		self.handleEvents = true
	end)
end

function Page:transitOut()
	if self.transitOutTween then
		return
	end
	if self.transitInTween then
		self.transitInTween:stop()
	end
	self.handleEvents = false
	self.transitOutTween = flux.to(self, 0.3, { alpha = 0, scaleX = 0.9, scaleY = 0.9 }):ease("sineout"):oncomplete(function ()
		self:kill()
	end)
end

return Page
