local class = require("class")

local ScoreReward = require("svn.scores.ScoreReward")

---@class svn.Scores 
---@operator call: svn.Scores
local Scores = class()

---@param users_repo svn.UsersRepo
---@param items svn.Items
---@param template_registry svn.TemplateRegistry
function Scores:new(users_repo, items, template_registry)
	self.users_repo = users_repo
	self.items = items
	self.template_registry = template_registry
end

---@param user svn.User
---@param score svn.Score
---@return svn.ScoreReward
function Scores:rewardUser(user, score)
	local reward = ScoreReward()
	reward.changed_items = {}

	local coins_multiplier = 1

	if score.input_mode == "4key" then
		coins_multiplier = coins_multiplier + math.exp(score.msd_diff / 35)
	else
		coins_multiplier = coins_multiplier + math.exp(score.enps_diff / 29)
	end

	coins_multiplier = coins_multiplier + score.ln_percent
	coins_multiplier = coins_multiplier + score.chart_duration / 480

	local coins_item = self.template_registry:createByName("coins")
	assert(coins_item)
	coins_item.owner_id = user.id
	coins_item.amount = math.ceil((score.score / 1000000) * coins_multiplier)
	table.insert(reward.changed_items, self.items:addItem(coins_item))

	local lootbox = self.template_registry:createByName("poor_lootbox")
	assert(lootbox)
	lootbox.owner_id = user.id
	table.insert(reward.changed_items, self.items:addItem(lootbox))

	return reward
end

return Scores
