local main_mod = "SUPER"

local function exec(command)
	return hl.dsp.exec_cmd(command)
end

local function display_keys(keys)
	return keys:gsub("^" .. main_mod, "Super")
end

local function bind(category, keys, description, dispatcher, opts)
	opts = opts or {}
	opts.description = string.format("cheatsheet|%s|%s|%s", category, display_keys(keys), description)
	hl.bind(keys, dispatcher, opts)
end

local function focus_workspace(workspace)
	return hl.dsp.focus({ workspace = workspace })
end

local function move_to_workspace(workspace)
	return hl.dsp.window.move({ workspace = workspace })
end

local function close_workspace_submap()
	hl.dispatch(exec("~/.config/hypr/scripts/submap-overlay.sh close"))
	hl.dispatch(hl.dsp.submap("reset"))
end

local function select_workspace(workspace)
	return function()
		hl.dispatch(focus_workspace(workspace))
		close_workspace_submap()
	end
end

local function move_to_workspace_and_close(workspace)
	return function()
		hl.dispatch(move_to_workspace(workspace))
		close_workspace_submap()
	end
end

-- Applications
bind("01 Applications", main_mod .. " + Return", "Open terminal", exec("ghostty"))
bind("01 Applications", main_mod .. " + E", "Open file manager", exec("nautilus"))
bind("01 Applications", main_mod .. " + D", "Toggle launcher", exec("dms ipc call spotlight toggle"))
bind(
	"01 Applications",
	main_mod .. " + V",
	"Choose clipboard entry",
	exec("dms ipc call clipboard toggle")
)
bind("01 Applications", main_mod .. " + N", "Toggle notifications", exec("dms ipc call notifications toggle"))
bind(
	"01 Applications",
	main_mod .. " + slash",
	"Show keybind cheatsheet",
	exec("dms ipc call keybinds toggle hyprland")
)
bind("01 Applications", main_mod .. " + W", "Toggle launcher", exec("dms ipc call spotlight toggle"))
bind("01 Applications", main_mod .. " + SHIFT + W", "Choose wallpaper", exec("dms ipc call dankdash wallpaper"))

-- Window management
bind("02 Window management", main_mod .. " + Q", "Kill active window", hl.dsp.window.kill())
bind("02 Window management", main_mod .. " + SPACE", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
bind("02 Window management", main_mod .. " + F", "Toggle fullscreen", hl.dsp.window.fullscreen({ action = "toggle" }))
bind("02 Window management", main_mod .. " + T", "Toggle pseudotiling", hl.dsp.window.pseudo({ action = "toggle" }))

bind("02 Window management", main_mod .. " + H", "Focus left", hl.dsp.focus({ direction = "left" }))
bind("02 Window management", main_mod .. " + L", "Focus right", hl.dsp.focus({ direction = "right" }))
bind("02 Window management", main_mod .. " + K", "Focus up", hl.dsp.focus({ direction = "up" }))
bind("02 Window management", main_mod .. " + J", "Focus down", hl.dsp.focus({ direction = "down" }))

bind("02 Window management", main_mod .. " + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "left" }))
bind(
	"02 Window management",
	main_mod .. " + SHIFT + L",
	"Move window right",
	hl.dsp.window.move({ direction = "right" })
)
bind("02 Window management", main_mod .. " + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "up" }))
bind("02 Window management", main_mod .. " + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "down" }))

bind(
	"02 Window management",
	main_mod .. " + SHIFT + left",
	"Resize left",
	hl.dsp.window.resize({ x = -50, y = 0, relative = true })
)
bind(
	"02 Window management",
	main_mod .. " + SHIFT + right",
	"Resize right",
	hl.dsp.window.resize({ x = 50, y = 0, relative = true })
)
bind(
	"02 Window management",
	main_mod .. " + SHIFT + up",
	"Resize up",
	hl.dsp.window.resize({ x = 0, y = -50, relative = true })
)
bind(
	"02 Window management",
	main_mod .. " + SHIFT + down",
	"Resize down",
	hl.dsp.window.resize({ x = 0, y = 50, relative = true })
)

bind("02 Window management", main_mod .. " + CTRL + H", "Move to left monitor", hl.dsp.window.move({ monitor = "l" }))
bind("02 Window management", main_mod .. " + CTRL + L", "Move to right monitor", hl.dsp.window.move({ monitor = "r" }))
bind("02 Window management", main_mod .. " + CTRL + K", "Move to upper monitor", hl.dsp.window.move({ monitor = "u" }))
bind("02 Window management", main_mod .. " + CTRL + J", "Move to lower monitor", hl.dsp.window.move({ monitor = "d" }))

bind("02 Window management", main_mod .. " + mouse:272", "Drag window", hl.dsp.window.drag(), { mouse = true })
bind("02 Window management", main_mod .. " + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Workspaces
bind("03 Workspaces", main_mod .. " + comma", "Previous workspace", focus_workspace("-1"))
bind("03 Workspaces", main_mod .. " + period", "Next workspace", focus_workspace("+1"))
bind("03 Workspaces", main_mod .. " + C", "Toggle scratch workspace", hl.dsp.workspace.toggle_special("scratch"))
bind(
	"03 Workspaces",
	main_mod .. " + SHIFT + C",
	"Send to scratch workspace",
	hl.dsp.window.move({ workspace = "special:scratch", follow = false })
)
bind("03 Workspaces", main_mod .. " + S", "Open workspace switcher", function()
	hl.dispatch(exec("~/.config/hypr/scripts/submap-overlay.sh open"))
	hl.dispatch(hl.dsp.submap("workspace"))
end)

hl.define_submap("workspace", function()
	bind("04 Workspace mode", "A", "Switch to workspace 1", select_workspace("1"))
	bind("04 Workspace mode", "S", "Switch to workspace 2", select_workspace("2"))
	bind("04 Workspace mode", "D", "Switch to workspace 3", select_workspace("3"))
	bind("04 Workspace mode", "F", "Switch to workspace 4", select_workspace("4"))
	bind("04 Workspace mode", "G", "Switch to workspace 5", select_workspace("5"))
	bind("04 Workspace mode", "H", "Previous open workspace", focus_workspace("e-1"))
	bind("04 Workspace mode", "L", "Next open workspace", focus_workspace("e+1"))

	bind("04 Workspace mode", "SHIFT + A", "Move to workspace 1", move_to_workspace_and_close("1"))
	bind("04 Workspace mode", "SHIFT + S", "Move to workspace 2", move_to_workspace_and_close("2"))
	bind("04 Workspace mode", "SHIFT + D", "Move to workspace 3", move_to_workspace_and_close("3"))
	bind("04 Workspace mode", "SHIFT + F", "Move to workspace 4", move_to_workspace_and_close("4"))
	bind("04 Workspace mode", "SHIFT + G", "Move to workspace 5", move_to_workspace_and_close("5"))

	bind("04 Workspace mode", "Escape", "Close workspace switcher", close_workspace_submap)
	bind("04 Workspace mode", "Return", "Close workspace switcher", close_workspace_submap)
	bind("04 Workspace mode", main_mod .. " + S", "Close workspace switcher", close_workspace_submap)
end)

bind("03 Workspaces", main_mod .. " + mouse_down", "Next open workspace", focus_workspace("e+1"))
bind("03 Workspaces", main_mod .. " + mouse_up", "Previous open workspace", focus_workspace("e-1"))

-- Groups
bind("05 Groups", main_mod .. " + G", "Toggle group", hl.dsp.group.toggle())
bind("05 Groups", main_mod .. " + Tab", "Next group tab", hl.dsp.group.next())
bind("05 Groups", main_mod .. " + SHIFT + Tab", "Previous group tab", hl.dsp.group.prev())
bind("05 Groups", main_mod .. " + ALT + H", "Add to group on left", hl.dsp.window.move({ into_group = "l" }))
bind("05 Groups", main_mod .. " + ALT + L", "Add to group on right", hl.dsp.window.move({ into_group = "r" }))
bind("05 Groups", main_mod .. " + ALT + K", "Add to group above", hl.dsp.window.move({ into_group = "u" }))
bind("05 Groups", main_mod .. " + ALT + J", "Add to group below", hl.dsp.window.move({ into_group = "d" }))
bind("05 Groups", main_mod .. " + SHIFT + G", "Remove from group", hl.dsp.window.move({ out_of_group = true }))

-- Screenshots
bind("06 Screenshots", "Print", "Capture region", exec("hyprshot -m region -o ~/Pictures/Screenshots"))
bind("06 Screenshots", "SHIFT + Print", "Capture window", exec("hyprshot -m window -o ~/Pictures/Screenshots"))
bind("06 Screenshots", main_mod .. " + Print", "Capture output", exec("hyprshot -m output -o ~/Pictures/Screenshots"))
bind(
	"06 Screenshots",
	"CTRL + Print",
	"Edit region capture",
	exec("hyprshot -m region -o ~/Pictures/Screenshots --raw | satty --filename -")
)
bind("06 Screenshots", main_mod .. " + P", "Capture region", exec("hyprshot -m region -o ~/Pictures/Screenshots"))
bind(
	"06 Screenshots",
	main_mod .. " + SHIFT + P",
	"Capture window",
	exec("hyprshot -m window -o ~/Pictures/Screenshots")
)
bind(
	"06 Screenshots",
	main_mod .. " + CTRL + P",
	"Capture output",
	exec("hyprshot -m output -o ~/Pictures/Screenshots")
)
bind(
	"06 Screenshots",
	main_mod .. " + ALT + P",
	"Edit region capture",
	exec("hyprshot -m region -o ~/Pictures/Screenshots --raw | satty --filename -")
)

-- Session and media
bind("07 Session and media", main_mod .. " + R", "Restart shell", exec("~/.config/hypr/scripts/restart-shell.sh"))
bind("07 Session and media", main_mod .. " + SHIFT + R", "Reload Hyprland", exec("hyprctl reload"))
bind("07 Session and media", "SHIFT + Z", "Lock session", exec("~/.config/hypr/scripts/lock-session.sh"))
bind("07 Session and media", main_mod .. " + M", "Toggle power menu", exec("dms ipc call powermenu toggle"))
bind("07 Session and media", main_mod .. " + ALT + W", "Next window and raise", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end)
bind("07 Session and media", main_mod .. " + ALT + Q", "Previous window and raise", function()
	hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
	hl.dispatch(hl.dsp.window.bring_to_top())
end)

bind(
	"07 Session and media",
	"XF86AudioRaiseVolume",
	"Raise volume",
	exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true }
)
bind(
	"07 Session and media",
	"XF86AudioLowerVolume",
	"Lower volume",
	exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeating = true }
)
bind("07 Session and media", "XF86AudioMute", "Toggle audio mute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
bind(
	"07 Session and media",
	"XF86AudioMicMute",
	"Toggle microphone mute",
	exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
)
bind("07 Session and media", "XF86AudioPlay", "Play or pause", exec("playerctl play-pause"))
bind("07 Session and media", "XF86AudioPause", "Play or pause", exec("playerctl play-pause"))
bind("07 Session and media", "XF86AudioNext", "Next track", exec("playerctl next"))
bind("07 Session and media", "XF86AudioPrev", "Previous track", exec("playerctl previous"))
bind(
	"07 Session and media",
	"XF86MonBrightnessUp",
	"Raise brightness",
	exec("brightnessctl set 5%+"),
	{ repeating = true }
)
bind(
	"07 Session and media",
	"XF86MonBrightnessDown",
	"Lower brightness",
	exec("brightnessctl set 5%-"),
	{ repeating = true }
)
