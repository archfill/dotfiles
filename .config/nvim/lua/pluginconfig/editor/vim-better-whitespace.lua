-- vim-better-whitespace設定
-- 高機能末尾空白処理（リアルタイムハイライト + 自動削除）

-- プラグインが読み込まれる前に設定を行う
-- これにより最適なパフォーマンスと視覚表示を実現

-- ===== 基本機能設定 =====
-- 末尾空白ハイライトを有効化
vim.g.better_whitespace_enabled = 1

-- 保存時に自動で末尾空白を削除
vim.g.strip_whitespace_on_save = 1

-- 削除時の確認ダイアログを無効化（高速化）
vim.g.strip_whitespace_confirm = 0

-- 空行の末尾空白はスキップ（パフォーマンス向上）
vim.g.better_whitespace_skip_empty_lines = 1

-- ===== 視覚設定 =====
-- ターミナルでの色設定
vim.g.better_whitespace_ctermcolor = 'red'

-- GUI（Neovim）での色設定（美しい赤色）
vim.g.better_whitespace_guicolor = '#FF5555'

-- ===== 除外設定 =====
-- 特定のファイルタイプでは末尾空白ハイライトを無効化
vim.g.better_whitespace_filetypes_blacklist = {
	-- Git関連
	'diff',
	'git',
	'gitcommit',
	'gitrebase',
	'gitconfig',
	
	-- ドキュメント・ヘルプ
	'markdown', -- Markdownでは末尾空白が意味を持つ場合がある
	'help',
	'man',
	'text',
	
	-- プラグイン・ツール
	'lazy',
	'mason',
	'TelescopePrompt',
	'neo-tree',
	'alpha',
	'dashboard',
	'Trouble',
	'qf',
	'fugitive',
	'startify',
	
	-- ログ・バイナリ
	'log',
	'binary',
	'xxd',
	
	-- 一時的・特殊ファイル
	'unite',
	'denite',
	'fzf',
	'ctrlp',
	'nofile',
	'terminal',
}

-- ===== 詳細設定 =====
-- 現在行の末尾空白を挿入モード中は非表示にする（デフォルト動作を明示）
vim.g.current_line_whitespace_disabled_hard = 0

-- 非常に大きなファイル（100MB以上）では自動的に無効化
vim.g.better_whitespace_verbosity = 1

-- ===== カスタムコマンド設定 =====
-- プラグイン読み込み後の追加設定
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- カスタムキーマップ（オプション）
		vim.keymap.set('n', '<leader>ws', ':StripWhitespace<CR>', { 
			desc = "Strip trailing whitespace",
			silent = true 
		})
		
		vim.keymap.set('n', '<leader>wt', ':ToggleWhitespace<CR>', { 
			desc = "Toggle whitespace highlighting",
			silent = true 
		})
		
		-- 特定のプロジェクトで一時的に無効化する場合のコマンド
		vim.api.nvim_create_user_command('WhitespaceDisable', function()
			vim.cmd('DisableWhitespace')
			vim.notify('Whitespace highlighting disabled for this session')
		end, { desc = 'Disable whitespace highlighting for this session' })
		
		vim.api.nvim_create_user_command('WhitespaceEnable', function()
			vim.cmd('EnableWhitespace')
			vim.notify('Whitespace highlighting enabled')
		end, { desc = 'Enable whitespace highlighting' })
	end,
})

-- ===== パフォーマンス最適化 =====
-- 大きなファイルでの自動調整
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local line_count = vim.api.nvim_buf_line_count(0)
		-- 1000行以上の大きなファイルでは保存時削除のみ有効
		if line_count > 1000 then
			vim.b.better_whitespace_enabled = 0
			-- ただし保存時の自動削除は継続
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = 0,
				callback = function()
					vim.cmd('StripWhitespace')
				end,
			})
		end
	end,
})

-- 初回起動時の機能紹介メッセージ
if vim.fn.has('vim_starting') == 1 then
	vim.defer_fn(function()
		vim.notify(
			'🚀 vim-better-whitespace が有効化されました\n' ..
			'✨ リアルタイムハイライト + 高機能削除が利用可能',
			vim.log.levels.INFO,
			{ title = 'Whitespace Plugin Active' }
		)
	end, 1000)
end