-- alpha.nvim configuration
-- モダンで美しいスタートスクリーン

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- ヘッダーアート
dashboard.section.header.val = {
	"                                                        ",
	"    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
	"    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
	"    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
	"    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
	"                                                        ",
	"           🚀 Welcome to Neovim Development Environment ",
	"",
}

-- メニューボタン
dashboard.section.buttons.val = {
	-- ファイル操作
	dashboard.button("f", "📁  Find File", ":Telescope find_files <CR>"),
	dashboard.button("g", "🔍  Live Grep", ":Telescope live_grep <CR>"),
	dashboard.button("r", "📄  Recent Files", ":Telescope oldfiles <CR>"),
	dashboard.button("n", "✏️   New File", ":ene <BAR> startinsert <CR>"),
	dashboard.button("e", "📂  File Explorer", ":Neotree <CR>"),
	-- セッション管理
	dashboard.button("S", "💾  Save Session", ":PossessionSave <CR>"),
	dashboard.button("R", "🔄  Load Session", ":PossessionLoad <CR>"),
	dashboard.button("D", "🗑️   Delete Session", ":PossessionDelete <CR>"),
	dashboard.button("T", "📋  Show Sessions", ":PossessionShow <CR>"),
	-- 設定
	dashboard.button("c", "⚙️   Edit Config", ":edit ~/.config/nvim/init.lua <CR>"),
	dashboard.button("p", "🔌  Edit Plugins", ":edit ~/.config/nvim/lua/plugins.lua <CR>"),
	-- Lazy.nvim Plugin Management
	dashboard.button("l", "💤  Lazy Home", ":Lazy <CR>"),
	dashboard.button("s", "🔄  Sync Plugins", ":Lazy sync <CR>"),
	dashboard.button("u", "⬆️   Update Plugins", ":Lazy update <CR>"),
	dashboard.button("i", "⬇️   Install Plugins", ":Lazy install <CR>"),
	dashboard.button("x", "🧹  Clean Plugins", ":Lazy clean <CR>"),
	dashboard.button("P", "📊  Plugin Profile", ":Lazy profile <CR>"),
	dashboard.button("L", "📜  Plugin Log", ":Lazy log <CR>"),
	-- 終了
	dashboard.button("q", "🚪  Quit Neovim", ":qa <CR>"),
}

-- フッター
dashboard.section.footer.val = function()
	local stats = require("lazy").stats()
	local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
	return {
		"",
		"⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
		"",
		"📚 Happy Coding! 🎉",
	}
end

-- レイアウト
dashboard.config.layout = {
	{ type = "padding", val = 2 },
	dashboard.section.header,
	{ type = "padding", val = 2 },
	dashboard.section.buttons,
	{ type = "padding", val = 1 },
	dashboard.section.footer,
}

-- 無効にするデフォルトのhl
dashboard.section.header.opts.hl = "AlphaHeader"
dashboard.section.buttons.opts.hl = "AlphaButtons"
dashboard.section.footer.opts.hl = "AlphaFooter"

-- セットアップ
alpha.setup(dashboard.config)

-- hjklキーバインド
vim.api.nvim_create_autocmd("FileType", {
	pattern = "alpha",
	callback = function()
		local opts = { buffer = true, silent = true }
		vim.keymap.set('n', 'h', 'h', opts)
		vim.keymap.set('n', 'j', 'j', opts)
		vim.keymap.set('n', 'k', 'k', opts)
		vim.keymap.set('n', 'l', 'l', opts)
	end,
})

-- カラー設定
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7", bold = true })
		vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#9ece6a" })
		vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#565f89", italic = true })
	end,
})