-- ===== SIMPLE NEOVIM PLUGIN CONFIGURATION =====
-- 簡素化されたプラグイン設定システム
-- ===================================================

-- lazy.nvim bootstrap（最小構成）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

-- 共通プラグインを読み込み
local common_plugins = require("plugins_base")

-- バージョン固有プラグインを読み込み
local function load_version_plugins()
	-- Neovim バージョン検出（簡素化）
	local version = vim.version()
	if version.prerelease and version.prerelease ~= vim.NIL then
		-- Nightly版
		local ok, nightly_plugins = pcall(require, "plugins_nightly")
		return ok and nightly_plugins or {}
	else
		-- Stable版
		local ok, stable_plugins = pcall(require, "plugins_stable")
		return ok and stable_plugins or {}
	end
end

-- プラグインリストを統合
local version_plugins = load_version_plugins()
local final_plugins = vim.tbl_extend("force", common_plugins, version_plugins)

-- lockfileパスをバージョンに応じて動的に設定
local function get_lockfile_path()
	local version = vim.version()
	if version.prerelease and version.prerelease ~= vim.NIL then
		return vim.fn.stdpath("config") .. "/lazy-lock-nightly.json"
	else
		return vim.fn.stdpath("config") .. "/lazy-lock-stable.json"
	end
end

-- lazy.nvim設定（パフォーマンス重視）
require("lazy").setup(final_plugins, {
	defaults = {
		lazy = true, -- lazy-loadingを有効化してパフォーマンス重視
	},
	lockfile = get_lockfile_path(), -- バージョン別lockfile指定
	install = {
		missing = true,
		colorscheme = { "tokyonight" },
	},
	checker = {
		enabled = false, -- 自動チェック無効
	},
	change_detection = {
		enabled = false, -- 変更検出無効
	},
	performance = {
		cache = {
			enabled = true,
		},
		rtp = {
			reset = true,
			paths = {},
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})