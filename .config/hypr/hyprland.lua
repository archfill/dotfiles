-- Hyprland Lua configuration entrypoint.
local colors = require("colors")

require("modules.monitors").apply()
require("modules.environment").apply()
require("modules.appearance").apply(colors)
require("modules.rules").apply()
require("modules.autostart").apply()
require("modules.keybinds")
