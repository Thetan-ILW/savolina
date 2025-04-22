local MainMenu = require("osu_ui.views.MainMenu")

local Rectangle = require("ui.Rectangle")

local base_load = MainMenu.load
function MainMenu:load(...)
	base_load(self, ...)

	self:addChild("savolina", Rectangle({
		x = 20,
		y = 200,
		width = 100,
		height = 100,
		z = 0.5,
		mouseClick = function(this)
			if not this.mouseOver then
				return
			end
			self:toNextView("savolinaLoadout")
		end
	}))
end
