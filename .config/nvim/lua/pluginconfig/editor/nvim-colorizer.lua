-- nvim-colorizer.lua設定
-- 高性能カラーハイライト

local status_ok, colorizer = pcall(require, "colorizer")
if not status_ok then
	return
end

colorizer.setup({
	filetypes = {
		"*", -- 全ファイルタイプでカラー表示を有効
		css = { css = true, css_fn = true }, -- CSS関数も対応
		scss = { css = true, css_fn = true },
		sass = { css = true, css_fn = true },
		javascript = { css = true },
		typescript = { css = true },
		html = { css = true },
		vue = { css = true },
		svelte = { css = true },
		lua = { names = false }, -- Lua色名は無効（パフォーマンス重視）
	},
	user_default_options = {
		RGB = true, -- #RGB hex codes
		RRGGBB = true, -- #RRGGBB hex codes
		names = true, -- "Name" codes like Blue or blue
		RRGGBBAA = true, -- #RRGGBBAA hex codes
		AARRGGBB = false, -- 0xAARRGGBB hex codes
		rgb_fn = true, -- CSS rgb() and rgba() functions
		hsl_fn = true, -- CSS hsl() and hsla() functions
		css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
		css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
		mode = "background", -- Set the display mode (foreground/background/virtualtext)
		tailwind = true, -- Enable tailwind colors
		sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
		virtualtext = "■", -- Virtual text character
		always_update = false, -- パフォーマンス重視で自動更新無効
	},
	buftypes = {}, -- 全バッファタイプで有効
})

-- パフォーマンス向上のための遅延読み込み
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		vim.defer_fn(function()
			require("colorizer").attach_to_buffer(0)
		end, 100)
	end,
})