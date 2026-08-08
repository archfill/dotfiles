local M = {}

function M.apply()
	local monitors_ok, monitors = pcall(require, "monitors")
	if not monitors_ok then
		if not tostring(monitors):match("module 'monitors' not found") then
			error(monitors)
		end
		return
	end

	for _, monitor in ipairs(monitors.monitors or {}) do
		hl.monitor(monitor)
	end

	for _, group in ipairs(monitors.workspace_groups or {}) do
		for workspace = group.first, group.last do
			hl.workspace_rule({ workspace = tostring(workspace), monitor = group.monitor })
		end
	end

	for _, rule in ipairs(monitors.window_rules or {}) do
		hl.window_rule(rule)
	end

	if monitors.cursor_default_monitor then
		hl.config({ cursor = { default_monitor = monitors.cursor_default_monitor } })
	end
end

return M
