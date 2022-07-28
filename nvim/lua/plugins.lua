local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
  vim.api.nvim_command("silent !git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd([[packadd packer.nvim]])

require("packer").startup(function(use)
  -- プラグインを書く
  use("wbthomason/packer.nvim")

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

  -- tabline
  use {
    'romgrk/barbar.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

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
  -- use({
  -- "onsails/lspkind-nvim",
  -- module = "lspkind",
  -- config = function()
  -- require("rc/pluginconfig/lspkind-nvim")
  -- end,
  -- })
  use({ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" })
  -- use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
  -- use({ "hrsh7th/cmp-calc", after = "nvim-cmp" })
  -- use({ "f3fora/cmp-spell", after = "nvim-cmp" })
  -- use({ "yutkat/cmp-mocword", after = "nvim-cmp" })
  -- use({
  -- "uga-rosa/cmp-dictionary",
  -- after = "nvim-cmp",
  -- config = function()
  -- require("rc/pluginconfig/cmp-dictionary")
  -- end,
  -- })
  use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
  -- use({
  -- "tzachar/cmp-tabnine",
  -- run = "./install.sh",
  -- after = "nvim-cmp",
  -- })
  -- use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
  -- use({ "lukas-reineke/cmp-rg", after = "nvim-cmp" })
  -- use({ "lukas-reineke/cmp-under-comparator", module = "cmp-under-comparator" })
  use({ "vim-denops/denops.vim" })
  use({
    "vim-skk/skkeleton",
    requires = { "vim-denops/denops.vim" },
    config = function()
      require("pluginconfig.skkeleton")
    end,
    setup = function()
      vim.keymap.set({ "i", "c", "l" }, "<C-j>", "<Plug>(skkeleton-enable)")
      vim.keymap.set("i", "<C-x><C-o>", function()
        require("cmp").complete()
      end)

      local pre_config

      local g1 = vim.api.nvim_create_augroup("skkeleton_callbacks", {})
      vim.api.nvim_create_autocmd("User", {
        group = g1,
        pattern = "skkeleton-enable-pre",
        callback = function()
          pre_config = require("cmp.config").get()
          require("cmp").setup.buffer({
            sources = { { name = "skkeleton" } },
            view = { entries = "native" },
          })
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = g1,
        pattern = "skkeleton-disable-pre",
        callback = function()
          if pre_config then
            require("cmp").setup.buffer(pre_config)
            pre_config = nil
          end
        end,
      })
    end,
  })
  use({ "rinx/cmp-skkeleton", after = { "nvim-cmp", "skkeleton" }, event = { "InsertEnter" } })
  use({
    "delphinus/skkeleton_indicator.nvim",
    config = function()
      vim.api.nvim_exec(
        [[
      hi SkkeletonIndicatorEiji guifg=#88c0d0 guibg=#2e3440 gui=bold
      hi SkkeletonIndicatorHira guifg=#2e3440 guibg=#a3be8c gui=bold
      hi SkkeletonIndicatorKata guifg=#2e3440 guibg=#ebcb8b gui=bold
      hi SkkeletonIndicatorHankata guifg=#2e3440 guibg=#b48ead gui=bold
      hi SkkeletonIndicatorZenkaku guifg=#2e3440 guibg=#88c0d0 gui=bold
    ]]   ,
        false
      )
      require("skkeleton_indicator").setup({})
    end,
  })

  -- lsp
  use("neovim/nvim-lspconfig")
  use({
    "williamboman/nvim-lsp-installer",
    config = function()
      require("pluginconfig.nvim-lsp")
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
