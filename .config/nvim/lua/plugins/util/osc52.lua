-- ================================================================
-- UTIL: OSC 52 Clipboard Support (SSH/Remote)
-- ================================================================

return {
  {
    "ojroques/nvim-osc52",
    lazy = false,
    priority = 1000,
    config = function()
      require('osc52').setup({
        max_length = 0,      -- 無制限（0 = unlimited）
        silent = false,      -- メッセージ表示
        trim = false,        -- トリム無効
        tmux_passthrough = true,  -- tmux経由でOSC 52を送信
      })

      -- SSH環境またはtmux内の場合、OSC 52を使用
      local function copy(lines, _)
        require('osc52').copy(table.concat(lines, '\n'))
      end

      local function paste()
        return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
      end

      -- SSH接続またはtmux環境の検出
      local in_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
      local in_tmux = vim.env.TMUX ~= nil

      -- SSH/tmux環境ではOSC 52を使用
      if in_ssh or in_tmux then
        vim.g.clipboard = {
          name = 'osc52',
          copy = {['+'] = copy, ['*'] = copy},
          paste = {['+'] = paste, ['*'] = paste},
        }
      end
    end,
  },
}
