local M = {}

function M.apply()
	for _, variable in ipairs({
		{ "XDG_CURRENT_DESKTOP", "Hyprland" },
		{ "XDG_SESSION_TYPE", "wayland" },
		{ "XDG_SESSION_DESKTOP", "Hyprland" },
		{ "QT_QPA_PLATFORM", "wayland" },
		{ "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
		{ "QT_AUTO_SCREEN_SCALE_FACTOR", "1" },
		{ "QT_STYLE_OVERRIDE", "adwaita-dark" },
		{ "GTK_THEME", "Adwaita:dark" },
		{ "XCURSOR_THEME", "Adwaita" },
		{ "XCURSOR_SIZE", "24" },
		{ "COLORTERM", "truecolor" },
		{ "GDK_BACKEND", "wayland,x11" },
		{ "SDL_VIDEODRIVER", "wayland" },
		{ "CLUTTER_BACKEND", "wayland" },
		{ "LIBVA_DRIVER_NAME", "nvidia" },
		{ "__GLX_VENDOR_LIBRARY_NAME", "nvidia" },
		{ "NVD_BACKEND", "direct" },
		{ "GTK_IM_MODULE", "fcitx" },
		{ "QT_IM_MODULE", "fcitx" },
		{ "XMODIFIERS", "@im=fcitx" },
	}) do
		hl.env(variable[1], variable[2])
	end
end

return M
