-- Hammerspoon Configuration
-- Modular, Extensible, Data-Driven
--
-- Structure:
--   init.lua       - Bootstrap (this file)
--   config.lua     - Configuration values
--   modules/       - Feature modules
--   utils/         - Helper functions

--------------------------------------------------------------------------------
-- Load Dependencies
--------------------------------------------------------------------------------

local config = require("config")
local helpers = require("utils.helpers")

--------------------------------------------------------------------------------
-- Load Modules
--------------------------------------------------------------------------------

-- Application launcher (Hyper + key to toggle apps)
local apps = require("modules.apps")
apps.init(config, helpers)

-- Config reload functionality
local reload = require("modules.reload")
reload.init(config, helpers)

-- Window management (temporary maximize toggle, positioning)
local windows = require("modules.windows")
windows.init(config, helpers)

-- FZF window switcher (fzf-powered window selection)
local fzf = require("modules.fzf")
fzf.init(config, helpers)

-- Window groups (Hyprland-style stacking)
local groups = require("modules.groups")
groups.init(config, helpers)

-- dアニメ playback popup avoidance
local pipAvoidance = require("modules.pip_avoidance")
pipAvoidance.init(config, helpers)
