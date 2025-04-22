local class = require("class")

local ScoreReward = require("svn.scores.ScoreReward")

---@class svn.Scores 
---@operator call: svn.Scores
local Scores = class()

---@param users_repo svn.UsersRepo
---@param items_repo svn.ItemsRepo
---@param template_registry svn.TemplateRegistry
function Scores:new(users_repo, items_repo, template_registry)
	self.users_repo = users_repo
	self.items_repo = items_repo
	self.template_registry = template_registry
end

---@param user svn.User
---@param score svn.Score
---@return svn.ScoreReward
function Scores:rewardUser(user, score)
	local reward = ScoreReward()
	reward.coins = 0
	reward.items = {}

	local coins_multiplier = 1

	if score.input_mode == "4key" then
		coins_multiplier = coins_multiplier + math.exp(score.msd_diff / 35)
	else
		coins_multiplier = coins_multiplier + math.exp(score.enps_diff / 29)
	end

	coins_multiplier = coins_multiplier + score.ln_percent
	coins_multiplier = coins_multiplier + score.chart_duration / 480

	reward.coins = (score.score / 1000000) * coins_multiplier

	user.coins = user.coins + reward.coins
	self.users_repo:updateUser(user)

	local template = self.template_registry:createByName("shit_item_gacha")
	template.owner_id = user.id

	if template then
		local item = self.items_repo:getOwnerItemByTemplateId(user.id, template.template_id)

		if item then
			item.amount = item.amount + 1
			self.items_repo:updateItem(item)
		else
			self.items_repo:createItem(template)
		end
	end

	table.insert(reward.items, template)
	return reward
end

return Scores
