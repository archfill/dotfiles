local lspsaga = require("lspsaga")
lspsaga.setup({
	-- ===== UI設定（美しい外観） =====
	ui = {
		border = "rounded",                    -- 角丸ボーダー
		winblend = 10,                        -- 10%透明度
		expand = "󰅀",                        -- 展開アイコン
		collapse = "󰅂",                      -- 折りたたみアイコン
		code_action = "💡",                   -- コードアクションアイコン
		actionfix = "🔧",                     -- 修正アクションアイコン
		lines = { "┗", "┣", "┃", "━", "┏" },  -- 美しい罫線
		kind = {},                           -- LSP kindアイコン（デフォルト使用）
	},

	-- ===== コードアクション強化 =====
	code_action = {
		num_shortcut = true,                 -- 数字ショートカット（1,2,3...）
		show_server_name = true,             -- LSPサーバー名表示
		extend_gitsigns = true,              -- gitsigns統合
		keys = {
			quit = "<Esc>",                  -- ESCで終了
			exec = "<CR>",                   -- Enterで実行
		},
	},

	-- ===== 診断機能カスタマイズ =====
	diagnostic = {
		show_code_action = true,             -- 診断でコードアクション表示
		show_source = true,                  -- 診断ソース表示
		jump_num_shortcut = true,            -- 数字で診断ジャンプ
		max_width = 0.7,                     -- 最大幅（画面の70%）
		text_hl_follow = true,               -- テキストハイライト追従
		border_follow = true,                -- ボーダー追従
		keys = {
			exec_action = "o",               -- アクション実行
			quit = "q",                      -- 終了
			go_action = "g",                 -- アクションに移動
		},
	},

	-- ===== lightbulb設定 =====
	lightbulb = {
		virtual_text = false,                -- バーチャルテキスト無効
	},

	-- ===== finder機能拡張 =====
	finder = {
		max_height = 0.5,                    -- 最大高さ（画面の50%）
		min_width = 30,                      -- 最小幅
		force_max_height = false,            -- 強制最大高さ無効
		keys = {
			jump_to = "p",                   -- プレビュージャンプ
			expand_or_jump = "o",            -- 展開またはジャンプ
			vsplit = "s",                    -- 垂直分割で開く
			split = "i",                     -- 水平分割で開く
			tabe = "t",                      -- 新しいタブで開く
			quit = { "q", "<ESC>" },         -- 終了
			scroll_down = "<C-j>",           -- スクロールダウン
			scroll_up = "<C-k>",             -- スクロールアップ
		},
	},

	-- ===== シンボルウィンドウバー（パンくずリスト） =====
	symbol_in_winbar = {
		enable = true,                       -- 有効化
		separator = " › ",                   -- セパレータ
		hide_keyword = true,                 -- キーワード非表示
		show_file = true,                    -- ファイル名表示
		folder_level = 2,                    -- フォルダレベル
		color_mode = true,                   -- カラーモード
	},

	-- ===== アウトライン最適化 =====
	outline = {
		win_position = "right",              -- 右側表示
		win_width = 30,                      -- ウィンドウ幅
		preview_width = 0.4,                 -- プレビュー幅
		show_detail = true,                  -- 詳細表示
		auto_preview = true,                 -- 自動プレビュー
		auto_refresh = true,                 -- 自動更新
		auto_close = true,                   -- 自動クローズ
		keys = {
			expand_or_jump = "o",            -- 展開またはジャンプ
			quit = "q",                      -- 終了
		},
	},

	-- ===== パフォーマンス設定 =====
	request_timeout = 2000,                  -- リクエストタイムアウト（2秒）

	-- ===== スクロールプレビュー =====
	scroll_preview = {
		scroll_down = "<C-f>",               -- スクロールダウン
		scroll_up = "<C-b>",                 -- スクロールアップ
	},
})

-- ===== KEYMAP MANAGEMENT =====
-- キーマップは keymap/plugins.lua で一元管理されています
-- 以下は参考用のコメント（実際のキーマップは keymap/plugins.lua を参照）
--
-- gx: コードアクション（normal + visual）
-- <leader>rn: リネーム
-- K: ホバー情報
-- go: 行診断表示
-- gj/gk: 診断ナビゲーション 
-- <C-u>/<C-d>: スマートスクロール
-- <leader>o: アウトライン表示

-- vim.keymap.set("n", LK_LSP.."r", "<cmd>Lspsaga rename ++project<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "M", "<cmd>Lspsaga code_action<cr>", { silent = true, noremap = true })
-- vim.keymap.set("x", "M", ":<c-u>Lspsaga range_code_action<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", "?", "<cmd>Lspsaga hover_doc<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."j", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."k", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."f", "<cmd>Lspsaga lsp_finder<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."s", "<Cmd>Lspsaga signature_help<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."d", "<cmd>Lspsaga preview_definition<CR>", { silent = true })
-- vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true, noremap = true })
-- -- vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>")
-- vim.keymap.set("n", LK_LSP.."l", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."c", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."b", "<cmd>Lspsaga show_buf_diagnostics<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", "[E", function()
-- 	require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true, noremap = true })
-- vim.keymap.set("n", "]E", function()
-- 	require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
-- end, { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."I", "<cmd>Lspsaga incoming_calls<CR>", { silent = true, noremap = true })
-- vim.keymap.set("n", LK_LSP.."O", "<cmd>Lspsaga outgoing_calls<CR>", { silent = true, noremap = true })
