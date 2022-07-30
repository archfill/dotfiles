local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
  vim.api.nvim_command("silent !git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd([[packadd packer.nvim]])

require("packer").startup(function(use)
  -- プラグインを書く
  use("wbthomason/packer.nvim")

  --------------------------------
  -- Notify
  use({ "rcarriga/nvim-notify", module = "notify" })

  -- color scheme
  local colorscheme = "nightfox.nvim"
  use("EdenEast/nightfox.nvim")
  use("cocopon/pgmnt.vim")

  -- status line
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
    config = function()
      require("pluginconfig.lualine")
    end,
  })

  --------------------------------
  -- Bufferline
  if not vim.g.vscode then
    use({
      "akinsho/bufferline.nvim",
      requires = { 'kyazdani42/nvim-web-devicons' },
      after = colorscheme,
      config = function()
        require("pluginconfig.bufferline")
      end,
    })
  end

  --------------------------------------------------------------
  -- FuzzyFinders
  --------------------------------
  -- telescope.nvim
  use({
    "nvim-telescope/telescope.nvim",
    -- requires = { { "nvim-lua/plenary.nvim", opt = true }, { "nvim-lua/popup.nvim", opt = true } },
    after = { colorscheme },
    -- event = "VimEnter",
    config = function()
      require("pluginconfig.telescope")
    end,
  })
  use({
    "nvim-telescope/telescope-frecency.nvim",
    requires = { "tami5/sqlite.lua" },
    after = { "telescope.nvim" },
    config = function()
      require("telescope").load_extension("frecency")
    end,
  })

  --------------------------------
  -- file finder
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "main",
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("pluginconfig.neo-tree")
    end,
  })

  --------------------------------
  -- Auto Completion
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      { "L3MON4D3/LuaSnip", opt = true, event = "VimEnter" },
      { "windwp/nvim-autopairs", opt = true, event = "VimEnter" },
    },
    after = { "LuaSnip", "nvim-autopairs" },
    config = function()
      require("pluginconfig/nvim-cmp")
    end,
  })
  use({
    "onsails/lspkind.nvim",
    module = "lspkind",
    config = function()
      require("pluginconfig.lspkind")
    end,
  })
  use({ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" })
  use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-calc", after = "nvim-cmp" })
  use({ "f3fora/cmp-spell", after = "nvim-cmp" })
  use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
  use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
  use({
    "vim-skk/skkeleton",
    requires = { "vim-denops/denops.vim" },
    config = function()
      require("pluginconfig.skkeleton")
    end,
    setup = function()
      require("pluginstart.skkeleton")
    end,
  })
  use({ "rinx/cmp-skkeleton", after = { "nvim-cmp", "skkeleton" }, event = { "InsertEnter" } })
  use({
    "delphinus/skkeleton_indicator.nvim",
    config = function()
      require("pluginconfig.skkeleton_indicator")
    end,
  })

  --------------------------------
  -- lsp
  use("neovim/nvim-lspconfig")
  use({
    "williamboman/nvim-lsp-installer",
    config = function()
      require("pluginconfig.nvim-lsp")
    end,
  })
  use({
    "tamago324/nlsp-settings.nvim",
    after = { "nvim-lspconfig" },
    config = function()
      require("pluginconfig.nlsp-settings")
    end,
  })

  -- lsp ui
  use({
    "glepnir/lspsaga.nvim",
    after = "mason.nvim",
    config = function()
      require("pluginconfig.lspsaga")
    end,
  })
  use({
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end,
  })

  -- comment out
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    after = { colorscheme },
    run = ":TSUpdate",
    config = function()
      require("pluginconfig/nvim-treesitter")
    end,
  })

  -- formatter
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("pluginconfig/null-ls")
    end,
  })

  -- bracket
  use({
    "windwp/nvim-autopairs",
    event = "VimEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  })

  -- git
  use({
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  })

  -- highlight
  use({
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  })

  -- packer bootstrap
  if packer_bootstrap then
    require("packer").sync()
  end
end)

vim.cmd([[autocmd BufWritePost init.lua source <afile> | PackerCompile]])
