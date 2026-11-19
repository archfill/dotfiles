-- Key Modal Module
-- Shared "Hyper + key, then one more key" modal. Used by modules.groups and
-- the window swap (modules.windows).
--
-- The modal shows a short help alert, exits by itself after a timeout, exits
-- on Esc, and exits when another key is pressed with all four Hyper modifiers
-- (that key still reaches its own binding).

local keymap = require("modules.keymap")

local keymodal = {}

local DEFAULT_TIMEOUT = 1 -- seconds before the modal exits by itself

--- Create a modal entered with hyper + key
--- @param hyper table Hyper modifiers
--- @param key string Key that enters the modal
--- @param helpText string Text shown while the modal is active
--- @param timeout number|nil Seconds before the modal exits by itself
--- @return hs.hotkey.modal modal Has an extra method modal:bindAction(key, fn)
function keymodal.new(hyper, key, helpText, timeout)
	timeout = timeout or DEFAULT_TIMEOUT

	local modal = hs.hotkey.modal.new(hyper, key)
	local modalTimer = nil
	local modalAlert = nil
	local modalTap = nil

	function modal:entered()
		modalAlert = hs.alert.show(helpText, timeout + 1)
		modalTimer = hs.timer.doAfter(timeout, function()
			modal:exit()
		end)
		-- Another Hyper key press leaves the modal and still reaches its own binding
		modalTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
			local flags = event:getFlags()
			if flags.ctrl and flags.cmd and flags.alt and flags.shift then
				hs.timer.doAfter(0, function()
					modal:exit()
				end)
			end
			return false
		end)
		modalTap:start()
	end

	function modal:exited()
		if modalTimer then
			modalTimer:stop()
			modalTimer = nil
		end
		if modalTap then
			modalTap:stop()
			modalTap = nil
		end
		if modalAlert then
			hs.alert.closeSpecific(modalAlert, 0)
			modalAlert = nil
		end
	end

	--- Bind a key inside the modal: exit first, then run fn.
	--- With info ({ category, description }) the key is also recorded for the
	--- cheatsheet as "Hyper + key → actionKey", running fn directly.
	function modal:bindAction(actionKey, fn, info)
		if info then
			keymap.add({
				category = info.category,
				label = keymap.formatLabel(hyper, key, actionKey),
				description = info.description,
				fn = fn,
			})
		end
		self:bind({}, actionKey, function()
			self:exit()
			fn()
		end)
	end

	modal:bind({}, "escape", function()
		modal:exit()
	end)

	return modal
end

return keymodal
