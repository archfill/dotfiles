hs.hotkey.bind({'ctrl', 'shift'}, "k", function()
    local kitty = hs.application.get("kitty")
    if kitty == nil then
        hs.application.launchOrFocus("/Applications/kitty.app")
    elseif kitty:isFrontmost() then
        kitty:hide()
    else
        hs.application.launchOrFocus("/Applications/kitty.app")
    end
end)

hs.hotkey.bind({'ctrl', 'shift'}, "u", function()
    local kitty = hs.application.get("Alacritty")
    if kitty == nil then
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    elseif kitty:isFrontmost() then
        kitty:hide()
    else
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    end
end)
