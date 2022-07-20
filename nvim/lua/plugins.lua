local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
  vim.api.nvim_command("silent !git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd[[packadd packer.nvim]]

require'packer'.startup(function(use)
  -- プラグインを書く
  use 'wbthomason/packer.nvim'

  -- color scheme
  local colorscheme = "nightfox.nvim"
  use 'EdenEast/nightfox.nvim'
  use 'cocopon/pgmnt.vim'

  -- file finder
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'main',
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    config = function ()
      require'pluginconfig.neo-tree'
    end
  }

  -- Auto Completion
  use({
    "hrsh7th/nvim-cmp",
  requires = {
  { "L3MON4D3/LuaSnip", opt = true, event = "VimEnter" },
  { "windwp/nvim-autopairs", opt = true, event = "VimEnter" },
  },
  after = { "LuaSnip", "nvim-autopairs" },
  config = function()
  require("rc/pluginconfig/nvim-cmp")
  end,
  })
  use({
  "onsails/lspkind-nvim",
  module = "lspkind",
  config = function()
  require("rc/pluginconfig/lspkind-nvim")
  end,
  })
  use({ "hrsh7th/cmp-nvim-lsp", module = "cmp_nvim_lsp" })
  use({ "hrsh7th/cmp-nvim-lsp-signature-help", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lsp-document-symbol", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-omni", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-emoji", after = "nvim-cmp" })
  use({ "hrsh7th/cmp-calc", after = "nvim-cmp" })
  use({ "f3fora/cmp-spell", after = "nvim-cmp" })
  use({ "yutkat/cmp-mocword", after = "nvim-cmp" })
  use({
  "uga-rosa/cmp-dictionary",
  after = "nvim-cmp",
  config = function()
  require("rc/pluginconfig/cmp-dictionary")
  end,
  })
  use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })
  use({
  "tzachar/cmp-tabnine",
  run = "./install.sh",
  after = "nvim-cmp",
  })
  use({ "ray-x/cmp-treesitter", after = "nvim-cmp" })
  use({ "lukas-reineke/cmp-rg", after = "nvim-cmp" })
  use({ "lukas-reineke/cmp-under-comparator", module = "cmp-under-comparator" })

  -- lsp
  use 'neovim/nvim-lspconfig'
  use {
    'williamboman/nvim-lsp-installer',
    config = function()
      require'pluginconfig.nvim-lsp'
    end
  }
  use {
    'j-hui/fidget.nvim',
    config = function()
      require'fidget'.setup{}
    end
  }

  -- comment out
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }

  -- Treesitter
  use{
    "nvim-treesitter/nvim-treesitter",
    after = { colorscheme },
    run = ":TSUpdate",
    config = function()
      require('pluginconfig/nvim-treesitter')
    end,
  }

  -- formatter
  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require "null-ls"
      null_ls.setup {
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.diagnostics.eslint,
          null_ls.builtins.completion.spell,
          null_ls.builtins.formatting.prettier,
        },
      }
    end,
  }


  -- packer bootstrap
  if packer_bootstrap then
    require("packer").sync()
  end

end)

vim.cmd([[autocmd BufWritePost init.lua source <afile> | PackerCompile]])

