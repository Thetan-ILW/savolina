local GameController = require("sphere.controllers.GameController")

local base_update = GameController.update
function GameController:update(dt)
	base_update(self, dt)
	self.svnClient:update()

end
