-- ================================================================
-- NEOVIM CONFIGURATION - LazyVim-Based Dotfiles Standards
-- ================================================================
-- Modern rule-compliant Neovim configuration following Rules 1-10
-- Complete separation of VSCode and terminal environments

-- ===== 互換性レイヤー（最優先で適用） =====
-- vim.tbl_flatten → vim.flatten 互換性レイヤー（古いNeovim対応）
-- Neovim 0.10+では vim.flatten が標準、vim.tbl_flatten は非推奨
-- Neovim 0.12使用中のため、このレイヤーは不要（削除済み）

-- ===== Tree-sitter設定 =====
-- HEAD版でbundled Tree-sitterが有効化済み
vim.g.skip_ts_context_commentstring_module = true

-- Core configurations (always loaded)
require("core.options") -- Neovim options and basic settings

-- VSCode環境での分岐処理
if vim.g.vscode then
	require("core.platform") -- VSCode + WSL settings
else
	-- Terminal Neovim environment
	require("core.global-keymap") -- Basic editor keymaps
	require("plugins") -- Rule-compliant plugin system
end

