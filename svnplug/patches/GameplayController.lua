local GameplayController = require("sphere.controllers.GameplayController")

local Score = require("svn.scores.Score")

local base_save_score = GameplayController.saveScore
function GameplayController:saveScore()
	base_save_score(self)

	local score_system = self.rhythmModel.scoreEngine.scoreSystem
	local chartdiff = self.playContext.chartdiff
	local judge = score_system.Savolina.judge ---@cast svnplug.Judge

	local score = Score()
	score.score = judge.score
	score.msd_diff = chartdiff.msd_diff or 0
	score.enps_diff = chartdiff.enps_diff or 0
	score.chart_duration = chartdiff.duration
	score.ln_percent = chartdiff.long_notes_count / chartdiff.notes_count
	score.note_count = chartdiff.notes_count
	score.input_mode = chartdiff.inputmode

	local svn_client = self.svn_client ---@type svnplug.SvnClient
	local inventory_model = self.svn_inventory_model ---@type svnplug.InventoryModel

	coroutine.wrap(function ()
		local changed_items = svn_client.remote.submission:submitScore(score)

		if changed_items then
			inventory_model:updateInventory(changed_items, false)
		end
	end)()
end
