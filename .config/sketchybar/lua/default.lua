-- Default settings for SketchyBar items
local colors = require("lua.colors")
local sbar = require("sketchybar")

-- Set default properties for all items
sbar.default({
  padding_left = 5,
  padding_right = 5,
  icon = {
    font = "HackGen35 Console NF:Bold:17.0",
    color = colors.white,
    padding_left = 4,
    padding_right = 4,
  },
  label = {
    font = "HackGen35 Console NF:Bold:14.0",
    color = colors.white,
    padding_left = 4,
    padding_right = 4,
  },
})