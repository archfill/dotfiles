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
          if vim.api.nvim_buf_is_valid(current_buf) then
            vim.cmd("bdelete " .. current_buf)
          end
        end,
        desc = "Close current buffer",
      },
      { "H", "<cmd>bprevious<cr>", desc = "Previous buffer" },
      { "L", "<cmd>bnext<cr>", desc = "Next buffer" },
      {
        "<leader>bd",
        function()
          local current_buf = vim.api.nvim_get_current_buf()
          if vim.api.nvim_buf_is_valid(current_buf) then
            vim.cmd("bdelete " .. current_buf)
          end
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
      -- 🎨 Beautiful Catppuccin Integration
      default_hl = {
        fg = function(buffer)
          return buffer.is_focused and "#cdd6f4" or "#9399b2" -- Text / Subtext0
        end,
        bg = function(buffer)
          return buffer.is_focused and "#1e1e2e" or "#181825" -- Base / Mantle
        end,
      },
      
      -- 🔧 Modern Tab Components with Enhanced Visual Feedback
      components = {
        -- Left padding with beautiful separator
        {
          text = function(buffer)
            return buffer.index == 1 and " " or ""
          end,
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
        },
        
        -- Devicon with enhanced colors
        {
          text = function(buffer) 
            return " " .. buffer.devicon.icon 
          end,
          fg = function(buffer) 
            return buffer.is_focused and buffer.devicon.color or "#6c7086" -- Surface2 when unfocused
          end,
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
        },
        
        -- Filename with smart styling
        {
          text = function(buffer) 
            return " " .. buffer.filename 
          end,
          fg = function(buffer)
            if buffer.is_focused then
              return buffer.is_modified and "#f9e2af" or "#cdd6f4" -- Yellow if modified, Text if normal
            else
              return buffer.is_modified and "#fab387" or "#9399b2" -- Peach if modified, Subtext0 if normal
            end
          end,
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
          style = function(buffer)
            return buffer.is_focused and "bold" or nil
          end,
        },
        
        -- Modified indicator with beautiful styling
        {
          text = function(buffer)
            return buffer.is_modified and " ●" or ""
          end,
          fg = function(buffer)
            return buffer.is_focused and "#f9e2af" or "#fab387" -- Yellow / Peach
          end,
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
        },
        
        -- Readonly indicator
        {
          text = function(buffer)
            return buffer.is_readonly and "  " or ""
          end,
          fg = "#f38ba8", -- Red for readonly
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
        },
        
        -- Beautiful close button (only on focused buffer)
        {
          text = function(buffer)
            return buffer.is_focused and "  󰅖 " or " "
          end,
          fg = function(buffer)
            return buffer.is_focused and "#f38ba8" or "#181825" -- Red close button or match background
          end,
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
          on_click = function(_, _, _, _, buffer)
            if buffer and buffer.number and vim.api.nvim_buf_is_valid(buffer.number) then
              vim.api.nvim_buf_delete(buffer.number, {})
            end
          end,
        },
        
        -- Right separator (Safe Implementation)
        {
          text = function(buffer, buffers)
            -- buffers が nil の場合の安全な処理
            if not buffers then
              return " " -- デフォルト区切り文字
            end
            -- buffer.index 存在チェック
            if not buffer or not buffer.index then
              return " "
            end
            -- 安全な配列長チェック
            local buffer_count = type(buffers) == "table" and #buffers or 0
            return buffer.index < buffer_count and " " or " "
          end,
          bg = function(buffer)
            return buffer.is_focused and "#1e1e2e" or "#181825"
          end,
        },
      },
      
      -- 🌲 Enhanced Sidebar for Neo-tree
      sidebar = {
        filetype = "neo-tree",
        components = {
          {
            text = "   Neo-tree",
            fg = "#89b4fa", -- Blue
            bg = "#1e1e2e", -- Base
            style = "bold",
          },
        }
      },
      
      -- 🔢 Beautiful Tab Numbers (Safe Implementation)
      tabs = {
        placement = "right",
        components = {
          {
            text = function(tabpage)
              -- tabpage 存在チェック
              if not tabpage or not tabpage.number then
                return " ? "
              end
              return " " .. tabpage.number .. " "
            end,
            fg = "#cdd6f4", -- Text
            bg = "#313244", -- Surface0
            style = "bold",
          },
        },
      },
      
      -- 🎯 Enhanced Pick Letter Display
      pick = {
        use_filename = true,
        letters = "etovxqpdwfghjklmnprbciuaoszuy1234567890",
      },
      
      -- 🎨 Additional Styling Options (Enhanced Safety)
      show_if_buffers_are_at_least = 1, -- 単一ファイルでもタブ表示
      buffers = {
        filter_valid = function(buffer)
          -- より厳密なバッファ検証
          return buffer 
            and buffer.type ~= "terminal" 
            and buffer.number 
            and vim.api.nvim_buf_is_valid(buffer.number)
        end,
        new_buffers_position = "next", -- Insert new buffers next to current
      },
    },
  },
}