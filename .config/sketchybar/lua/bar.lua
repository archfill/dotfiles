-- Bar configuration for SketchyBar
-- Theme: Catppuccin Mocha
local colors = require("lua.colors")
local sbar = require("sketchybar")

-- Configure the main bar appearance
sbar.bar({
  position = "top",
  height = 36,
  margin = 10,
  padding_left = 12,
  padding_right = 12,
  corner_radius = 10,
  blur_radius = 50,
  color = colors.bar_bg,
  border_color = colors.bar_border,
  border_width = 0,
  y_offset = 4,
  shadow = "on",
})