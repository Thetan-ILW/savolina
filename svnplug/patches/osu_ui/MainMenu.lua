local MainMenu = require("osu_ui.views.MainMenu")

local Rectangle = require("ui.Rectangle")

local base_load = MainMenu.load
function MainMenu:load(...)
	base_load(self, ...)

	local scene = self:findComponent("scene")
	local svn_client = scene.ui.game.svnClient ---@type svnplug.SvnClient

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
			coroutine.wrap(function()
				if not svn_client.connected then
					return
				end
				local ok, err = svn_client.remote.auth:getHello()
				if ok then
					print(require("stbl").encode(ok))
				else
					print(err)
				end
			end)()
		end
	}))
end
