-- ================================================================
-- LSP: Mason Package Manager
-- ================================================================

return {
	-- LSP Progress UI (null-ls参照削除、snacks.notifier統合)
	{
		"j-hui/fidget.nvim",
		priority = 700,
		event = "LspAttach",
		opts = {
			notification = {
				window = {
					winblend = 0, -- snacks.notifierと統一
				},
			},
			integration = {
				["nvim-tree"] = { enable = false }, -- neo-tree使用のため
			},
		},
	},

	-- Package Manager
	{
		"mason-org/mason.nvim",
		priority = 600,
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
		event = "VeryLazy",
		opts = {
			ui = {
				border = "rounded",
				size = {
					width = 0.8,
					height = 0.8,
				},
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- Tool Installer (Linters & Formatters)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		priority = 550,
		dependencies = { "mason-org/mason.nvim" },
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				-- Linters (nvim-lint)
				"luacheck", -- Lua
				"ruff", -- Python
				"eslint_d", -- JavaScript/TypeScript (faster than eslint)
				"shellcheck", -- Shell
				"hadolint", -- Dockerfile

				-- Formatters (conform.nvim)
				"stylua", -- Lua
				"black", -- Python
				"isort", -- Python imports
				"prettier", -- JS/TS/HTML/CSS/JSON/YAML/Markdown
				"shfmt", -- Shell

				-- Note: gofmt and rustfmt are included in their language toolchains
			},
			auto_update = false, -- 自動更新しない（安定性重視）
			run_on_start = true, -- Neovim起動時に確認
			start_delay = 3000, -- 3秒遅延（起動速度への影響を最小化）
			debounce_hours = 24, -- 24時間ごとに確認
		},
	},

	-- LSP Configuration (pluginconfigから401行の詳細設定を完全移行)
	{
		"mason-org/mason-lspconfig.nvim",
		priority = 500,
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			-- ===== FLOATING WINDOW CONFIGURATION =====
			-- Diagnostics floating window設定
			vim.diagnostic.config({
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					focusable = false,
				},
				virtual_text = {
					prefix = "●",
					spacing = 4,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- LSPアタッチ時のみ有効なキーマップ（バッファローカル）
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("ModernLspKeymaps", { clear = true }),
				callback = function(args)
					local opts = { buffer = args.buf, silent = true }

					vim.keymap.set(
						"n",
						"gd",
						vim.lsp.buf.definition,
						vim.tbl_extend("force", opts, { desc = "Go to Definition" })
					)
					vim.keymap.set(
						"n",
						"gr",
						vim.lsp.buf.references,
						vim.tbl_extend("force", opts, { desc = "Go to References" })
					)
					vim.keymap.set(
						"n",
						"gi",
						vim.lsp.buf.implementation,
						vim.tbl_extend("force", opts, { desc = "Go to Implementation" })
					)
					vim.keymap.set(
						"n",
						"gt",
						vim.lsp.buf.type_definition,
						vim.tbl_extend("force", opts, { desc = "Go to Type Definition" })
					)
					vim.keymap.set("n", "K", function()
						vim.lsp.buf.hover({
							border = "rounded",
							focusable = false,
							source = "always",
						})
					end, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
					vim.keymap.set(
						"n",
						"<leader>rn",
						vim.lsp.buf.rename,
						vim.tbl_extend("force", opts, { desc = "Rename Symbol" })
					)
					vim.keymap.set("n", "<leader>ca", function()
						vim.lsp.buf.code_action({
							float = {
								border = "rounded",
								focusable = false,
								title = "Code Actions",
							},
						})
					end, vim.tbl_extend("force", opts, { desc = "Code Action" }))
					vim.keymap.set(
						"n",
						"<leader>dl",
						vim.diagnostic.setloclist,
						vim.tbl_extend("force", opts, { desc = "Diagnostics to Location List" })
					)
					vim.keymap.set(
						"n",
						"<leader>df",
						vim.diagnostic.open_float,
						vim.tbl_extend("force", opts, { desc = "Show Diagnostic in Float" })
					)
					vim.keymap.set(
						"n",
						"[d",
						vim.diagnostic.goto_prev,
						vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" })
					)
					vim.keymap.set(
						"n",
						"]d",
						vim.diagnostic.goto_next,
						vim.tbl_extend("force", opts, { desc = "Next Diagnostic" })
					)
				end,
			})

			-- Signature help floating window設定
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				focusable = false,
				title = "Signature Help",
			})

			-- 安全なrequire
			local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
			if not mason_lspconfig_ok then
				vim.notify("mason-lspconfig.nvim が見つかりません", vim.log.levels.ERROR)
				return
			end

			-- masonが利用可能か確認
			local mason_ok, mason = pcall(require, "mason")
			if not mason_ok then
				vim.notify(
					"mason.nvim が見つかりません。LSP設定をスキップします。",
					vim.log.levels.WARN
				)
				return
			end

			-- ===== MASON-LSPCONFIG 基本設定 =====
			local setup_ok, setup_err = pcall(function()
				mason_lspconfig.setup({
					-- 自動インストールするLSPサーバー（主要言語対応）
					ensure_installed = {
						-- 既存言語
						"lua_ls", -- Lua
						"pyright", -- Python
						"jsonls", -- JSON

						-- 緊急追加（設定不整合修正）
						"ts_ls", -- TypeScript/JavaScript (renamed from tsserver)
						"yamlls", -- YAML
						"bashls", -- Bash/Shell

						-- 主要言語追加
						"rust_analyzer", -- Rust
						"gopls", -- Go
						"clangd", -- C/C++
						"html", -- HTML
						"cssls", -- CSS

						-- Tier1言語追加
						"intelephense", -- PHP
						"solargraph", -- Ruby
						"sqls", -- SQL
						"terraformls", -- Terraform/HCL
						"kotlin_language_server", -- Kotlin

						-- 既存言語不足対応
						"marksman", -- Markdown
						"dockerls", -- Docker

						-- 外部依存言語（条件付き対応）
						-- Note: jdtls は条件付きセットアップ、dartls は flutter-tools.nvim 側で管理
					},
					automatic_enable = false, -- vim.lsp.enable() で明示的に有効化
				})
			end)

			if not setup_ok then
				vim.notify(
					"mason-lspconfig.setup() に失敗しました: " .. tostring(setup_err),
					vim.log.levels.ERROR
				)
				return
			end

			-- ===== モダンなLSPサーバー設定 (Neovim 0.11+ vim.lsp.config対応) =====

			-- サーバー設定関数（vim.lsp.config使用）
			local function setup_server_safe(server_name, config)
				local ok, err = pcall(function()
					vim.lsp.config(server_name, config or {})
				end)

				if not ok then
					vim.notify(
						string.format(
							"LSP サーバー '%s' の設定に失敗しました: %s",
							server_name,
							tostring(err)
						),
						vim.log.levels.WARN
					)
				end
			end

			-- サーバー有効化関数（vim.lsp.enable使用）
			local function enable_server_safe(server_name)
				local ok, err = pcall(function()
					vim.lsp.enable(server_name)
				end)

				if not ok then
					vim.notify(
						string.format(
							"LSP サーバー '%s' の有効化に失敗しました: %s",
							server_name,
							tostring(err)
						),
						vim.log.levels.WARN
					)
				end
			end

			-- モダンAPI: 設定と有効化を明示的に行う
			local function with_completion_capabilities(config)
				local merged = vim.deepcopy(config or {})
				local blink_ok, blink = pcall(require, "blink.cmp")

				if blink_ok and type(blink.get_lsp_capabilities) == "function" then
					merged.capabilities = blink.get_lsp_capabilities(merged.capabilities)
				end

				return merged
			end

			local function setup_and_enable_server(server_name, config)
				setup_server_safe(server_name, with_completion_capabilities(config))
				enable_server_safe(server_name)
			end

			-- ===== 基本言語サーバー設定 =====

			-- Lua Language Server
			setup_and_enable_server("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim", "require" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- Python Language Server
			setup_and_enable_server("pyright", {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			-- JSON Language Server
			setup_and_enable_server("jsonls", {
				settings = {
					json = {
						validate = { enable = true },
					},
				},
			})

			-- ===== 開発スタックサーバー =====

			-- TypeScript/JavaScript（ESLint統合）
			setup_and_enable_server("ts_ls", {
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			})

			-- Rust（最適化設定）
			setup_and_enable_server("rust_analyzer", {
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = { command = "clippy" },
						procMacro = { enable = true },
					},
				},
			})

			-- Go（最適化設定）
			setup_and_enable_server("gopls", {
				settings = {
					gopls = {
						analyses = { unusedparams = true },
						staticcheck = true,
						gofumpt = true,
					},
				},
			})

			-- C/C++（クロスプラットフォーム設定）
			setup_and_enable_server("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
				},
			})

			-- ===== ウェブ技術サーバー =====

			-- YAML（Kubernetes/Docker対応）
			setup_and_enable_server("yamlls", {
				settings = {
					yaml = {
						schemas = {
							["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
							["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*docker-compose*.yml",
						},
					},
				},
			})

			-- Bash/Shell
			setup_and_enable_server("bashls", {})

			-- HTML（Emmet統合）
			setup_and_enable_server("html", {
				filetypes = { "html", "htmldjango" },
			})

			-- CSS（Tailwind対応）
			setup_and_enable_server("cssls", {
				settings = {
					css = {
						validate = true,
						lint = { unknownAtRules = "ignore" },
					},
				},
			})

			-- ===== Tier1言語サーバー =====

			-- PHP（WordPress/Laravel対応）
			setup_and_enable_server("intelephense", {
				settings = {
					intelephense = {
						files = { maxSize = 1000000 },
						environment = { includePaths = { "vendor/" } },
						diagnostics = { enable = true },
					},
				},
			})

			-- Ruby（Rails対応）
			setup_and_enable_server("solargraph", {
				settings = {
					solargraph = {
						diagnostics = true,
						completion = true,
						hover = true,
						formatting = true,
					},
				},
			})

			-- SQL（PostgreSQL/MySQL対応）
			local function setup_sqls()
				local local_config_ok, local_config = pcall(require, "config.local")
				if local_config_ok and local_config.sqls then
					setup_and_enable_server("sqls", {
						settings = { sqls = local_config.sqls },
					})
				else
					setup_and_enable_server("sqls", {
						settings = { sqls = { connections = {} } },
					})
					if not local_config_ok then
						vim.notify(
							"SQL settings not configured. Copy config/local.lua.template to config/local.lua to configure database connections.",
							vim.log.levels.INFO,
							{ title = "SQLS Configuration" }
						)
					end
				end
			end
			setup_sqls()

			-- Terraform（AWS/Azure/GCP対応）
			setup_and_enable_server("terraformls", {
				filetypes = { "terraform", "hcl" },
				settings = {
					terraform = {
						validation = { enableEnhancedValidation = true },
					},
				},
			})

			-- Kotlin（Android/サーバーサイド対応）
			setup_and_enable_server("kotlin_language_server", {
				settings = {
					kotlin = {
						compiler = {
							jvm = { target = "1.8" },
						},
					},
				},
			})

			-- Markdown（ドキュメント作成支援）
			setup_and_enable_server("marksman", {
				filetypes = { "markdown" },
				settings = {
					marksman = {
						completion = {
							wiki = { enable = true },
						},
					},
				},
			})

			-- Docker（コンテナ開発支援）
			setup_and_enable_server("dockerls", {
				filetypes = { "dockerfile" },
				settings = {
					docker = {
						languageserver = {
							formatter = { ignoreMultilineInstructions = true },
						},
					},
				},
			})

			-- ===== 条件付きサーバー設定 =====

			-- Java（条件付き対応）
			local function setup_java_lsp()
				local java_home = os.getenv("JAVA_HOME")
				local java_cmd = vim.fn.exepath("java")

				if not java_home and not java_cmd then
					vim.notify(
						"Java環境が見つかりません。\n"
							.. "Java開発を行う場合は以下を設定してください:\n"
							.. "• JAVA_HOME環境変数の設定\n"
							.. "• Java JDK 8+のインストール",
						vim.log.levels.INFO,
						{ title = "Java LSP Setup" }
					)
					return
				end

				local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace"
				vim.fn.mkdir(workspace_dir, "p")

				setup_and_enable_server("jdtls", {
					cmd = { "jdtls", "-data", workspace_dir },
					filetypes = { "java" },
					root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
					settings = {
						java = {
							configuration = {
								runtimes = java_home and { { name = "JavaSE-11", path = java_home } } or {},
							},
							compile = { nullAnalysis = { mode = "disabled" } },
							contentProvider = { preferred = "fernflower" },
							signatureHelp = { enabled = true },
							completion = { enabled = true },
							format = { enabled = true },
						},
					},
				})

				vim.notify("Java LSP (jdtls) が有効化されました", vim.log.levels.INFO, { title = "Java LSP" })
			end
			setup_java_lsp()

			-- Dart/Flutter は flutter-tools.nvim 側で dartls を管理する
		end,
	},
}
