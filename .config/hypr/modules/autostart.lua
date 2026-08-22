local M = {}

function M.apply()
	hl.on("hyprland.start", function()
		hl.exec_cmd(
			"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS HYPRLAND_INSTANCE_SIGNATURE PATH GTK_IM_MODULE QT_IM_MODULE XMODIFIERS INPUT_METHOD SDL_IM_MODULE"
		)
		hl.exec_cmd("sh -c '[ -n \"$NOTIFY_SOCKET\" ] && uwsm finalize'")
		hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
		hl.exec_cmd("1password")
		hl.exec_cmd("fcitx5 -d")
	end)
end

return M
