-- Bar configuration for SketchyBar
local colors = require("lua.colors")
local sbar = require("sketchybar")

-- Configure the main bar appearance
sbar.bar({
  position = "top",
  height = 32,
  margin = 8,
  padding_left = 10,
  padding_right = 10,
  corner_radius = 8,
  blur_radius = 30,
  color = colors.bar_bg,
  y_offset = 0,
})