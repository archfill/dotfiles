-- ================================================================
-- LANG: Flutter & Dart Development
-- ================================================================

return {
  -- Flutter統合開発ツール
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    keys = {
      { "<leader>Fc", "<cmd>FlutterCopyProfilerUrl<cr>", desc = "Copy Profiler URL" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter Devices" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter Emulators" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter Outline Toggle" },
      { "<leader>Fr", "<cmd>FlutterReload<cr>", desc = "Flutter Reload" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter Restart" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Flutter Quit" },
      { "<leader>Fs", "<cmd>FlutterRun<cr>", desc = "Flutter Run" },
      { "<leader>FD", "<cmd>FlutterDetach<cr>", desc = "Flutter Detach" },
      { "<leader>FL", "<cmd>FlutterLspRestart<cr>", desc = "Flutter LSP Restart" },
      { "<leader>Fl", "<cmd>FlutterSuper<cr>", desc = "Flutter Super" },
      { "<leader>FV", "<cmd>FlutterVisualDebug<cr>", desc = "Flutter Visual Debug" },
      { "<leader>Fv", "<cmd>FlutterVersion<cr>", desc = "Flutter Version" },
    },
    opts = {
      ui = {
        border = "rounded",
        notification_style = "native",
      },
      decorations = {
        statusline = {
          app_version = false,
          device = true,
        }
      },
      debugger = {
        enabled = false,
        run_via_dap = false,
      },
      flutter_path = nil, -- Auto-detect
      flutter_lookup_cmd = nil, -- Auto-detect
      fvm = false, -- Use system Flutter
      widget_guides = {
        enabled = false,
      },
      closing_tags = {
        highlight = "ErrorMsg",
        prefix = "//",
        enabled = true
      },
      dev_log = {
        enabled = true,
        open_cmd = "tabedit",
      },
      dev_tools = {
        autostart = false,
        auto_open_browser = false,
      },
      outline = {
        open_cmd = "30vnew",
        auto_open = false
      },
      lsp = {
        color = {
          enabled = false,
          background = false,
          virtual_text = true,
          virtual_text_str = "■",
        },
        on_attach = nil,
        capabilities = nil,
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          analysisExcludedFolders = {
            vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
            vim.fn.expand("$HOME/.pub-cache"),
            vim.fn.expand("$HOME/tools/flutter"),
          },
          renameFilesWithClasses = "prompt",
          enableSnippets = true,
        }
      }
    },
  },

  -- Dart基本サポート
  {
    "dart-lang/dart-vim-plugin",
    ft = { "dart" },
    config = function()
      vim.g.dart_html_in_string = true
      vim.g.dart_style_guide = 2
      vim.g.dart_format_on_save = true
    end,
  },

  -- pubspec.yaml管理
  {
    "nvim-flutter/pubspec-assist.nvim",
    ft = { "yaml" },
    opts = {
      ui = {
        border = "rounded",
      },
      snippets = {
        enabled = true,
      },
    },
  },
}