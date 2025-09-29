-- SketchyBar Lua Configuration
-- Main entry point for SbarLua configuration
-- Based on the structure from SoichiroYamane/dotfiles

-- Setup SbarLua module path
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

local sbar = require("sketchybar")

-- Begin configuration
sbar.begin_config()

-- Load modular configuration files
require("lua.bar")
require("lua.default")
require("lua.items")

-- End configuration
sbar.end_config()

-- Start event loop for callbacks
sbar.event_loop()