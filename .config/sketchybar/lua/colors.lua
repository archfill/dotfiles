-- Color definitions for SketchyBar
-- Theme: Catppuccin Mocha (Most Popular 2024-2025)

-- Catppuccin Mocha Theme
local catppuccin = {
	-- Base colors
	base = 0xcc1e1e2e,
	mantle = 0xcc181825,
	crust = 0xcc11111b,

	-- Text colors
	text = 0xffcdd6f4,
	subtext1 = 0xffbac2de,
	subtext0 = 0xffa6adc8,

	-- Surface colors
	surface0 = 0xcc313244,
	surface1 = 0xcc45475a,
	surface2 = 0xcc585b70,

	-- Accent colors
	blue = 0xff89b4fa,
	lavender = 0xffb4befe,
	sapphire = 0xff74c7ec,
	sky = 0xff89dceb,
	teal = 0xff94e2d5,
	green = 0xffa6e3a1,
	yellow = 0xfff9e2af,
	peach = 0xfffab387,
	maroon = 0xffeba0ac,
	red = 0xfff38ba8,
	mauve = 0xffcba6f7,
	pink = 0xfff5c2e7,
	flamingo = 0xfff2cdcd,
	rosewater = 0xfff5e0dc,

	-- Special colors
	white = 0xffffffff,
	black = 0xff000000,
	transparent = 0x00000000,
}

-- Nord Theme (Alternative - Uncomment to use)
--[[
local nord = {
	base = 0xcc2e3440,
	surface = 0xcc3b4252,
	overlay = 0xcc434c5e,
	text = 0xffeceff4,
	subtext = 0xffe5e9f0,
	blue = 0xff88c0d0,
	cyan = 0xff8fbcbb,
	green = 0xffa3be8c,
	yellow = 0xffebcb8b,
	orange = 0xffd08770,
	red = 0xffbf616a,
	magenta = 0xffb48ead,
	white = 0xffffffff,
	black = 0xff000000,
	transparent = 0x00000000,
}
]]

-- Tokyo Night Theme (Alternative - Uncomment to use)
--[[
local tokyo_night = {
	base = 0xcc1a1b26,
	surface = 0xcc16161e,
	overlay = 0xcc292e42,
	text = 0xffa9b1d6,
	subtext = 0xff787c99,
	blue = 0xff7aa2f7,
	cyan = 0xff7dcfff,
	green = 0xff9ece6a,
	yellow = 0xffe0af68,
	orange = 0xffff9e64,
	red = 0xfff7768e,
	magenta = 0xffbb9af7,
	white = 0xffffffff,
	black = 0xff000000,
	transparent = 0x00000000,
}
]]

-- Export theme (change 'catppuccin' to 'nord' or 'tokyo_night' to switch themes)
local colors = catppuccin

-- Semantic color mappings for SketchyBar items
return {
	-- Bar colors
	bar_bg = colors.base,
	bar_border = colors.surface2,

	-- Item colors
	item_bg = colors.surface0,
	item_bg_hover = colors.surface1,

	-- Text colors
	text = colors.text,
	subtext = colors.subtext0,
	white = colors.white,
	black = colors.black,

	-- System monitoring colors
	cpu_normal = colors.blue,
	cpu_warning = colors.yellow,
	cpu_critical = colors.red,

	memory_normal = colors.green,
	memory_warning = colors.yellow,
	memory_critical = colors.red,

	network = colors.sky,

	-- Media colors
	spotify = 0xff1DB954,  -- Spotify brand green

	-- UI element colors
	workspace_active = colors.blue,
	workspace_occupied = colors.surface2,
	workspace_empty = colors.surface0,

	battery_charging = colors.green,
	battery_full = colors.green,
	battery_medium = colors.yellow,
	battery_low = colors.red,

	volume = colors.lavender,
	weather = colors.peach,
	clock = colors.text,
	ime_bg = colors.sapphire,

	-- Accent colors (direct access)
	blue = colors.blue,
	green = colors.green,
	yellow = colors.yellow,
	red = colors.red,
	pink = colors.pink,
	lavender = colors.lavender,
	peach = colors.peach,

	-- Utility
	transparent = colors.transparent,
	semi_transparent = 0x80000000,
}
