-- ================================================================
-- NEOVIM PLUGIN KEYMAPS - PERFORMANCE OPTIMIZED
-- ================================================================
-- パフォーマンス最優先でプラグイン別にキーマップを最適化
-- Category A: keys設定（完全遅延読み込み）
-- Category B: 設定ファイル管理（複雑な処理）
-- Category C: ハイブリッド（基本はkeys、複雑部分は設定ファイル）
-- ================================================================

local M = {}

-- ================================================================
-- CATEGORY A: FULL KEYS OPTIMIZATION (完全遅延読み込み)
-- ================================================================

-- Neo-tree: ファイルエクスプローラー
-- シンプルなコマンド実行のため keys が最適
M.neo_tree = {
	{ "<leader>e", "<cmd>Neotree position=float reveal toggle<cr>", desc = "Toggle Neo-tree (float)" },
}

-- Telescope: ファジーファインダー
-- 高頻度使用、即座に動作すべきため keys が最適
M.telescope = {
	-- File operations
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
	{ "<leader>fd", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find Files (including hidden)" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
	{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
	{ "<leader>fm", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
	{ "<leader>-", "<cmd>Telescope command_history<cr>", desc = "Command History" },

	-- Git operations
	{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
	{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
	{ "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Git Buffer Commits" },
	{ "<leader>gv", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
}

-- Conform: フォーマッター
-- フォーマット処理、即座に実行したいため keys が最適
M.conform = {
	{
		"<leader>mp",
		function()
			require("conform").format({ async = true, lsp_fallback = true })
		end,
		mode = { "n", "v" },
		desc = "Format file or range",
	},
}

-- Notify: 通知管理
-- 通知管理、シンプルなため keys が最適
M.nvim_notify = {
	{
		"<leader>nc",
		function()
			require("notify").dismiss({ silent = true, pending = true })
		end,
		desc = "Clear notifications",
	},
}

-- Possession: セッション管理
-- セッション操作、即座に動作すべきため keys が最適
M.possession = {
	{ "<leader>sl", "<cmd>PossessionLoad<cr>", desc = "Load session" },
	{ "<leader>ss", "<cmd>PossessionSave<cr>", desc = "Save session" },
	{ "<leader>sd", "<cmd>PossessionDelete<cr>", desc = "Delete session" },
	{ "<leader>sc", "<cmd>PossessionClose<cr>", desc = "Close session" },
}

-- Telekasten: メモシステム
-- メモ操作、即座に動作すべきため keys が最適
M.telekasten = {
	{ "<leader>zf", "<cmd>Telekasten find_notes<cr>", desc = "Find notes" },
	{ "<leader>zd", "<cmd>Telekasten find_daily_notes<cr>", desc = "Find daily notes" },
	{ "<leader>zg", "<cmd>Telekasten search_notes<cr>", desc = "Search notes" },
	{ "<leader>zt", "<cmd>Telekasten goto_today<cr>", desc = "Go to today" },
	{ "<leader>zc", "<cmd>Telekasten show_calendar<cr>", desc = "Show calendar" },
	{ "<leader>zi", "<cmd>Telekasten paste_img_and_link<cr>", desc = "Paste image" },
	{ "<leader>zI", "<cmd>Telekasten insert_img_link<cr>", desc = "Insert image link" },
	{ "<leader>zt", "<cmd>Telekasten toggle_todo<cr>", desc = "Toggle todo" },
	{ "<leader>zb", "<cmd>Telekasten show_backlinks<cr>", desc = "Show backlinks" },
	{ "<leader>zF", "<cmd>Telekasten find_friends<cr>", desc = "Find friends" },
}

-- ================================================================
-- CATEGORY B: CONFIG FILE OPTIMIZATION (設定ファイルで管理)
-- ================================================================

-- nvim-cmp: 複雑な条件分岐とコンテキスト依存のため設定ファイルが最適
-- → pluginconfig/editor/nvim-cmp.lua で管理

-- nvim-treesitter: 初期化とハイライト設定が必要なため設定ファイルが最適
-- → pluginconfig/editor/nvim-treesitter.lua で管理

-- Comment.nvim: treesitter連携と複雑な判定処理のため設定ファイルが最適
-- → pluginconfig/editor/Comment.lua で管理

-- ================================================================
-- CATEGORY C: HYBRID OPTIMIZATION (ハイブリッド)
-- ================================================================

-- LSP: 基本操作は keys、複雑な設定は初期化後
M.lspconfig_basic = {
	-- Navigation (即座に動作すべき基本操作)
	{ "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go to Definition" },
	{ "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Go to Declaration" },
	{ "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Go to Implementation" },
	{ "gr", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "Show References" },

	-- Diagnostics (競合解決済み: eからdに変更)
	{ "<leader>d", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Show Diagnostics" },
	{ "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Diagnostics to LocList" },
	{ "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Previous Diagnostic" },
	{ "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic" },

	-- Actions
	{ "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
	{ "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename Symbol" },
	{ "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", mode = "i", desc = "Signature Help" },
}
-- 複雑なLSP設定は pluginconfig/lsp/nvim-lspconfig.lua で管理

-- nvim-cokeline: 基本バッファ操作は keys、複雑な表示設定は初期化後
M.nvim_cokeline_basic = {
	{
		"x",
		function()
			local current_buf = vim.api.nvim_get_current_buf()
			vim.cmd("bdelete " .. current_buf)
		end,
		desc = "Close current buffer",
	},
	{ "H", "<cmd>bprevious<cr>", desc = "Previous buffer" },
	{ "L", "<cmd>bnext<cr>", desc = "Next buffer" },
	{
		"<leader>bd",
		function()
			local current_buf = vim.api.nvim_get_current_buf()
			vim.cmd("bdelete " .. current_buf)
		end,
		desc = "Delete buffer",
	},
	{ "<leader>bo", "<cmd>%bd|e#|bd#<cr>", desc = "Close other buffers" },
	{
		"<S-Left>",
		function()
			require("nvim-cokeline.api").move_buffer(-1)
		end,
		desc = "Move buffer left",
	},
	{
		"<S-Right>",
		function()
			require("nvim-cokeline.api").move_buffer(1)
		end,
		desc = "Move buffer right",
	},

	-- Buffer number navigation
	{
		"<leader>1",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 1",
	},
	{
		"<leader>2",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 2",
	},
	{
		"<leader>3",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 3",
	},
	{
		"<leader>4",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 4",
	},
	{
		"<leader>5",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 5",
	},
	{
		"<leader>6",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 6",
	},
	{
		"<leader>7",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 7",
	},
	{
		"<leader>8",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 8",
	},
	{
		"<leader>9",
		function()
			require("nvim-cokeline.api").pick("focus")
		end,
		desc = "Focus buffer 9",
	},
}
-- 複雑な表示設定とAPI操作は pluginconfig/ui/nvim-cokeline.lua で管理

-- which-key: 説明表示のみなので設定ファイルが最適
-- → pluginconfig/ui/which-key.lua で管理

-- ================================================================
-- UTILITIES
-- ================================================================

-- プラグイン別キーマップ取得
function M.get_plugin_keys(plugin_name)
	return M[plugin_name] or {}
end

-- 全キーマップ一覧表示（デバッグ用）
function M.list_all_keys()
	local all_keys = {}
	for plugin, keymaps in pairs(M) do
		if type(keymaps) == "table" and plugin ~= "get_plugin_keys" and plugin ~= "list_all_keys" then
			all_keys[plugin] = keymaps
		end
	end
	return all_keys
end

-- キーマップ統計情報
function M.get_stats()
	local stats = {
		total_plugins = 0,
		total_keymaps = 0,
		category_a = 0, -- keys設定
		category_b = 0, -- 設定ファイル管理
		category_c = 0, -- ハイブリッド
	}

	for plugin, keymaps in pairs(M) do
		if
			type(keymaps) == "table"
			and plugin ~= "get_plugin_keys"
			and plugin ~= "list_all_keys"
			and plugin ~= "get_stats"
		then
			stats.total_plugins = stats.total_plugins + 1
			stats.total_keymaps = stats.total_keymaps + #keymaps

			-- カテゴリ分類
			if plugin:match("_basic$") then
				stats.category_c = stats.category_c + 1
			elseif plugin == "nvim_cmp" or plugin == "nvim_treesitter" or plugin == "comment_nvim" then
				stats.category_b = stats.category_b + 1
			else
				stats.category_a = stats.category_a + 1
			end
		end
	end

	return stats
end

return M

