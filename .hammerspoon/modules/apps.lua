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
	local cycleKey = config.appCycleKey
	if cycleKey then
		-- Create window filter for standard windows in current space
		local filter = hs.window.filter.new()
			:setCurrentSpace(true)
			:setDefaultFilter({})

		-- Create switcher
		switcher = hs.window.switcher.new(filter)

		-- Customize UI appearance
		switcher.ui.onlyActiveApplication = false
		switcher.ui.showTitles = true
		switcher.ui.showThumbnails = true
		switcher.ui.thumbnailSize = 128
		switcher.ui.showSelectedThumbnail = false
		switcher.ui.textSize = 12
		switcher.ui.backgroundColor = { 0.2, 0.2, 0.2, 0.9 }
		switcher.ui.highlightColor = { 0.4, 0.6, 0.9, 0.8 }

		-- Bind hotkeys
		hs.hotkey.bind(config.hyper, cycleKey, function()
			switcher:next()
		end)

		-- Optional: reverse cycle
		if config.appCycleKeyReverse then
			hs.hotkey.bind(config.hyper, config.appCycleKeyReverse, function()
				switcher:previous()
			end)
		end
	end
end

return apps
