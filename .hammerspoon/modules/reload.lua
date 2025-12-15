-- Configuration Reload Module
-- Handles manual and automatic config reloading

local reload = {}

local pathwatcher = nil

--- Initialize reload functionality
--- @param config table Configuration table with settings
--- @param helpers table Helper functions
function reload.init(config, helpers)
	local settings = config.settings
	local hyper = config.hyper

	-- Manual reload hotkey (Hyper + R)
	if settings.reloadKey then
		hs.hotkey.bind(hyper, settings.reloadKey, function()
			hs.reload()
		end)
	end

	-- Auto-reload on config file changes
	if settings.autoReload then
		pathwatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
			reload.doReload(settings, helpers)
		end)
		pathwatcher:start()
	end

	-- Show startup notification
	if settings.showReloadAlert then
		helpers.alert("Hammerspoon loaded", settings.alertDuration)
	end
end

--- Perform config reload
--- @param settings table Settings table
--- @param helpers table Helper functions
function reload.doReload(settings, helpers)
	if pathwatcher then
		pathwatcher:stop()
	end
	hs.reload()
end

return reload
