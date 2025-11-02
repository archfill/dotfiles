-- Items configuration for SketchyBar
local colors = require("lua.colors")
local sbar = require("sketchybar")

local plugin_dir = os.getenv("HOME") .. "/.config/sketchybar/plugins"

-- Add event listener for aerospace workspace changes
sbar.add("event", "aerospace_workspace_change")

-- Create workspace indicators for common workspaces
local workspaces = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

for _, ws in ipairs(workspaces) do
	local space = sbar.add("item", "space." .. ws)

	space:set({
		position = "left",
		icon = {
			string = ws,
			color = colors.text,
		},
		background = {
			color = colors.item_bg,
			corner_radius = 5,
			height = 25,
			drawing = "off",
		},
		label = {
			drawing = "off",
		},
		script = plugin_dir .. "/aerospace.sh " .. ws,
		click_script = "aerospace workspace " .. ws,
		update_freq = 2,
	})

	-- Set icon padding separately
	space:set({
		icon = {
			padding_left = 7,
			padding_right = 7,
		},
	})

	space:subscribe("aerospace_workspace_change", function(env)
		-- This will be handled by the shell script
	end)
end

-- Left side items
-- Chevron separator
local chevron = sbar.add("item", "chevron")
chevron:set({
	position = "left",
	icon = {
		string = "",
		color = colors.text,
	},
	label = {
		drawing = "off",
	},
})

-- Front app indicator
local front_app = sbar.add("item", "front_app")
front_app:set({
	position = "left",
	icon = {
		drawing = "off",
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/front_app.sh",
})

front_app:subscribe("front_app_switched", function(env)
	-- This will be handled by the shell script
end)

-- Center items
-- Spotify Player
local spotify = sbar.add("item", "spotify")
spotify:set({
	position = "center",
	update_freq = 2,
	icon = {
		string = "",
		color = colors.spotify,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/spotify.sh",
	drawing = "off",  -- Hidden by default, shown when playing
})

-- Right side items
-- CPU Monitor
local cpu = sbar.add("item", "cpu")
cpu:set({
	position = "right",
	update_freq = 3,
	icon = {
		string = "󰻠",
		color = colors.cpu_normal,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/cpu.sh",
})

-- Memory Monitor
local memory = sbar.add("item", "memory")
memory:set({
	position = "right",
	update_freq = 5,
	icon = {
		string = "󰍛",
		color = colors.memory_normal,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/memory.sh",
})

-- Network Speed
local network = sbar.add("item", "network")
network:set({
	position = "right",
	update_freq = 2,
	icon = {
		string = "󰖟",
		color = colors.network,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/network.sh",
})

-- Weather
local weather = sbar.add("item", "weather")
weather:set({
	position = "right",
	update_freq = 1800,  -- Update every 30 minutes
	icon = {
		string = "󰖐",
		color = colors.weather,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/weather.sh",
})

-- Clock
local clock = sbar.add("item", "clock")
clock:set({
	position = "right",
	update_freq = 10,
	icon = {
		string = "",
		color = colors.clock,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/clock.sh",
})

-- Volume indicator
local volume = sbar.add("item", "volume")
volume:set({
	position = "right",
	icon = {
		color = colors.volume,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/volume.sh",
})

volume:subscribe("volume_change", function(env)
	-- This will be handled by the shell script
end)

-- Battery indicator
local battery = sbar.add("item", "battery")
battery:set({
	position = "right",
	update_freq = 120,
	icon = {
		color = colors.battery_full,
	},
	label = {
		color = colors.text,
	},
	script = plugin_dir .. "/battery.sh",
})

battery:subscribe({ "system_woke", "power_source_change" }, function(env)
	-- This will be handled by the shell script
end)

-- Amphetamine indicator
local amphetamine = sbar.add("item", "amphetamine")
amphetamine:set({
	position = "right",
	icon = {
		string = "󰾫",
		color = colors.peach,
	},
	label = {
		color = colors.text,
	},
	update_freq = 5,
	script = plugin_dir .. "/amphetamine.sh",
	background = {
		color = colors.item_bg,
		corner_radius = 5,
		height = 25,
	},
})

-- IME indicator
local ime_indicator = sbar.add("item", "ime_indicator")
ime_indicator:set({
	position = "right",
	icon = {
		string = "󱌘",
		color = colors.white,
	},
	label = {
		color = colors.text,
	},
	update_freq = 1,
	script = plugin_dir .. "/ime_indicator.sh",
	background = {
		color = colors.ime_bg,
		corner_radius = 5,
		height = 25,
	},
})
