local class = require("class")

---@class svn.SubmissionServerRemote : svn.IServerRemote
---@operator call: svn.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param scores svn.Scores
function SubmissionServerRemote:new(scores)
	self.scores = scores
end

---@param score svn.Score
---@return svn.ScoreReward?
function SubmissionServerRemote:submitScore(score)
	if not self.ctx.user then
		return
	end

	if score.chart_duration < 30 then
		return
	end

	local reward = self.scores:rewardUser(self.ctx.user, score)
	return reward
end

return SubmissionServerRemote
