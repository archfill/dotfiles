local M = {}

function M.apply(colors)
	hl.config({
		cursor = {
			no_hardware_cursors = false,
		},
		input = {
			kb_layout = "us",
			repeat_rate = 75,
			repeat_delay = 300,
			follow_mouse = 0,
			touchpad = {
				natural_scroll = false,
			},
		},
		general = {
			gaps_in = 5,
			gaps_out = 10,
			border_size = 2,
			col = {
				active_border = { colors = { colors.primary, colors.tertiary }, angle = 45 },
				inactive_border = colors.surface_variant,
			},
			layout = "dwindle",
			allow_tearing = false,
		},
		xwayland = {
			force_zero_scaling = true,
		},
		decoration = {
			rounding = 10,
			blur = {
				enabled = true,
				size = 3,
				passes = 1,
				vibrancy = 0.1696,
			},
			shadow = {
				enabled = true,
				range = 4,
				render_power = 3,
				color = "rgba(1a1a1aee)",
			},
		},
		dwindle = {
			preserve_split = true,
		},
		master = {
			new_status = "master",
		},
		group = {
			col = {
				border_active = colors.primary,
				border_inactive = colors.surface_variant,
			},
			groupbar = {
				enabled = true,
				font_family = "JetBrainsMono Nerd Font Propo",
				font_size = 11,
				height = 22,
				gradients = true,
				render_titles = true,
				text_color = colors.on_surface,
				col = {
					active = colors.primary,
					inactive = colors.surface,
				},
			},
		},
		misc = {
			force_default_wallpaper = 0,
			disable_hyprland_logo = true,
		},
	})

	hl.curve("myBezier", {
		type = "bezier",
		points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
	})

	for _, animation in ipairs({
		{ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" },
		{ leaf = "windowsOut", enabled = true, speed = 7, bezier = "myBezier", style = "popin 80%" },
		{ leaf = "border", enabled = true, speed = 10, bezier = "myBezier" },
		{ leaf = "borderangle", enabled = true, speed = 8, bezier = "myBezier" },
		{ leaf = "fade", enabled = true, speed = 7, bezier = "myBezier" },
		{ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" },
	}) do
		hl.animation(animation)
	end
end

return M
