local BaseJudge = require("sphere.models.RhythmModel.ScoreEngine.Judge")

---@alias svnplug.Counter "marvelous" | "perfect" | "great" | "okay" | "miss"

---@class svnplug.Judge: sphere.Judge
---@operator call: svnplug.Judge
local Judge = BaseJudge + {}
Judge.orderedCounters = { "marvelous", "perfect", "great", "okay" }

---@param fever svnplug.Fever
function Judge:new(fever)
	BaseJudge.new(self)
	self.judgeName = "Savolina"
	self.scoreSystemName = "Savolina"

	self.fever = fever

	---@type { [svnplug.Counter]: number }
	self.score_weights_default = {
		marvelous = 350,
		perfect = 300,
		great = 200,
		okay = 100,
		miss = 0
	}

	---@type { [svnplug.Counter]: number }
	self.windows = {
		marvelous = 0.01485,
		perfect = 0.0297,
		great = 0.0594,
		okay = 0.891,
	}

	---@type { [svnplug.Counter]: number }
	self.counters = { -- таблица с результатами нажатий
		marvelous = 0,
		perfect = 0,
		great = 0,
		okay = 0,
		miss = 0,
	}

	self.accuracy = 1
	self.score = 0
	self.combo = 0
end

---@param event { deltaTime: number, newState: string }
function Judge:hit(event)
	local is_release = event.newState == "endPassed" or event.newState == "endMissedPassed"
	local delta_time = event.deltaTime
	delta_time = is_release and delta_time / 1.5 or delta_time

	local counter = self:getCounter(delta_time, self.windows) or "miss"
	self:addCounter(counter, event.currentTime)
	self.fever:hit(counter, event.currentTime)

	local mult = self.fever:getScoreMultiplier(event.currentTime)
	if self.combo < 25 then
		mult = mult
	elseif self.combo < 50 then
		mult = mult * 0.625
	elseif self.combo < 75 then
		mult = mult * 0.75
	elseif self.combo < 100 then
		mult = mult * 0.875
	else
		mult = mult
	end

	if counter == "okay" then
		self.score = self.score + self.score_weights_default.okay * mult
	elseif counter == "miss" then
		self:miss(event)
	else
		self.score = self.score + self.score_weights_default[counter] * mult
		self.combo = self.combo + 1
	end

	local c = self.counters
	local marvelous_weight = 100
	local perfect_weight = 100
	local great_weight = 75
	local okay_weight = 50
	local total_weight = (marvelous_weight * c.marvelous) + (perfect_weight * c.perfect) + (great_weight * c.great) + (okay_weight * c.okay)
	local max_weight = self.notes * marvelous_weight

	self.accuracy = total_weight / max_weight
end

function Judge:miss(event)
	self.combo = self.combo / 2
	self.fever:miss()
	self:addCounter("miss", event.currentTime)
end

function Judge:ghostTap(event)
	self.combo = self.combo / 2
end

function Judge.getTimings()
	local early_hit = -0.1
	local early_miss = -0.1
	local late_hit = 0.1
	local late_miss = 0.1

	return {
		nearest = false,
		ShortNote = { hit = { early_hit, late_hit }, miss = { early_miss, late_miss } },
		LongNoteStart = { hit = { early_hit, late_hit }, miss = { early_miss, late_miss } },
		LongNoteEnd = {
			hit = { early_hit, late_hit },
			miss = { early_miss, late_miss },
		},
	}
end

return Judge
