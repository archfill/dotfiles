-- Stable color module. Matugen writes the machine-local colors_generated.lua;
-- this file provides the tracked fallback palette when it is unavailable.
local generated_ok, generated_colors = pcall(require, "colors_generated")
if generated_ok then
	return generated_colors
end

local function rgba(hex)
	return "rgba(" .. hex .. ")"
end

return {
	primary = rgba("c2c1ffff"),
	on_primary = rgba("2a2a60ff"),
	primary_container = rgba("414178ff"),
	on_primary_container = rgba("e2dfffff"),
	secondary = rgba("c6c4ddff"),
	on_secondary = rgba("2f2f42ff"),
	secondary_container = rgba("454559ff"),
	on_secondary_container = rgba("e2e0f9ff"),
	tertiary = rgba("e9b9d2ff"),
	on_tertiary = rgba("47263aff"),
	tertiary_container = rgba("5f3c51ff"),
	on_tertiary_container = rgba("ffd8ebff"),
	background = rgba("131318ff"),
	on_background = rgba("e4e1e9ff"),
	surface = rgba("131318ff"),
	on_surface = rgba("e4e1e9ff"),
	surface_variant = rgba("47464faa"),
	on_surface_variant = rgba("c8c5d0ff"),
	outline = rgba("918f9aff"),
	outline_variant = rgba("47464fff"),
	shadow = rgba("000000ff"),
	error = rgba("ffb4abff"),
	on_error = rgba("690005ff"),
	source_color = rgba("c2c1ffff"),
}
