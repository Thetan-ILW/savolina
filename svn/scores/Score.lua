local class = require("class")

---@class svn.Score
---@operator call: svn.Score
---@field input_mode string
---@field note_count number
---@field chart_duration number
---@field msd_diff number
---@field enps_diff number
---@field ln_percent number Value between 0 and 1
---@field score number
local Score = class()

return Score
