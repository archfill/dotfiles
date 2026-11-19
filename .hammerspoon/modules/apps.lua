-- Application Launcher Module
-- Registers hotkeys for launching/toggling applications

local keymap = require("modules.keymap")

local apps = {}

-- Window switcher instance
local switcher = nil

--- Initialize app launcher hotkeys
--- @param config table Configuration table with hyper key and app launchers
--- @param helpers table Helper functions
function apps.init(config, helpers)
	-- App launchers (Hyper + key to toggle specific app)
	for _, launcher in ipairs(config.appLaunchers) do
		keymap.bind(config.hyper, launcher.key, {
			category = keymap.categories.apps,
			description = launcher.app .. " を開く・隠す",
		}, function()
			helpers.toggleApp(launcher.app, launcher.position)
		end)
	end

	-- Alfred's clipboard history: handled outside Hammerspoon, shown only
	keymap.add({
		category = keymap.categories.other,
		label = keymap.formatLabel(config.hyper, "v"),
		description = "クリップボードの履歴（Alfred）",
	})

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
		-- Create window filter for standard windows in current space.
		-- Only AXStandardWindow: notification banners and widgets
		-- (com.apple.notificationcenterui) and menu bar panels are excluded.
		local filter = hs.window.filter.new()
			:setCurrentSpace(true)
			:setDefaultFilter({ allowRoles = "AXStandardWindow" })

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
	-- Display only: hs.window.switcher decides when the modifiers are released,
	-- so it cannot be called from the cheatsheet
	keymap.bind(config.hyper, config.appCycleKey, {
		category = keymap.categories.move,
		description = "ウィンドウを切り替える",
		runnable = false,
	}, function()
		-- The switcher focuses the window when Hyper is released
		require("modules.windows").moveMouseOnNextFocus()
		switcher:next()
	end)

	-- Optional: reverse cycle
	if config.appCycleKeyReverse then
		keymap.bind(config.hyper, config.appCycleKeyReverse, {
			category = keymap.categories.move,
			description = "ウィンドウを逆順に切り替える",
			runnable = false,
		}, function()
			require("modules.windows").moveMouseOnNextFocus()
			switcher:previous()
		end)
	end
end

return apps
