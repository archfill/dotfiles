local M = {}

function M.apply()
	hl.on("hyprland.start", function()
		hl.exec_cmd(
			"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS HYPRLAND_INSTANCE_SIGNATURE PATH GTK_IM_MODULE QT_IM_MODULE XMODIFIERS INPUT_METHOD SDL_IM_MODULE"
		)
		hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
		hl.exec_cmd("1password")
		hl.exec_cmd("fcitx5 -d")
		hl.exec_cmd("systemctl --user start caelestia.service")
		hl.exec_cmd("systemctl --user start hyprpolkitagent")
		hl.exec_cmd(
			"bash -c 'if [ -f ~/.config/hypr/hypridle.local.conf ]; then hypridle -c ~/.config/hypr/hypridle.local.conf; else hypridle; fi'"
		)
		hl.exec_cmd("wl-paste --type text --watch cliphist store")
		hl.exec_cmd("wl-paste --type image --watch cliphist store")
	end)
end

return M
