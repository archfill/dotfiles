-- dアニメ playback popup avoidance
--
-- Tracks a browser playback popup and moves it to the least-overlapping
-- corner when the focused window changes or is resized.

local pipAvoidance = {}

local settings = {}
local helpers = {}
local enabled = false

local targetWindow = nil
local targetWindowID = nil
local lastAvoidWindow = nil
local targetBorder = nil
local borderSyncTimer = nil
local lastBorderFrame = nil
local borderVisible = false
local repositionTimer = nil
local windowFilter = nil
local scheduleReposition

-- Newly-created browser windows are kept briefly so a title that is populated
-- asynchronously can still be used for auto-detection.
local pendingAutoDetect = {}
local pendingAutoDetectTimers = {}

local defaultBrowserApps = {
	"Safari",
	"Safari Technology Preview",
	"Google Chrome",
	"Brave Browser",
	"Microsoft Edge",
	"Firefox",
	"Arc",
	"Vivaldi",
}

local defaultTitlePatterns = {
	"dアニメストア",
	"dアニメ",
	"animestore",
}

local defaultCornerOrder = {
	"topRight",
	"topLeft",
	"bottomRight",
	"bottomLeft",
}

local function safeCall(callback, fallback)
	local ok, value = pcall(callback)
	if ok then
		return value
	end
	return fallback
end

local function windowID(win)
	if not win then
		return nil
	end
	return safeCall(function()
		return win:id()
	end)
end

local function windowTitle(win)
	return safeCall(function()
		return win:title() or ""
	end, "")
end

local function applicationName(win)
	local app = safeCall(function()
		return win:application()
	end)
	if not app then
		return ""
	end
	return safeCall(function()
		return app:name() or ""
	end, "")
end

local function isVisible(win)
	return safeCall(function()
		return win:isVisible()
	end, false)
end

local function isMinimized(win)
	return safeCall(function()
		return win:isMinimized()
	end, false)
end

local function rectArea(rect)
	if not rect or not rect.w or not rect.h then
		return 0
	end
	return math.max(0, rect.w) * math.max(0, rect.h)
end

local function intersectionArea(first, second)
	if not first or not second then
		return 0
	end

	local left = math.max(first.x, second.x)
	local top = math.max(first.y, second.y)
	local right = math.min(first.x + first.w, second.x + second.w)
	local bottom = math.min(first.y + first.h, second.y + second.h)

	return math.max(0, right - left) * math.max(0, bottom - top)
end

local function topLeftDistance(first, second)
	if not first or not second then
		return math.huge
	end

	local dx = first.x - second.x
	local dy = first.y - second.y
	return math.sqrt(dx * dx + dy * dy)
end

local function buildSet(values)
	local result = {}
	for _, value in ipairs(values or {}) do
		result[value] = true
	end
	return result
end

local browserAppSet = {}

local function isBrowserApp(appName)
	return browserAppSet[appName] == true
end

local function matchesTitle(title)
	local lowerTitle = string.lower(title or "")
	for _, pattern in ipairs(settings.titlePatterns or defaultTitlePatterns) do
		if string.find(title, pattern, 1, true) then
			return true
		end

		if string.find(lowerTitle, string.lower(pattern), 1, true) then
			return true
		end
	end
	return false
end

local function isTargetWindow(win)
	local id = windowID(win)
	return id ~= nil and targetWindowID ~= nil and id == targetWindowID
end

local function showAlert(message)
	if helpers and helpers.alert then
		helpers.alert(message)
	end
end

local function stopBorderSyncTimer()
	if borderSyncTimer then
		safeCall(function()
			borderSyncTimer:stop()
		end)
		borderSyncTimer = nil
	end
end

local function hideTargetBorder()
	if targetBorder then
		safeCall(function()
			targetBorder:hide()
		end)
	end
	borderVisible = false
end

local function sameFrame(first, second)
	if not first or not second then
		return false
	end

	return math.abs(first.x - second.x) < 0.5
		and math.abs(first.y - second.y) < 0.5
		and math.abs(first.w - second.w) < 0.5
		and math.abs(first.h - second.h) < 0.5
end

local function borderElement(frame)
	local border = settings.border or {}
	local inset = math.max(0, border.inset or 2)
	local radius = math.max(0, border.radius or 6)
	local width = math.max(1, border.width or 3)

	return {
		type = "rectangle",
		action = "stroke",
		strokeColor = border.color or {
			red = 0.15,
			green = 0.85,
			blue = 1.0,
			alpha = 0.95,
		},
		strokeWidth = width,
		roundedRectRadii = {
			xRadius = radius,
			yRadius = radius,
		},
		frame = {
			x = inset,
			y = inset,
			w = math.max(1, frame.w - inset * 2),
			h = math.max(1, frame.h - inset * 2),
		},
	}
end

local function updateTargetBorder(frame)
	local border = settings.border or {}
	if border.enabled == false or not targetWindowID then
		hideTargetBorder()
		return
	end

	if not targetWindow or not isVisible(targetWindow) or isMinimized(targetWindow) then
		hideTargetBorder()
		return
	end

	frame = frame or safeCall(function()
		return targetWindow:frame()
	end)
	if not frame then
		hideTargetBorder()
		return
	end

	if not targetBorder then
		targetBorder = safeCall(function()
			return hs.canvas.new(frame)
		end)
		if not targetBorder then
			return
		end

		safeCall(function()
			targetBorder:level(border.level or "floating")
			-- The outline is visual-only; do not let it activate Hammerspoon or
			-- register mouse callbacks over the playback controls.
			targetBorder:clickActivating(false)
			targetBorder:mouseCallback(nil)
		end)
	end

	local frameChanged = not sameFrame(frame, lastBorderFrame)
	safeCall(function()
		if frameChanged then
			targetBorder:frame(frame)
			targetBorder:replaceElements({ borderElement(frame) })
		end
		if not borderVisible then
			targetBorder:show()
			-- Keep the outline above the playback window without making it clickable.
			targetBorder:bringToFront(false)
		end
	end)
	lastBorderFrame = {
		x = frame.x,
		y = frame.y,
		w = frame.w,
		h = frame.h,
	}
	borderVisible = true
end

local function startBorderSyncTimer()
	stopBorderSyncTimer()
	local border = settings.border or {}
	if border.enabled == false or not targetWindowID then
		return
	end

	borderSyncTimer = safeCall(function()
		return hs.timer.doEvery(border.syncInterval or (1 / 60), function()
			updateTargetBorder()
		end)
	end)
end

local function stopRepositionTimer()
	if repositionTimer then
		safeCall(function()
			repositionTimer:stop()
		end)
		repositionTimer = nil
	end
end

local function clearTarget(message)
	stopRepositionTimer()
	stopBorderSyncTimer()
	hideTargetBorder()
	targetWindow = nil
	targetWindowID = nil
	lastAvoidWindow = nil
	lastBorderFrame = nil
	if message then
		showAlert(message)
	end
end

local function registerWindow(win, source)
	local id = windowID(win)
	if not id then
		return false
	end

	targetWindow = win
	targetWindowID = id

	local appName = applicationName(win)
	local title = windowTitle(win)
	local label = title ~= "" and title or appName
	local suffix = source == "auto" and " (自動検出)" or ""
	showAlert("dアニメ再生ウィンドウを登録: " .. label .. suffix)
	updateTargetBorder()
	startBorderSyncTimer()

	local focused = safeCall(function()
		return hs.window.focusedWindow()
	end)
	if focused and not isTargetWindow(focused) then
		lastAvoidWindow = focused
		scheduleReposition()
	end

	return true
end


local function toggleTargetRegistration()
	if targetWindowID then
		clearTarget("dアニメ再生ウィンドウの登録を解除")
		return
	end

	local focused = safeCall(function()
		return hs.window.focusedWindow()
	end)
	if not focused then
		showAlert("登録できるフォーカス中のウィンドウがありません")
		return
	end

	registerWindow(focused, "manual")
end

local function toggleEnabled()
	enabled = not enabled
	if not enabled then
		stopRepositionTimer()
	end

	showAlert(enabled and "dアニメ自動退避: ON" or "dアニメ自動退避: OFF")
	if enabled then
		-- Re-evaluate immediately after re-enabling if a target is registered.
		local focused = safeCall(function()
			return hs.window.focusedWindow()
		end)
		if focused and not isTargetWindow(focused) then
			lastAvoidWindow = focused
			scheduleReposition()
		end
	end
end

local function visibleScreenFrame(screen)
	local frame = safeCall(function()
		return screen:visibleFrame()
	end)
	if frame then
		return frame
	end
	return safeCall(function()
		return screen:frame()
	end)
end

local function cornerFrames(screen, currentFrame)
	local visible = visibleScreenFrame(screen)
	if not visible or not currentFrame then
		return {}
	end

	local inset = settings.inset or 16
	local width = math.min(currentFrame.w, math.max(1, visible.w - inset * 2))
	local height = math.min(currentFrame.h, math.max(1, visible.h - inset * 2))

	local xLeft = visible.x + inset
	local xRight = visible.x + visible.w - inset - width
	local yTop = visible.y + inset
	local yBottom = visible.y + visible.h - inset - height

	local frames = {
		topLeft = { x = xLeft, y = yTop, w = width, h = height },
		topRight = { x = xRight, y = yTop, w = width, h = height },
		bottomLeft = { x = xLeft, y = yBottom, w = width, h = height },
		bottomRight = { x = xRight, y = yBottom, w = width, h = height },
	}

	return frames
end

local function raiseTargetWindow(win)
	if not settings.raiseTarget then
		return
	end

	safeCall(function()
		-- raise() does not request keyboard focus.
		win:raise()
	end)
end

local function currentAvoidWindow()
	local focused = safeCall(function()
		return hs.window.focusedWindow()
	end)
	if focused and not isTargetWindow(focused) then
		return focused
	end

	if lastAvoidWindow and not isTargetWindow(lastAvoidWindow) and isVisible(lastAvoidWindow) then
		return lastAvoidWindow
	end

	return nil
end

local function chooseBestCorner(currentFrame, avoidFrame, frames)
	local best = nil
	local currentOverlap = intersectionArea(currentFrame, avoidFrame)
	local cornerOrder = settings.cornerOrder or defaultCornerOrder
	local preferredVerticalPosition = settings.preferredVerticalPosition
	if preferredVerticalPosition == "top" or preferredVerticalPosition == "bottom" then
		local preferredOrder = {}
		local otherOrder = {}
		for _, name in ipairs(cornerOrder) do
			local isPreferred = preferredVerticalPosition == "top"
				and (name == "topLeft" or name == "topRight")
				or preferredVerticalPosition == "bottom"
				and (name == "bottomLeft" or name == "bottomRight")
			if isPreferred then
				table.insert(preferredOrder, name)
			else
				table.insert(otherOrder, name)
			end
		end
		for _, name in ipairs(otherOrder) do
			table.insert(preferredOrder, name)
		end
		cornerOrder = preferredOrder
	end

	for order, name in ipairs(cornerOrder) do
		local candidateFrame = frames[name]
		if candidateFrame then
			local overlap = intersectionArea(candidateFrame, avoidFrame)
			local distance = topLeftDistance(candidateFrame, currentFrame)

			if not best
				or overlap < best.overlap - 1
				or (math.abs(overlap - best.overlap) <= 1 and order < best.order)
				or (math.abs(overlap - best.overlap) <= 1 and order == best.order and distance < best.distance) then
				best = {
					name = name,
					frame = candidateFrame,
					overlap = overlap,
					distance = distance,
					order = order,
				}
			end
		end
	end

	return best, currentOverlap
end

local function reposition()
	if not enabled or not targetWindow or not targetWindowID then
		return
	end

	if not isVisible(targetWindow) or isMinimized(targetWindow) then
		hideTargetBorder()
		return
	end

	local avoidWindow = currentAvoidWindow()
	if not avoidWindow or isTargetWindow(avoidWindow) then
		return
	end

	local currentFrame = safeCall(function()
		return targetWindow:frame()
	end)
	local avoidFrame = safeCall(function()
		return avoidWindow:frame()
	end)
	local screen = safeCall(function()
		return targetWindow:screen()
	end)
	if not currentFrame or not avoidFrame or not screen then
		updateTargetBorder(currentFrame)
		return
	end

	raiseTargetWindow(targetWindow)
	updateTargetBorder(currentFrame)

	local targetArea = rectArea(currentFrame)
	if targetArea <= 0 then
		return
	end

	local best, currentOverlap = chooseBestCorner(
		currentFrame,
		avoidFrame,
		cornerFrames(screen, currentFrame)
	)
	if not best then
		return
	end

	local overlapThreshold = targetArea * (settings.minOverlapRatio or 0.08)
	if currentOverlap <= overlapThreshold then
		return
	end

	local minimumImprovement = targetArea * (settings.minImprovementRatio or 0.05)
	if currentOverlap - best.overlap < minimumImprovement then
		return
	end

	local minimumMove = settings.minMoveDistance or 8
	if best.distance < minimumMove then
		return
	end

	safeCall(function()
		targetWindow:setFrame(best.frame, settings.animationDuration or 0.2)
	end)
end

scheduleReposition = function()
	if not enabled or not targetWindowID then
		return
	end

	stopRepositionTimer()
	repositionTimer = hs.timer.doAfter(settings.debounce or 0.5, function()
		repositionTimer = nil
		reposition()
	end)
end

local function cancelAutoDetectTimer(id)
	local timer = pendingAutoDetectTimers[id]
	if timer then
		safeCall(function()
			timer:stop()
		end)
	end
	pendingAutoDetectTimers[id] = nil
	pendingAutoDetect[id] = nil
end

local function tryAutoRegister(win)
	if not enabled or not settings.autoDetect or targetWindowID then
		return
	end

	local id = windowID(win)
	if not id or not pendingAutoDetect[id] then
		return
	end

	local appName = applicationName(win)
	if not isBrowserApp(appName) or not matchesTitle(windowTitle(win)) then
		return
	end

	cancelAutoDetectTimer(id)
	registerWindow(win, "auto")
end

local function markForAutoDetect(win)
	if not enabled or not settings.autoDetect then
		return
	end

	local id = windowID(win)
	if not id or not isBrowserApp(applicationName(win)) then
		return
	end

	pendingAutoDetect[id] = true
	tryAutoRegister(win)

	if pendingAutoDetect[id] then
		pendingAutoDetectTimers[id] = hs.timer.doAfter(5, function()
			cancelAutoDetectTimer(id)
		end)

		-- Browser popups can receive their title shortly after creation.
		hs.timer.doAfter(0.25, function()
			if pendingAutoDetect[id] then
				tryAutoRegister(win)
			end
		end)
	end
end

local function focusedWindowIs(win)
	local focused = safeCall(function()
		return hs.window.focusedWindow()
	end)
	return focused and windowID(focused) == windowID(win)
end

local function handleWindowEvent(win, appName, event)
	local id = windowID(win)
	if not id then
		return
	end

	if event == hs.window.filter.windowCreated then
		markForAutoDetect(win)
		return
	end

	if event == hs.window.filter.windowTitleChanged then
		if pendingAutoDetect[id] then
			tryAutoRegister(win)
		end
		return
	end

	if event == hs.window.filter.windowDestroyed then
		if id == targetWindowID then
			clearTarget("dアニメ再生ウィンドウを閉じました")
		else
			cancelAutoDetectTimer(id)
		end
		return
	end

	if isTargetWindow(win) then
		updateTargetBorder()
		return
	end

	if event == hs.window.filter.windowFocused then
		lastAvoidWindow = win
		scheduleReposition()
	elseif event == hs.window.filter.windowMoved and focusedWindowIs(win) then
		lastAvoidWindow = win
		scheduleReposition()
	end
end

function pipAvoidance.init(config, helperModule)
	settings = config.pipAvoidance or {}
	helpers = helperModule or {}
	enabled = settings.enabled ~= false

	browserAppSet = buildSet(settings.browserApps or defaultBrowserApps)
	settings.titlePatterns = settings.titlePatterns or defaultTitlePatterns
	settings.cornerOrder = settings.cornerOrder or defaultCornerOrder

	if not enabled then
		return
	end

	windowFilter = hs.window.filter.new(true)
	windowFilter:subscribe({
		[hs.window.filter.windowCreated] = handleWindowEvent,
		[hs.window.filter.windowTitleChanged] = handleWindowEvent,
		[hs.window.filter.windowDestroyed] = handleWindowEvent,
		[hs.window.filter.windowFocused] = handleWindowEvent,
		[hs.window.filter.windowMoved] = handleWindowEvent,
		[hs.window.filter.windowHidden] = handleWindowEvent,
		[hs.window.filter.windowMinimized] = handleWindowEvent,
		[hs.window.filter.windowUnhidden] = handleWindowEvent,
		[hs.window.filter.windowUnminimized] = handleWindowEvent,
		[hs.window.filter.windowVisible] = handleWindowEvent,
		[hs.window.filter.windowNotVisible] = handleWindowEvent,
	})

	hs.hotkey.bind(config.hyper, settings.registerKey or "o", toggleTargetRegistration)
	hs.hotkey.bind(config.hyper, settings.toggleKey or "i", toggleEnabled)
end

return pipAvoidance
