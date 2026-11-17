-- Application Launcher Module
-- Registers hotkeys for launching/toggling applications

local apps = {}

-- Window switcher instance
local switcher = nil

--- Initialize app launcher hotkeys
--- @param config table Configuration table with hyper key and app launchers
--- @param helpers table Helper functions
function apps.init(config, helpers)
	-- App launchers (Hyper + key to toggle specific app)
	for _, launcher in ipairs(config.appLaunchers) do
		hs.hotkey.bind(config.hyper, launcher.key, function()
			helpers.toggleApp(launcher.app, launcher.position)
		end)
	end

	-- Window switcher with UI (sorted by last focused)
	if config.appCycleKey then
		apps.setupSwitcher(config)
	end
end

local SWITCHER_RETRY_DELAY = 5
local SWITCHER_MAX_ATTEMPTS = 6

--- Build the window switcher. Retries on failure because hs.window.filter
--- loads hs.spaces, which errors if the Dock cannot be found yet right after login.
--- @param config table Configuration table
--- @param attempt number|nil Current attempt (1-based)
function apps.setupSwitcher(config, attempt)
	attempt = attempt or 1
	local ok, err = pcall(function()
		-- Create window filter for standard windows in current space
		local filter = hs.window.filter.new()
			:setCurrentSpace(true)
			:setDefaultFilter({})

		local s = hs.window.switcher.new(filter)

		-- Customize UI appearance
		s.ui.onlyActiveApplication = false
		s.ui.showTitles = true
		s.ui.showThumbnails = true
		s.ui.thumbnailSize = 128
		s.ui.showSelectedThumbnail = false
		s.ui.textSize = 12
		s.ui.backgroundColor = { 0.2, 0.2, 0.2, 0.9 }
		s.ui.highlightColor = { 0.4, 0.6, 0.9, 0.8 }

		switcher = s
	end)

	if not ok then
		if attempt < SWITCHER_MAX_ATTEMPTS then
			print(string.format("apps: window switcher setup failed (attempt %d), retrying in %ds: %s",
				attempt, SWITCHER_RETRY_DELAY, err))
			hs.timer.doAfter(SWITCHER_RETRY_DELAY, function()
				apps.setupSwitcher(config, attempt + 1)
			end)
		else
			print(string.format("apps: window switcher setup gave up after %d attempts: %s", attempt, err))
		end
		return
	end

	-- Bind hotkeys
	hs.hotkey.bind(config.hyper, config.appCycleKey, function()
		switcher:next()
	end)

	-- Optional: reverse cycle
	if config.appCycleKeyReverse then
		hs.hotkey.bind(config.hyper, config.appCycleKeyReverse, function()
			switcher:previous()
		end)
	end
end

return apps
