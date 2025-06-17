-- noice.nvim 最新設定
-- 美しく機能的なメッセージ、コマンドライン、ポップアップメニューのUI
-- 最新のドキュメントに基づく包括的な設定

local noice_ok, noice = pcall(require, "noice")
if not noice_ok then
	vim.notify("noice.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

-- 依存関係の確認（遅延チェック）
vim.defer_fn(function()
	local nui_ok = pcall(require, "nui")
	if not nui_ok then
		vim.notify("nui.nvim 依存関係が見つかりません\nLazy.nvim: :Lazy sync で同期してください", vim.log.levels.WARN)
	end
end, 2000)

-- ===== NOICE セットアップ =====
noice.setup({
	-- ===== コマンドライン設定 =====
	cmdline = {
		enabled = true,
		-- ポップアップ形式のコマンドライン（美しい外観）
		view = "cmdline_popup",
		opts = {},
		
		-- コマンドライン形式設定
		format = {
			-- 通常のコマンド
			cmdline = { 
				pattern = "^:", 
				icon = "", 
				lang = "vim",
				title = " Command " 
			},
			-- 検索（下方向）
			search_down = { 
				kind = "search", 
				pattern = "^/", 
				icon = " ", 
				lang = "regex",
				title = " Search Down " 
			},
			-- 検索（上方向）
			search_up = { 
				kind = "search", 
				pattern = "^%?", 
				icon = " ", 
				lang = "regex",
				title = " Search Up " 
			},
			-- フィルターコマンド
			filter = { 
				pattern = "^:%s*!", 
				icon = "$", 
				lang = "bash",
				title = " Shell " 
			},
			-- Luaコマンド
			lua = { 
				pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, 
				icon = "", 
				lang = "lua",
				title = " Lua " 
			},
			-- ヘルプコマンド
			help = { 
				pattern = "^:%s*he?l?p?%s+", 
				icon = "",
				title = " Help " 
			},
			-- 入力
			input = { 
				view = "cmdline_input", 
				icon = "󰥻 " 
			},
		},
	},

	-- ===== メッセージ設定 =====
	messages = {
		enabled = true,
		view = "notify", -- 通知として表示
		view_error = "notify",
		view_warn = "notify", 
		view_history = "messages",
		view_search = "virtualtext",
	},
	
	-- ===== ポップアップメニュー設定 =====
	popupmenu = {
		enabled = true,
		backend = "nui", -- nui.nvimバックエンド使用
		-- 補完アイテムアイコン
		kind_icons = {
			Text = "󰉿",
			Method = "󰆧",
			Function = "󰊕",
			Constructor = "",
			Field = "󰜢",
			Variable = "󰀫",
			Class = "󰠱",
			Interface = "",
			Module = "",
			Property = "󰜢",
			Unit = "󰑭",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "󰈇",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "󰙅",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "",
		},
	},
	
	-- ===== リダイレクト設定 =====
	redirect = {
		view = "popup",
		filter = { event = "msg_show" },
	},
	
	-- ===== カスタムコマンド =====
	commands = {
		-- :Noice history - メッセージ履歴
		history = {
			view = "split",
			opts = { enter = true, format = "details" },
			filter = {
				any = {
					{ event = "notify" },
					{ error = true },
					{ warning = true },
					{ event = "msg_show", kind = { "" } },
					{ event = "lsp", kind = "message" },
				},
			},
		},
		-- :Noice last - 最新のメッセージ
		last = {
			view = "popup",
			opts = { enter = true, format = "details" },
			filter = {
				any = {
					{ event = "notify" },
					{ error = true },
					{ warning = true },
					{ event = "msg_show", kind = { "" } },
					{ event = "lsp", kind = "message" },
				},
			},
			filter_opts = { count = 1 },
		},
		-- :Noice errors - エラーのみ
		errors = {
			view = "popup",
			opts = { enter = true, format = "details" },
			filter = { error = true },
			filter_opts = { reverse = true },
		},
		-- :Noice all - 全てのメッセージ
		all = {
			view = "split",
			opts = { enter = true, format = "details" },
			filter = {},
		},
	},
	
	-- ===== 通知設定 =====
	notify = {
		enabled = true,
		view = "notify",
	},

	-- ===== LSP設定 =====
	lsp = {
		-- プログレス表示
		progress = {
			enabled = true,
			format = "lsp_progress",
			format_done = "lsp_progress_done",
			throttle = 1000 / 30, -- 30fps
			view = "mini",
		},
		-- LSPドキュメントとホバー
		override = {
			-- nvim-cmpとの統合
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
		-- ホバードキュメント
		hover = {
			enabled = true,
			silent = false, -- ホバーが利用できない場合にメッセージ表示
			view = nil, -- nilの場合はデフォルトのホバーハンドラーを使用
			opts = {}, -- ホバーのオプション (lsp.handlers.hover)
		},
		-- シグネチャヘルプ
		signature = {
			enabled = true,
			auto_open = {
				enabled = true,
				trigger = true, -- 自動的にシグネチャヘルプを開く
				luasnip = true, -- LuaSnipと統合
				throttle = 50, -- スロットル間隔（ms）
			},
			view = nil, -- nilの場合はデフォルトのシグネチャハンドラーを使用
			opts = {}, -- シグネチャヘルプのオプション (lsp.handlers.signature_help)
		},
		-- メッセージの表示
		message = {
			enabled = true,
			view = "notify",
			opts = {},
		},
		-- ドキュメントのシンタックスハイライト
		documentation = {
			view = "hover",
			opts = {
				lang = "markdown",
				replace = true,
				render = "plain",
				format = { "{message}" },
				win_options = { concealcursor = "n", conceallevel = 3 },
			},
		},
	},

	-- ===== プリセット設定 =====
	presets = {
		bottom_search = true, -- 検索を下部のクラシックなコマンドラインで使用
		command_palette = true, -- コマンドラインとポップアップメニューを一緒に配置
		long_message_to_split = true, -- 長いメッセージを分割に送信
		inc_rename = false, -- inc-rename.nvimの入力ダイアログを有効化
		lsp_doc_border = false, -- ホバードキュメントとシグネチャヘルプにボーダーを追加
	},
	
	-- ===== ビュー設定 =====
	views = {
		-- コマンドラインポップアップ
		cmdline_popup = {
			position = {
				row = "50%",
				col = "50%",
			},
			size = {
				width = 60,
				height = "auto",
			},
			border = {
				style = "rounded",
				padding = { 0, 1 },
			},
			win_options = {
				winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
			},
		},
		-- ポップアップメニュー
		popupmenu = {
			relative = "editor",
			position = {
				row = 8,
				col = "50%",
			},
			size = {
				width = 60,
				height = 10,
			},
			border = {
				style = "rounded",
				padding = { 0, 1 },
			},
			win_options = {
				winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
			},
		},
	},
	
	-- ===== ルート設定 =====
	routes = {
		-- 検索メッセージを仮想テキストに表示
		{
			filter = {
				event = "msg_show",
				kind = "search_count",
			},
			opts = { skip = true },
		},
		-- 書き込み完了メッセージをミニビューに表示
		{
			filter = {
				event = "msg_show",
				find = "written",
			},
			view = "mini",
		},
		-- 長いメッセージを分割に表示
		{
			filter = {
				event = "msg_show",
				min_height = 6,
			},
			view = "split",
		},
	},
})

-- ===== キーマップ設定 =====
-- Noice履歴とコマンド
vim.keymap.set("n", "<leader>nm", ":Noice<CR>", { desc = "Noice メッセージ履歴" })
vim.keymap.set("n", "<leader>nl", ":Noice last<CR>", { desc = "Noice 最新メッセージ" })
vim.keymap.set("n", "<leader>ne", ":Noice errors<CR>", { desc = "Noice エラー一覧" })
vim.keymap.set("n", "<leader>nh", ":Noice history<CR>", { desc = "Noice 全履歴" })

-- メッセージ削除
vim.keymap.set("n", "<leader>nd", ":NoiceDismiss<CR>", { desc = "Noice メッセージ削除" })

-- Telescope統合（もしTelescopeが利用可能な場合）
local telescope_ok, _ = pcall(require, "telescope")
if telescope_ok then
	vim.keymap.set("n", "<leader>nt", ":Noice telescope<CR>", { desc = "Noice Telescope統合" })
end

-- ===== ステータス表示 =====
vim.defer_fn(function()
	vim.notify(
		"🎨 Noice.nvim が設定されました\n" ..
		"<leader>nm: メッセージ履歴\n" ..
		"<leader>ne: エラー一覧\n" ..
		"<leader>nd: メッセージ削除",
		vim.log.levels.INFO,
		{ title = "Noice Ready" }
	)
end, 1500)
