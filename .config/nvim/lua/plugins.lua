-- ===== NEOVIM UNIFIED PLUGIN CONFIGURATION =====
-- Stable版とNightly版の統合プラグイン設定システム
-- 共通プラグイン + バージョン固有プラグインの組み合わせ
-- ===================================================

-- lazy.nvim セットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}, { text = true }):wait()
end
vim.opt.runtimepath:prepend(lazypath)

-- Neovimバージョンタイプを自動検出
local function get_neovim_version_type()
	-- 方法1: 環境変数チェック（優先度：最高）
	local env_version = os.getenv("NVIM_VERSION_TYPE")
	if env_version and (env_version == "stable" or env_version == "nightly") then
		return env_version
	end
	
	-- 方法2: 状態ファイルチェック（優先度：中）
	local state_file = vim.fn.expand("~/.neovim_version_state")
	if vim.fn.filereadable(state_file) == 1 then
		local content = vim.fn.readfile(state_file)
		if content and #content > 0 then
			local version_type = vim.trim(content[1])
			if version_type == "stable" or version_type == "nightly" then
				return version_type
			end
		end
	end
	
	-- 方法3: バイナリのバージョン自動判定（優先度：低）
	local version = vim.version()
	if version.prerelease and version.prerelease ~= vim.NIL then
		return "nightly"
	else
		return "stable"
	end
end

-- lazy-lockファイルの動的管理
local function setup_lazy_lock()
	local version_type = get_neovim_version_type()
	local config_dir = vim.fn.stdpath("config")
	local target_lock = config_dir .. "/lazy-lock-" .. version_type .. ".json"
	local current_lock = config_dir .. "/lazy-lock.json"
	
	-- バージョン固有のlazy-lockファイルが存在しない場合は作成
	if vim.fn.filereadable(target_lock) == 0 then
		vim.fn.writefile({"{}"}, target_lock)
	end
	
	-- 現在のlazy-lock.jsonを削除（シンボリックリンクまたは通常ファイル）
	if vim.fn.filereadable(current_lock) == 1 or vim.fn.getftype(current_lock) == "link" then
		vim.fn.delete(current_lock)
	end
	
	-- バージョン固有のlazy-lockにシンボリックリンクを作成
	vim.fn.system(string.format("ln -sf %s %s", 
		vim.fn.shellescape("lazy-lock-" .. version_type .. ".json"),
		vim.fn.shellescape(current_lock)
	))
end

-- lazy-lockファイルをセットアップ
setup_lazy_lock()

-- 共通プラグインを読み込み
local common_plugins = require("plugins_base")

-- バージョン固有プラグインを読み込み
local function load_version_specific_plugins()
	local version_type = get_neovim_version_type()
	
	if version_type == "nightly" then
		-- Nightly版: 実験的プラグインを追加
		local nightly_plugins = require("plugins_nightly")
		return nightly_plugins
	else
		-- Stable版: 追加プラグインなし（現在）
		local stable_plugins = require("plugins_stable")
		return stable_plugins
	end
end

-- プラグインリストを統合
local function create_unified_plugins()
	local version_plugins = load_version_specific_plugins()
	return vim.tbl_extend("force", common_plugins, version_plugins)
end

-- ローカルプラグインの読み込み
local function load_local_plugins()
	if vim.fn.filereadable(vim.fn.expand("~/.nvim_pluginlist_local.lua")) == 1 then
		return dofile(vim.fn.expand("~/.nvim_pluginlist_local.lua"))
	end
	return {}
end

-- 最終的なプラグインリストを作成
local final_plugins = create_unified_plugins()
local local_plugins = load_local_plugins()

-- lazy.nvimでプラグインをセットアップ
require("lazy").setup(vim.tbl_deep_extend("force", final_plugins, local_plugins), {
	defaults = {
		lazy = true, -- should plugins be lazy-loaded?
	},
})

-- デバッグ情報（必要に応じてコメントアウト）
-- local detected_version = get_neovim_version_type()
-- print("Detected Neovim version type:", detected_version)
-- print("Total plugins loaded:", #final_plugins)