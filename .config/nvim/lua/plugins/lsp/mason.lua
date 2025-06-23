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
        border = "single",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
  },

  -- LSP Configuration (pluginconfigから401行の詳細設定を完全移行)
  {
    "williamboman/mason-lspconfig.nvim",
    priority = 500,
    keys = {
      { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
      { "gr", vim.lsp.buf.references, desc = "Go to References" },
      { "gi", vim.lsp.buf.implementation, desc = "Go to Implementation" },
      { "gt", vim.lsp.buf.type_definition, desc = "Go to Type Definition" },
      { "K", vim.lsp.buf.hover, desc = "Hover Documentation" },
      { "<leader>rn", vim.lsp.buf.rename, desc = "Rename Symbol" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
      { "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Diagnostics to Location List" },
      { "[d", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
      { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
    },
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- pluginconfigから完全移行 - 401行の企業レベル設定を統合
      
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
      
      -- masonが利用可能か確認
      local mason_ok, mason = pcall(require, "mason")
      if not mason_ok then
        vim.notify("mason.nvim が見つかりません。LSP設定をスキップします。", vim.log.levels.WARN)
        return
      end
      
      -- ===== MASON-LSPCONFIG 基本設定 =====
      local setup_ok, setup_err = pcall(function()
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
          automatic_enable = true,  -- New API in mason-lspconfig 2.0
        })
      end)
      
      if not setup_ok then
        vim.notify("mason-lspconfig.setup() に失敗しました: " .. tostring(setup_err), vim.log.levels.ERROR)
        return
      end
      
      -- ===== モダンなLSPサーバー設定 (mason-lspconfig 2.0対応) =====
      
      -- 基本サーバー設定関数
      local function setup_server_safe(server_name, config)
        if lspconfig[server_name] and type(lspconfig[server_name].setup) == "function" then
          local ok, err = pcall(function()
            lspconfig[server_name].setup(config or {})
          end)
          if not ok then
            vim.notify(
              string.format("LSP サーバー '%s' の設定に失敗しました: %s", server_name, tostring(err)),
              vim.log.levels.WARN
            )
          end
        end
      end
      
      -- ===== 基本言語サーバー設定 =====
      
      -- Lua Language Server
      setup_server_safe("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim', 'require' } },
            workspace = { 
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
      
      -- Python Language Server
      setup_server_safe("pyright", {
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
      setup_server_safe("jsonls", {
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      })
      
      -- ===== 開発スタックサーバー =====
      
      -- TypeScript/JavaScript（ESLint統合）
      setup_server_safe("tsserver", {
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
      
      -- Rust（最適化設定）
      setup_server_safe("rust_analyzer", {
        settings = {
          ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
            procMacro = { enable = true },
          }
        }
      })
      
      -- Go（最適化設定）
      setup_server_safe("gopls", {
        settings = {
          gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
          }
        }
      })
      
      -- C/C++（クロスプラットフォーム設定）
      setup_server_safe("clangd", {
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
      setup_server_safe("yamlls", {
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
      
      -- Bash/Shell
      setup_server_safe("bashls", {})
      
      -- HTML（Emmet統合）
      setup_server_safe("html", {
        filetypes = { "html", "htmldjango" },
      })
      
      -- CSS（Tailwind対応）
      setup_server_safe("cssls", {
        settings = {
          css = {
            validate = true,
            lint = { unknownAtRules = "ignore" }
          }
        }
      })
      
      -- ===== Tier1言語サーバー =====
      
      -- PHP（WordPress/Laravel対応）
      setup_server_safe("intelephense", {
        settings = {
          intelephense = {
            files = { maxSize = 1000000 },
            environment = { includePaths = { "vendor/" } },
            diagnostics = { enable = true },
          }
        }
      })
      
      -- Ruby（Rails対応）
      setup_server_safe("solargraph", {
        settings = {
          solargraph = {
            diagnostics = true,
            completion = true,
            hover = true,
            formatting = true,
          }
        }
      })
      
      -- SQL（PostgreSQL/MySQL対応）
      local function setup_sqls()
        local local_config_ok, local_config = pcall(require, "config.local")
        if local_config_ok and local_config.sqls then
          setup_server_safe("sqls", {
            settings = { sqls = local_config.sqls }
          })
        else
          setup_server_safe("sqls", {
            settings = { sqls = { connections = {} } }
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
      setup_server_safe("terraformls", {
        filetypes = { "terraform", "hcl" },
        settings = {
          terraform = {
            validation = { enableEnhancedValidation = true }
          }
        }
      })
      
      -- Kotlin（Android/サーバーサイド対応）
      setup_server_safe("kotlin_language_server", {
        settings = {
          kotlin = {
            compiler = {
              jvm = { target = "1.8" }
            }
          }
        }
      })
      
      -- Markdown（ドキュメント作成支援）
      setup_server_safe("marksman", {
        filetypes = { "markdown" },
        settings = {
          marksman = {
            completion = {
              wiki = { enable = true }
            }
          }
        }
      })
      
      -- Docker（コンテナ開発支援）
      setup_server_safe("dockerls", {
        filetypes = { "dockerfile" },
        settings = {
          docker = {
            languageserver = {
              formatter = { ignoreMultilineInstructions = true }
            }
          }
        }
      })
      
      -- ===== 条件付きサーバー設定 =====
      
      -- Java（条件付き対応）
      local function setup_java_lsp()
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
        
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace"
        vim.fn.mkdir(workspace_dir, "p")
        
        setup_server_safe("jdtls", {
          cmd = { "jdtls", "-data", workspace_dir },
          filetypes = { "java" },
          root_dir = require("lspconfig.util").root_pattern(
            ".git", "mvnw", "gradlew", "pom.xml", "build.gradle"
          ),
          settings = {
            java = {
              configuration = {
                runtimes = java_home and {{ name = "JavaSE-11", path = java_home }} or {}
              },
              compile = { nullAnalysis = { mode = "disabled" } },
              contentProvider = { preferred = "fernflower" },
              signatureHelp = { enabled = true },
              completion = { enabled = true },
              format = { enabled = true },
            }
          }
        })
        
        vim.notify("Java LSP (jdtls) が有効化されました", vim.log.levels.INFO, { title = "Java LSP" })
      end
      setup_java_lsp()
      
      -- Dart/Flutter（条件付き対応）
      local function setup_dart_lsp()
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
        
        setup_server_safe("dartls", {
          cmd = { "dart", "language-server", "--protocol=lsp" },
          filetypes = { "dart" },
          root_dir = require("lspconfig.util").root_pattern("pubspec.yaml"),
          init_options = {
            onlyAnalyzeProjectsWithOpenFiles = true,
            suggestFromUnimportedLibraries = true,
            closingLabels = true,
            outline = true,
            flutterOutline = true,
          },
          settings = {
            dart = {
              completeFunctionCalls = true,
              showTodos = true,
              enableSnippets = true,
            }
          }
        })
        
        vim.notify("Dart LSP (dartls) が有効化されました", vim.log.levels.INFO, { title = "Dart LSP" })
      end
      setup_dart_lsp()
    end,
  },
}