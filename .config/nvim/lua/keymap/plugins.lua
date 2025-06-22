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

-- Telescope: ファジーファインダー + 高性能拡張
-- 高頻度使用、即座に動作すべきため keys が最適
M.telescope = {
	-- ===== CORE FILE OPERATIONS =====
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
	{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
	{ "<leader>fm", function() require("telescope.builtin").oldfiles() end, desc = "Recent Files" },
	{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Old Files" },

	-- ===== ADVANCED FILE OPERATIONS =====
	{ "<leader>fd", function() require("pluginconfig.tools.telescope").find_dotfiles() end, desc = "Find Dotfiles" },
	{ "<leader>fn", function() require("pluginconfig.tools.telescope").find_nvim_config() end, desc = "Find Neovim Config" },
	{ "<leader>ft", function() require("pluginconfig.tools.telescope").find_project_todos() end, desc = "Find TODOs" },
	{ "<leader>fG", "<cmd>Telescope git_files<cr>", desc = "Git Files" },

	-- ===== CORE EXTENSIONS =====
	{ "<leader>fB", function() require("telescope").extensions.file_browser.file_browser({ path = "%:p:h", select_buffer = true }) end, desc = "File Browser" },
	{ "<leader>fp", function() require("telescope").extensions.project.project({}) end, desc = "Projects" },
	{ "<leader>fs", function() require("telescope").extensions.symbols.symbols() end, desc = "Symbols & Emoji" },
	{ "<leader>fu", function() require("telescope").extensions.undo.undo() end, desc = "Undo Tree" },
	{ "<leader>fH", function() require("telescope").extensions.heading.heading() end, desc = "Document Headings" },

	-- ===== HIGH PRIORITY EXTENSIONS =====
	{ "<leader>fF", function() require("telescope").extensions.frecency.frecency() end, desc = "Frecency Files (Smart)" },
	{ "<leader>fy", function() require("telescope").extensions.yanky.history() end, desc = "Yank History" },
	{ "<leader>fM", function() require("telescope").extensions.media_files.media_files() end, desc = "Media Files" },
	{ "<leader>gx", function() require("telescope").extensions.git_conflicts.conflicts() end, desc = "Git Conflicts" },
	{ "<leader>fX", function() require("telescope").extensions.tabs.list() end, desc = "Tabs" },
	{ "<leader>fC", function() require("telescope").extensions.cmdline.cmdline() end, desc = "Command Line" },
	{ "<leader>fS", function() require("telescope").extensions.session.session() end, desc = "Sessions" },

	-- ===== UTILITY SEARCHES =====
	{ "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Registers" },
	{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
	{ "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
	{ "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jump List" },
	{ "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
	{ "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix" },

	-- ===== COMMAND OPERATIONS =====
	{ "<leader>f:", "<cmd>Telescope commands<cr>", desc = "Commands" },
	{ "<leader>f;", "<cmd>Telescope command_history<cr>", desc = "Command History" },
	{ "<leader>f/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
	{ "<leader>f?", function() require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({})) end, desc = "Buffer Fuzzy Find" },
	{ "<leader>-", "<cmd>Telescope command_history<cr>", desc = "Command History" },

	-- ===== LSP OPERATIONS =====
	{ "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
	{ "<leader>lr", "<cmd>Telescope lsp_references<cr>", desc = "LSP References" },
	{ "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
	{ "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },

	-- ===== GIT OPERATIONS =====
	{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
	{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
	{ "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Git Buffer Commits" },
	{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
	{ "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },

	-- ===== TELESCOPE META =====
	{ "<leader>fT", "<cmd>Telescope builtin<cr>", desc = "Telescope Builtins" },

	-- ===== FLUTTER (if available) =====
	{ "<leader>flc", "<cmd>Telescope flutter commands<cr>", desc = "Flutter Commands" },
	{ "<leader>flv", "<cmd>Telescope flutter fvm<cr>", desc = "Flutter FVM" },
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

