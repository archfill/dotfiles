-- mason-lspconfig.nvim設定
-- mason.nvimとnvim-lspconfigを連携

-- 安全なrequire
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
	vim.notify("mason-lspconfig.nvim が見つかりません", vim.log.levels.ERROR)
	return
end

local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
	vim.notify("nvim-lspconfig が見つかりません", vim.log.levels.ERROR)
	return
end

-- ===== MASON-LSPCONFIG 基本設定 =====
mason_lspconfig.setup({
	-- 自動インストールするLSPサーバー（主要言語対応）
	ensure_installed = {
		-- 既存言語
		"lua_ls",      -- Lua
		"pyright",     -- Python  
		"jsonls",      -- JSON
		
		-- 緊急追加（設定不整合修正）
		"tsserver",    -- TypeScript/JavaScript
		"yamlls",      -- YAML
		"bashls",      -- Bash/Shell
		
		-- 主要言語追加
		"rust_analyzer", -- Rust
		"gopls",       -- Go
		"clangd",      -- C/C++
		"html",        -- HTML
		"cssls",       -- CSS
		
		-- Tier1言語追加
		"intelephense", -- PHP
		"solargraph",  -- Ruby
		"sqls",        -- SQL
		"terraformls", -- Terraform/HCL
		"kotlin_language_server", -- Kotlin
		
		-- 既存言語不足対応
		"marksman",    -- Markdown
		"dockerls",    -- Docker
		
		-- 外部依存言語（条件付き対応）
		"jdtls",       -- Java
		"dartls",      -- Dart/Flutter
	},
	automatic_installation = true,
})

-- ===== LSP自動設定ハンドラー =====
mason_lspconfig.setup_handlers({
	-- デフォルトハンドラー（基本設定）
	function(server_name)
		lspconfig[server_name].setup({})
	end,

	-- ===== 言語別特別設定 =====
	
	-- TypeScript/JavaScript（ESLint統合）
	["tsserver"] = function()
		lspconfig.tsserver.setup({
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = 'all',
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					}
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = 'all',
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					}
				}
			}
		})
	end,

	-- Rust（最適化設定）
	["rust_analyzer"] = function()
		lspconfig.rust_analyzer.setup({
			settings = {
				['rust-analyzer'] = {
					cargo = {
						allFeatures = true,
					},
					checkOnSave = {
						command = "clippy",
					},
					procMacro = {
						enable = true,
					},
				}
			}
		})
	end,

	-- Go（最適化設定）
	["gopls"] = function()
		lspconfig.gopls.setup({
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
					gofumpt = true,
				}
			}
		})
	end,

	-- C/C++（クロスプラットフォーム設定）
	["clangd"] = function()
		lspconfig.clangd.setup({
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--function-arg-placeholders",
			},
		})
	end,

	-- YAML（Kubernetes/Docker対応）
	["yamlls"] = function()
		lspconfig.yamlls.setup({
			settings = {
				yaml = {
					schemas = {
						["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
						["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
						["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*docker-compose*.yml",
					},
				}
			}
		})
	end,

	-- HTML（Emmet統合）
	["html"] = function()
		lspconfig.html.setup({
			filetypes = { "html", "htmldjango" },
		})
	end,

	-- CSS（Tailwind対応）
	["cssls"] = function()
		lspconfig.cssls.setup({
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					}
				}
			}
		})
	end,
	
	-- ===== Tier1言語設定 =====
	
	-- PHP（WordPress/Laravel対応）
	["intelephense"] = function()
		lspconfig.intelephense.setup({
			settings = {
				intelephense = {
					files = {
						maxSize = 1000000,
					},
					environment = {
						includePaths = { "vendor/" },
					},
					diagnostics = {
						enable = true,
					},
				}
			}
		})
	end,
	
	-- Ruby（Rails対応）
	["solargraph"] = function()
		lspconfig.solargraph.setup({
			settings = {
				solargraph = {
					diagnostics = true,
					completion = true,
					hover = true,
					formatting = true,
				}
			}
		})
	end,
	
	-- SQL（PostgreSQL/MySQL対応）
	["sqls"] = function()
		-- Load local configuration for SQL connections
		local local_config_ok, local_config = pcall(require, "config.local")
		if local_config_ok and local_config.sqls then
			lspconfig.sqls.setup({
				settings = {
					sqls = local_config.sqls,
				},
			})
		else
			-- Fallback configuration without credentials
			lspconfig.sqls.setup({
				settings = {
					sqls = {
						-- Note: To configure SQL connections, copy config/local.lua.template to config/local.lua
						-- and configure your database connections there
						connections = {},
					},
				},
			})
			if not local_config_ok then
				vim.notify(
					"SQL settings not configured. Copy config/local.lua.template to config/local.lua to configure database connections.",
					vim.log.levels.INFO,
					{ title = "SQLS Configuration" }
				)
			end
		end
	end,
	
	-- Terraform（AWS/Azure/GCP対応）
	["terraformls"] = function()
		lspconfig.terraformls.setup({
			filetypes = { "terraform", "hcl" },
			settings = {
				terraform = {
					validation = {
						enableEnhancedValidation = true,
					},
				},
			},
		})
	end,
	
	-- Kotlin（Android/サーバーサイド対応）
	["kotlin_language_server"] = function()
		lspconfig.kotlin_language_server.setup({
			settings = {
				kotlin = {
					compiler = {
						jvm = {
							target = "1.8",
						},
					},
				},
			},
		})
	end,
	
	-- ===== 既存言語不足対応 =====
	
	-- Markdown（ドキュメント作成支援）
	["marksman"] = function()
		lspconfig.marksman.setup({
			filetypes = { "markdown" },
			settings = {
				marksman = {
					completion = {
						wiki = {
							enable = true,
						},
					},
				},
			},
		})
	end,
	
	-- Docker（コンテナ開発支援）
	["dockerls"] = function()
		lspconfig.dockerls.setup({
			filetypes = { "dockerfile" },
			settings = {
				docker = {
					languageserver = {
						formatter = {
							ignoreMultilineInstructions = true,
						},
					},
				},
			},
		})
	end,
	
	-- ===== 外部依存言語（条件付き対応） =====
	
	-- Java（条件付き対応）
	["jdtls"] = function()
		-- Java環境検出
		local java_home = os.getenv("JAVA_HOME")
		local java_cmd = vim.fn.exepath("java")
		
		if not java_home and not java_cmd then
			vim.notify(
				"Java環境が見つかりません。\n" ..
				"Java開発を行う場合は以下を設定してください:\n" ..
				"• JAVA_HOME環境変数の設定\n" ..
				"• Java JDK 8+のインストール",
				vim.log.levels.INFO,
				{ title = "Java LSP Setup" }
			)
			return
		end
		
		-- workspace設定
		local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace"
		vim.fn.mkdir(workspace_dir, "p")
		
		lspconfig.jdtls.setup({
			cmd = { "jdtls", "-data", workspace_dir },
			filetypes = { "java" },
			root_dir = require("lspconfig.util").root_pattern(
				".git", "mvnw", "gradlew", "pom.xml", "build.gradle"
			),
			settings = {
				java = {
					configuration = {
						runtimes = java_home and {
							{ name = "JavaSE-11", path = java_home }
						} or {},
					},
					-- メモリ使用量最適化
					compile = {
						nullAnalysis = { mode = "disabled" },
					},
					contentProvider = { preferred = "fernflower" },
					-- 基本機能のみ有効化
					signatureHelp = { enabled = true },
					completion = { enabled = true },
					format = { enabled = true },
				},
			},
		})
		
		vim.notify("Java LSP (jdtls) が有効化されました", vim.log.levels.INFO, { title = "Java LSP" })
	end,
	
	-- Dart/Flutter（条件付き対応）
	["dartls"] = function()
		-- Flutter/Dart環境検出
		local flutter_root = os.getenv("FLUTTER_ROOT")
		local flutter_cmd = vim.fn.exepath("flutter")
		local dart_cmd = vim.fn.exepath("dart")
		
		if not flutter_root and not flutter_cmd and not dart_cmd then
			vim.notify(
				"Dart/Flutter環境が見つかりません。\n" ..
				"Flutter開発を行う場合は以下を設定してください:\n" ..
				"• Flutter SDKのインストール\n" ..
				"• FLUTTER_ROOT環境変数またはPATH設定",
				vim.log.levels.INFO,
				{ title = "Dart LSP Setup" }
			)
			return
		end
		
		lspconfig.dartls.setup({
			cmd = { "dart", "language-server", "--protocol=lsp" },
			filetypes = { "dart" },
			root_dir = require("lspconfig.util").root_pattern("pubspec.yaml"),
			init_options = {
				-- Flutter最適化
				onlyAnalyzeProjectsWithOpenFiles = true,
				suggestFromUnimportedLibraries = true,
				closingLabels = true,
				outline = true,
				flutterOutline = true,
			},
			settings = {
				dart = {
					-- 基本機能有効化
					completeFunctionCalls = true,
					showTodos = true,
					enableSnippets = true,
				},
			},
		})
		
		vim.notify("Dart LSP (dartls) が有効化されました", vim.log.levels.INFO, { title = "Dart LSP" })
	end,
})