-- nvim-cokeline設定
-- 美しいbufferlineでバッファ管理

local cokeline_ok, cokeline = pcall(require, "cokeline")
if not cokeline_ok then
	vim.notify("nvim-cokeline が見つかりません", vim.log.levels.ERROR)
	return
end

-- トーキョーナイトテーマの色を取得
local colors = {
	bg = "#1a1b26",
	fg = "#c0caf5",
	bg_dark = "#16161e",
	bg_highlight = "#292e42",
	terminal_black = "#414868",
	fg_dark = "#565f89",
	fg_gutter = "#3b4261",
	blue = "#7aa2f7",
	cyan = "#7dcfff",
	blue1 = "#2ac3de",
	blue0 = "#3d59a1",
	blue5 = "#89ddff",
	blue6 = "#b4f9f8",
	blue7 = "#394b70",
	magenta = "#bb9af7",
	magenta2 = "#ff007c",
	purple = "#9d7cd8",
	orange = "#ff9e64",
	yellow = "#e0af68",
	green = "#9ece6a",
	green1 = "#73daca",
	green2 = "#41a6b5",
	teal = "#1abc9c",
	red = "#f7768e",
	red1 = "#db4b4b",
	git = {
		change = "#6183bb",
		add = "#449dab",
		delete = "#914c54",
	},
}

-- ===== COKELINE 美しい設定 =====
cokeline.setup({
	show_if_buffers_are_at_least = 1,

	buffers = {
		-- アクティブでないバッファも表示
		focus_on_delete = "prev",
		-- バッファ削除時の動作
		delete_on_right_click = false, -- 右クリック削除は無効（誤操作防止）
	},

	rendering = {
		-- 最大幅設定
		max_buffer_width = 30,
	},

	default_hl = {
		-- デフォルトハイライト
		fg = function(buffer)
			return buffer.is_focused and colors.fg or colors.fg_dark
		end,
		bg = function(buffer)
			return buffer.is_focused and colors.bg_highlight or colors.bg
		end,
		italic = function(buffer)
			return buffer.is_focused and true or false
		end,
		bold = function(buffer)
			return buffer.is_focused and true or false
		end,
	},

	-- ===== 美しいコンポーネント設定 =====
	components = {
		-- 左パディング
		{
			text = " ",
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
		},

		-- ファイルアイコン
		{
			text = function(buffer)
				local devicons = require("nvim-web-devicons")
				local icon, hl = devicons.get_icon_color(buffer.filename, buffer.filetype)
				return icon and (icon .. " ") or "📄 "
			end,
			fg = function(buffer)
				local devicons = require("nvim-web-devicons")
				local _, hl = devicons.get_icon_color(buffer.filename, buffer.filetype)
				if buffer.is_focused then
					return hl and vim.fn.synIDattr(vim.fn.hlID(hl), "fg") or colors.blue
				else
					return colors.fg_dark
				end
			end,
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
		},

		-- ファイル名
		{
			text = function(buffer)
				local name = buffer.unique_prefix .. buffer.filename
				-- 長いファイル名を短縮
				if #name > 25 then
					name = name:sub(1, 22) .. "..."
				end
				return name
			end,
			fg = function(buffer)
				if buffer.is_modified then
					return buffer.is_focused and colors.orange or colors.yellow
				end
				return buffer.is_focused and colors.fg or colors.fg_dark
			end,
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
			style = function(buffer)
				return buffer.is_focused and "bold" or "NONE"
			end,
		},

		-- 変更インジケーター
		{
			text = function(buffer)
				return buffer.is_modified and " ●" or ""
			end,
			fg = function(buffer)
				return buffer.is_modified and colors.orange or colors.fg_dark
			end,
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
		},

		-- LSP診断インジケーター
		{
			text = function(buffer)
				local diag = vim.diagnostic.get(buffer.number)
				local errors = #vim.tbl_filter(function(d)
					return d.severity == vim.diagnostic.severity.ERROR
				end, diag)
				local warnings = #vim.tbl_filter(function(d)
					return d.severity == vim.diagnostic.severity.WARN
				end, diag)

				if errors > 0 then
					return " 󰅚"
				elseif warnings > 0 then
					return " 󰀪"
				end
				return ""
			end,
			fg = function(buffer)
				local diag = vim.diagnostic.get(buffer.number)
				local errors = #vim.tbl_filter(function(d)
					return d.severity == vim.diagnostic.severity.ERROR
				end, diag)
				local warnings = #vim.tbl_filter(function(d)
					return d.severity == vim.diagnostic.severity.WARN
				end, diag)

				if errors > 0 then
					return colors.red
				elseif warnings > 0 then
					return colors.yellow
				end
				return colors.fg_dark
			end,
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
		},

		-- 閉じるボタン
		{
			text = " 󰅖",
			fg = function(buffer)
				return buffer.is_hovered and colors.red or colors.fg_dark
			end,
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
			on_click = function(_, _, _, _, buffer)
				vim.cmd("bdelete " .. buffer.number)
			end,
		},

		-- 右パディング
		{
			text = " ",
			bg = function(buffer)
				return buffer.is_focused and colors.bg_highlight or colors.bg
			end,
		},

		-- セパレーター
		{
			text = function(buffer, prev_buffer)
				if buffer.is_focused then
					return ""
				elseif prev_buffer and prev_buffer.is_focused then
					return ""
				else
					return "│"
				end
			end,
			fg = function(buffer, prev_buffer)
				if buffer.is_focused then
					return colors.bg_highlight
				elseif prev_buffer and prev_buffer.is_focused then
					return colors.bg_highlight
				else
					return colors.fg_gutter
				end
			end,
			bg = function(buffer, prev_buffer)
				if buffer.is_focused or (prev_buffer and prev_buffer.is_focused) then
					return colors.bg
				else
					return colors.bg
				end
			end,
		},
	},
})

-- キーマップはkeymap/plugins.luaで管理（パフォーマンス最適化）

vim.notify("🎨 nvim-cokeline setup complete!", vim.log.levels.INFO)