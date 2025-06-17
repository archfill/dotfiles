-- VSCode用の最小限設定
-- プラグインを無効化してVSCodeの拡張機能と競合を避ける

if vim.g.vscode then
  -- VSCode環境でのみ必要な設定
  
  -- 基本的なVimキーバインドの設定
  vim.g.mapleader = " "
  
  -- VSCodeコマンドパレット用のキーマッピング
  vim.keymap.set({'n', 'x'}, '<leader>p', function()
    vim.fn.VSCodeNotify('workbench.action.showCommands')
  end, { desc = 'Command Palette' })
  
  -- ファイル検索
  vim.keymap.set({'n', 'x'}, '<leader>f', function()
    vim.fn.VSCodeNotify('workbench.action.quickOpen')
  end, { desc = 'Quick Open' })
  
  -- シンボル検索
  vim.keymap.set({'n', 'x'}, '<leader>s', function()
    vim.fn.VSCodeNotify('workbench.action.gotoSymbol')
  end, { desc = 'Go to Symbol' })
  
  -- エクスプローラーの表示切り替え
  vim.keymap.set({'n', 'x'}, '<leader>e', function()
    vim.fn.VSCodeNotify('workbench.action.toggleSidebarVisibility')
  end, { desc = 'Toggle Explorer' })
  
  -- ターミナルの表示切り替え
  vim.keymap.set({'n', 'x'}, '<leader>t', function()
    vim.fn.VSCodeNotify('workbench.action.terminal.toggleTerminal')
  end, { desc = 'Toggle Terminal' })
  
  -- 保存
  vim.keymap.set({'n', 'x'}, '<leader>w', function()
    vim.fn.VSCodeNotify('workbench.action.files.save')
  end, { desc = 'Save File' })
  
  -- フォーマット
  vim.keymap.set({'n', 'x'}, '<leader>F', function()
    vim.fn.VSCodeNotify('editor.action.formatDocument')
  end, { desc = 'Format Document' })
  
  -- コメントの切り替え
  vim.keymap.set({'n', 'x'}, 'gc', function()
    vim.fn.VSCodeNotify('editor.action.commentLine')
  end, { desc = 'Toggle Comment' })
  
  -- Git関連
  vim.keymap.set({'n', 'x'}, '<leader>g', function()
    vim.fn.VSCodeNotify('workbench.view.scm')
  end, { desc = 'Git Source Control' })
  
  -- プロブレム（エラー）の表示
  vim.keymap.set({'n', 'x'}, '<leader>x', function()
    vim.fn.VSCodeNotify('workbench.actions.view.problems')
  end, { desc = 'Show Problems' })
  
  -- デバッグの開始/停止
  vim.keymap.set({'n', 'x'}, '<F5>', function()
    vim.fn.VSCodeNotify('workbench.action.debug.start')
  end, { desc = 'Start Debug' })
  
  -- 基本的なエディタ設定（VSCodeの設定を上書きしない範囲で）
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.incsearch = true
  vim.opt.hlsearch = true
  
  -- WSL環境でのクリップボード設定
  if vim.fn.has('wsl') == 1 then
    -- WSL環境ではclip.exeとpowershell.exeを使用
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
    vim.opt.clipboard = "unnamedplus"
  else
    -- 通常のLinux環境
    vim.opt.clipboard = "unnamedplus"
  end
  
  -- 検索ハイライトを消去
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
  
  vim.keymap.set("n", "-", ":", { noremap = true, silent = false })
  vim.keymap.set("n", ":", "-", { noremap = true, silent = false })
end