-- FZF Window Switcher Module
-- Provides fzf-powered window switching using FzfWindowSwitcher Spoon

local fzf = {}

--- Initialize fzf window switcher
--- @param config table Configuration table with hyper key and fzf settings
--- @param helpers table Helper functions
function fzf.init(config, helpers)
	local fzfConfig = config.fzf or {}

	-- Skip if disabled
	if fzfConfig.enabled == false then
		return
	end

	-- Load required Spoons
	local fzfFilterLoaded = pcall(function()
		hs.loadSpoon("FzfFilter")
	end)

	if not fzfFilterLoaded then
		helpers.alert("FzfFilter.spoon not found", 2)
		return
	end

	local fzfSwitcherLoaded = pcall(function()
		hs.loadSpoon("FzfWindowSwitcher")
	end)

	if not fzfSwitcherLoaded then
		helpers.alert("FzfWindowSwitcher.spoon not found", 2)
		return
	end

	-- Configure FzfFilter
	-- The Spoon only auto-detects Homebrew paths, but fzf is installed by Nix
	-- (home-manager), so look in the Nix profiles first.
	local fzfPath = fzfConfig.fzfPath
	if not fzfPath then
		local candidates = {
			"/etc/profiles/per-user/" .. os.getenv("USER") .. "/bin/fzf", -- nix-darwin + home-manager
			os.getenv("HOME") .. "/.nix-profile/bin/fzf", -- standalone home-manager
			"/run/current-system/sw/bin/fzf",
		}
		for _, candidate in ipairs(candidates) do
			if hs.fs.attributes(candidate) then
				fzfPath = candidate
				break
			end
		end
	end
	if fzfPath then
		spoon.FzfFilter.fzfPath = fzfPath
	end

	-- Start FzfFilter (will auto-detect fzf path if not set)
	spoon.FzfFilter:start()

	-- Configure FzfWindowSwitcher options
	if fzfConfig.searchWindowTitles ~= nil then
		spoon.FzfWindowSwitcher.searchWindowTitles = fzfConfig.searchWindowTitles
	end
	if fzfConfig.quickSwitchEnabled ~= nil then
		spoon.FzfWindowSwitcher.quickSwitchEnabled = fzfConfig.quickSwitchEnabled
	end
	if fzfConfig.maxTitleLength then
		spoon.FzfWindowSwitcher.maxTitleLength = fzfConfig.maxTitleLength
	end

	-- Set custom hotkey using Hyper key
	local hotkey = fzfConfig.hotkey or "w"
	spoon.FzfWindowSwitcher.hotkey = { config.hyper, hotkey }

	-- Initialize and start
	spoon.FzfWindowSwitcher:init()
	spoon.FzfWindowSwitcher:start()

	-- Replace the Spoon's show-only hotkey with a toggle (press again to close)
	local switcher = spoon.FzfWindowSwitcher
	if switcher.hotkeyBind then
		switcher.hotkeyBind:delete()
	end
	switcher.hotkeyBind = hs.hotkey.bind(config.hyper, hotkey, function()
		if switcher.windowChooser and switcher.windowChooser:isVisible() then
			switcher.windowChooser:hide()
		else
			switcher:showWindowSwitcher()
		end
	end)
end

return fzf
