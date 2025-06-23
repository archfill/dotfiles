-- ================================================================
-- UI: Bufferline - Priority 700
-- ================================================================

return {
  -- Modern bufferline
  {
    "willothy/nvim-cokeline",
    priority = 700,
    keys = {
      {
        "x",
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          vim.cmd("bdelete " .. current_buf)
        end,
        desc = "Close current buffer",
      },
      { "H", "<cmd>bprevious<cr>", desc = "Previous buffer" },
      { "L", "<cmd>bnext<cr>", desc = "Next buffer" },
      {
        "<leader>bd",
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          vim.cmd("bdelete " .. current_buf)
        end,
        desc = "Delete buffer",
      },
      { "<leader>bo", "<cmd>%bd|e#|bd#<cr>", desc = "Close other buffers" },
      {
        "<S-Left>",
        function()
          require("nvim-cokeline.api").move_buffer(-1)
        end,
        desc = "Move buffer left",
      },
      {
        "<S-Right>",
        function()
          require("nvim-cokeline.api").move_buffer(1)
        end,
        desc = "Move buffer right",
      },
      { "<leader>1", "<cmd>lua require('nvim-cokeline.api').pick(1)<cr>", desc = "Buffer 1" },
      { "<leader>2", "<cmd>lua require('nvim-cokeline.api').pick(2)<cr>", desc = "Buffer 2" },
      { "<leader>3", "<cmd>lua require('nvim-cokeline.api').pick(3)<cr>", desc = "Buffer 3" },
      { "<leader>4", "<cmd>lua require('nvim-cokeline.api').pick(4)<cr>", desc = "Buffer 4" },
      { "<leader>5", "<cmd>lua require('nvim-cokeline.api').pick(5)<cr>", desc = "Buffer 5" },
      { "<leader>6", "<cmd>lua require('nvim-cokeline.api').pick(6)<cr>", desc = "Buffer 6" },
      { "<leader>7", "<cmd>lua require('nvim-cokeline.api').pick(7)<cr>", desc = "Buffer 7" },
      { "<leader>8", "<cmd>lua require('nvim-cokeline.api').pick(8)<cr>", desc = "Buffer 8" },
      { "<leader>9", "<cmd>lua require('nvim-cokeline.api').pick(9)<cr>", desc = "Buffer 9" },
    },
    event = "BufReadPost",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      default_hl = {
        fg = function(buffer)
          return buffer.is_focused and "#a9b1d6" or "#565f89"
        end,
        bg = function(buffer)
          return buffer.is_focused and "#1a1b26" or "#16161e"
        end,
      },
      components = {
        {
          text = function(buffer) return " " .. buffer.devicon.icon end,
          fg = function(buffer) return buffer.devicon.color end,
        },
        {
          text = function(buffer) return buffer.filename .. " " end,
          style = function(buffer)
            return buffer.is_focused and "bold" or nil
          end,
        },
        {
          text = function(buffer)
            return buffer.is_modified and "● " or ""
          end,
          fg = "#f7768e",
        },
        {
          text = function(buffer)
            return buffer.is_readonly and " " or ""
          end,
          fg = "#bb9af7",
        },
      },
      sidebar = {
        filetype = "neo-tree",
        components = {
          {
            text = "  Neo-tree",
            fg = "#7aa2f7",
            bg = "#1a1b26",
            style = "bold",
          },
        }
      },
      tabs = {
        placement = "right",
        components = {
          {
            text = function(tabpage)
              return " " .. tabpage.number .. " "
            end,
          },
        },
      },
    },
  },
}