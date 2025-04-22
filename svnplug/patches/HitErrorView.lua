local SvnScoring = require("svnplug.ScoreSystem")
local HitErrorView = require("sphere.views.GameplayView.HitErrorView")
HitErrorView.colors[SvnScoring.name] = {
	marvelous = { 0.6, 0.8, 1, 1 },
	perfect = { 0.6, 0.8, 1, 1 },
	great = { 0.95, 0.796, 0.188, 1 },
	okay = { 0.07, 0.8, 0.56, 1 },
}
