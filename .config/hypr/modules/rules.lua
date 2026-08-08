local M = {}

function M.apply()
	hl.window_rule({ match = { class = "firefox", title = ".*Picture-in-Picture.*" }, float = true })
	hl.window_rule({ match = { class = "com.nextcloud.desktopclient.nextcloud" }, float = true, center = true })
	hl.window_rule({ match = { class = "Nextcloud" }, float = true, center = true })

	for _, app in ipairs({ "1Password", "Prism", "Steam", "Minecraft" }) do
		hl.window_rule({ match = { initial_class = ".*" .. app .. ".*" }, float = true, center = true })
		hl.window_rule({ match = { initial_title = ".*" .. app .. ".*" }, float = true, center = true })
	end

	hl.window_rule({
		match = { class = "looking-glass-client" },
		opacity = "1.0 1.0",
		force_rgbx = true,
		float = true,
		size = { 2560, 1440 },
		center = true,
		workspace = "5",
		fullscreen = true,
	})
end

return M
