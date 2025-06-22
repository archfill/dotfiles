-- mason.nvim v2.0.0 最新設定
-- ポータブルパッケージマネージャー（LSP、DAP、リンター、フォーマッター）

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
	vim.notify("mason.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

-- ===== MASON v2.0.0 セットアップ =====
mason.setup({
	-- ===== 基本設定 =====
	-- インストール先ディレクトリ（標準パス使用）
	install_root_dir = vim.fn.stdpath("data") .. "/mason",
	
	-- PATH管理設定
	PATH = "prepend", -- masonのbinを最優先でPATHに追加
	
	-- ログレベル設定
	log_level = vim.log.levels.INFO, -- DEBUG, INFO, WARN, ERROR
	
	-- パフォーマンス設定
	max_concurrent_installers = 4, -- 同時インストール数制限
	
	-- ===== レジストリとプロバイダー設定 =====
	-- パッケージレジストリ（公式）
	registries = {
		"github:mason-org/mason-registry",
	},
	
	-- メタデータプロバイダー（API優先、クライアント側フォールバック）
	providers = {
		"mason.providers.registry-api", -- https://api.mason-registry.dev
		"mason.providers.client",       -- クライアント側ツール
	},
	
	-- ===== GitHub設定 =====
	github = {
		-- GitHubリリースダウンロードURLテンプレート
		download_url_template = "https://github.com/%s/releases/download/%s/%s",
	},
	
	-- ===== Python pip設定 =====
	pip = {
		upgrade_pip = false,    -- pipの自動アップグレード無効
		install_args = {},      -- 追加のpipインストール引数
	},
	
	-- ===== UI設定 =====
	ui = {
		-- パッケージ状況チェック
		check_outdated_packages_on_open = true,
		
		-- ウィンドウ境界線設定（v2.0.0準拠）
		border = "rounded",
		
		-- ウィンドウサイズ設定
		width = 0.8,  -- 画面幅の80%
		height = 0.9, -- 画面高さの90%
		
		-- ===== アイコン設定（v2.0.0準拠） =====
		icons = {
			package_installed = "✓",   -- インストール済み
			package_pending = "➜",     -- インストール中/待機中
			package_uninstalled = "✗"  -- 未インストール
		},
		
		-- ===== キーマップ設定（v2.0.0準拠） =====
		keymaps = {
			-- パッケージ操作
			toggle_package_expand = "<CR>",
			install_package = "i",
			update_package = "u",
			check_package_version = "c",
			update_all_packages = "U",
			check_outdated_packages = "C",
			uninstall_package = "X",
			cancel_installation = "<C-c>",
			
			-- フィルター・ヘルプ
			apply_language_filter = "<C-f>",
			toggle_package_install_log = "<CR>",
			toggle_help = "g?",
		},
	},
})

-- ===== v2.0.0 コマンド設定 =====
-- mason.nvim v2.0.0で利用可能なコマンド:
-- :Mason - UIを開く
-- :MasonUpdate - レジストリ更新
-- :MasonInstall <package> - パッケージインストール
-- :MasonUninstall <package> - パッケージアンインストール
-- :MasonUninstallAll - 全パッケージアンインストール
-- :MasonLog - ログファイルを表示

-- 推奨パッケージ一括インストールコマンド
vim.api.nvim_create_user_command("MasonInstallEssentials", function()
	local essential_packages = {
		-- LSP Servers (Essential)
		"lua-language-server",       -- Lua
		"pyright",                  -- Python
		"typescript-language-server", -- TypeScript/JavaScript
		"json-lsp",                 -- JSON
		"yaml-language-server",      -- YAML
		"bash-language-server",      -- Bash
		"rust-analyzer",            -- Rust
		"gopls",                    -- Go
		"clangd",                   -- C/C++
		"html-lsp",                 -- HTML
		"css-lsp",                  -- CSS
		
		-- Tier1 LSP Servers
		"intelephense",             -- PHP
		"solargraph",               -- Ruby
		"sqls",                     -- SQL
		"terraform-ls",             -- Terraform/HCL
		"kotlin-language-server",   -- Kotlin
		
		-- Formatters (Essential)
		"stylua",                   -- Lua
		"prettier",                 -- Web (JS/TS/HTML/CSS/JSON/YAML)
		"black",                    -- Python
		"isort",                    -- Python imports
		"rustfmt",                  -- Rust
		"gofmt",                    -- Go
		"goimports",               -- Go imports
		"clang-format",            -- C/C++
		"shfmt",                   -- Shell scripts
		
		-- Tier1 Formatters
		"php-cs-fixer",            -- PHP
		"rubocop",                 -- Ruby
		"sql-formatter",           -- SQL
		"terraform-fmt",           -- Terraform/HCL (内蔵だが一応)
		"ktlint",                  -- Kotlin
		
		-- Linters (Essential)
		"luacheck",                -- Lua
		"shellcheck",              -- Shell scripts
		"eslint_d",                -- JavaScript/TypeScript
		"pylint",                  -- Python
		"golangci-lint",           -- Go
		"cppcheck",                -- C/C++
		"yamllint",                -- YAML
		
		-- Tier1 Linters
		"phpstan",                 -- PHP
		-- rubocop (共通)           -- Ruby
		"sqlfluff",                -- SQL
		"tflint",                  -- Terraform/HCL
		-- ktlint (共通)            -- Kotlin
		
		-- 既存言語不足対応
		"marksman",                -- Markdown LSP
		"dockerfile-language-server", -- Docker LSP
		"selene",                  -- Lua linter
		"htmlhint",                -- HTML linter
		"stylelint",               -- CSS linter
		"dockfmt",                 -- Docker formatter
		
		-- 外部依存言語（条件付き対応）
		"jdtls",                   -- Java LSP
		"dart-language-server",    -- Dart/Flutter LSP
		"dart-analyzer",           -- Dart linter
	}
	
	-- 非同期でインストール
	vim.notify("必須パッケージのインストールを開始...", vim.log.levels.INFO, { title = "Mason v2.0.0" })
	
	for _, package in ipairs(essential_packages) do
		vim.cmd("MasonInstall " .. package)
	end
	
	vim.notify(
		string.format("%d個の必須パッケージ（全言語完全対応）をインストール中\n:Mason で進行状況を確認", #essential_packages),
		vim.log.levels.INFO,
		{ title = "Mason v2.0.0 Ultimate Language Support" }
	)
end, { desc = "Mason v2.0.0: 必須パッケージを一括インストール" })

-- レジストリ更新 + UI表示コマンド
vim.api.nvim_create_user_command("MasonUpdateAndShow", function()
	vim.cmd("MasonUpdate")  -- レジストリ更新
	vim.defer_fn(function()
		vim.cmd("Mason")    -- UI表示
	end, 1000)
end, { desc = "Mason v2.0.0: レジストリ更新後にUIを表示" })

-- ===== v2.0.0 レジストリ・イベント処理 =====
-- mason-registryへの接続と状態監視（遅延実行）
vim.defer_fn(function()
	local registry_ok, registry = pcall(require, "mason-registry")
	if registry_ok then
		-- v2.0.0 レジストリが利用可能な場合のイベント処理
		
		-- パッケージインストール開始
		local install_handle_ok = pcall(function()
			registry:on("package:handle", vim.schedule_wrap(function(pkg, handle)
				vim.notify(
					string.format("📦 %s インストール開始", pkg.name),
					vim.log.levels.INFO,
					{ title = "Mason v2.0.0" }
				)
			end))
		end)

		-- パッケージインストール成功
		local install_success_ok = pcall(function()
			registry:on("package:install:success", vim.schedule_wrap(function(pkg, handle)
				vim.notify(
					string.format("✅ %s インストール完了", pkg.name),
					vim.log.levels.INFO,
					{ title = "Mason v2.0.0" }
				)
			end))
		end)

		-- パッケージインストール失敗
		local install_failed_ok = pcall(function()
			registry:on("package:install:failed", vim.schedule_wrap(function(pkg, handle)
				vim.notify(
					string.format("❌ %s インストール失敗", pkg.name),
					vim.log.levels.ERROR,
					{ title = "Mason v2.0.0" }
				)
			end))
		end)
		
		-- イベント登録状況をログ出力
		if not (install_handle_ok and install_success_ok and install_failed_ok) then
			vim.notify("Mason v2.0.0: 一部イベントハンドラーの登録に失敗", vim.log.levels.WARN)
		end
	else
		vim.notify("Mason registry not available", vim.log.levels.WARN)
	end
end, 3000)

-- ===== 自動セットアップ確認 =====
-- 初回起動時に基本パッケージの確認
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- 3秒後にレジストリチェックを実行
		vim.defer_fn(function()
			local registry_ok, registry = pcall(require, "mason-registry")
			if registry_ok then
				-- レジストリ更新（非同期）
				registry.refresh(function()
					local essential_packages = { "lua-language-server" }
					local missing_packages = {}
					
					for _, pkg_name in ipairs(essential_packages) do
						local pkg_ok, pkg = pcall(registry.get_package, pkg_name)
						if pkg_ok and not pkg:is_installed() then
							table.insert(missing_packages, pkg_name)
						end
					end
					
					if #missing_packages > 0 then
						vim.notify(
							"必須パッケージが不足しています:\n" .. table.concat(missing_packages, ", ") ..
							"\n:MasonInstallRecommended で一括インストール可能",
							vim.log.levels.WARN,
							{ title = "Mason 設定確認" }
						)
					end
				end)
			end
		end, 3000)
	end,
	once = true,
})

-- ===== v2.0.0 キーマップ設定 =====
-- Mason UI操作
vim.keymap.set("n", "<leader>ms", ":Mason<CR>", { 
	desc = "Mason v2.0.0: UIを開く",
	silent = true 
})

-- レジストリ更新 + UI表示
vim.keymap.set("n", "<leader>mu", ":MasonUpdateAndShow<CR>", { 
	desc = "Mason v2.0.0: レジストリ更新後にUIを表示",
	silent = true 
})

-- 必須パッケージインストール
vim.keymap.set("n", "<leader>mi", ":MasonInstallEssentials<CR>", { 
	desc = "Mason v2.0.0: 必須パッケージを一括インストール",
	silent = true 
})

-- Mason ログ表示
vim.keymap.set("n", "<leader>ml", ":MasonLog<CR>", { 
	desc = "Mason v2.0.0: ログファイルを表示",
	silent = true 
})

-- ===== v2.0.0 ステータス表示 =====
-- Mason v2.0.0 設定完了の通知
vim.defer_fn(function()
	vim.notify(
		"🔧 Mason.nvim v2.0.0 設定完了\n" ..
		"<leader>ms: Mason UI\n" ..
		"<leader>mi: 必須パッケージインストール\n" ..
		"<leader>mu: レジストリ更新 + UI\n" ..
		"<leader>ml: ログ表示",
		vim.log.levels.INFO,
		{ title = "Mason v2.0.0 Ready" }
	)
end, 2000)