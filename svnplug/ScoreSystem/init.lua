local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")
local Judge = require("svnplug.ScoreSystem.Judge")
local Fever = require("svnplug.ScoreSystem.Fever")

---@class svnplug.Scoring: sphere.ScoreSystem
---@operator call: svnplug.Scoring
local SvnScoring = ScoreSystem + {}

SvnScoring.name = "Savolina"
SvnScoring.metadata = {
	name = "Savolina",
	hasAccuracy = true,
	hasScore = true,
	accuracyFormat = "%0.02f%%",
	accuracyMultiplier = 100,
	scoreFormat = "%i",
	scoreMultiplier = 1
}

---@param s string
---@return svn.PowerElement
local function getPowerElement(s)
	local sum = 0
	for i = 1, string.len(s) do
		sum = sum + string.byte(s, i)
	end
	return (sum % 3) + 1
end

function SvnScoring:getAccuracy()
	return self.judge.accuracy
end

function SvnScoring:getScore()
	return self.judge.score
end

function SvnScoring:load()
	local chart_duration = self.scoreEngine.noteChart.chartmeta.duration
	local note_count = self.scoreEngine.noteChart.chartdiff.notes_count

	local fever = Fever(note_count, chart_duration)
	self.judge = Judge(fever)

	self.judges = {
		[self.metadata.name] = self.judge
	}
end

function SvnScoring:hit(event)
	self.judge:hit(event)
end

function SvnScoring:miss(event)
	self.judge:miss(event)
end

function SvnScoring:ghostTap(event)
	self.judge:ghostTap(event)
end

function SvnScoring:getTimings()
	return Judge.getTimings()
end

function SvnScoring:getSlice()
	return {}
end

SvnScoring.notes = {
	ShortNote = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = "ghostTap",
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "hit",
			startMissed = "miss",
			startMissedPressed = "miss",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = "miss",
			endMissed = "miss",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = "hit",
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "miss",
		},
	},
}

return SvnScoring
