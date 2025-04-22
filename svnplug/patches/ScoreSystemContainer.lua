local ScoreSystemContainer = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystemContainer")
local SvnScoring = require("svnplug.ScoreSystem")
table.insert(ScoreSystemContainer.modules, SvnScoring)
