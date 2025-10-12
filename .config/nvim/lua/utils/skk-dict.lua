-- ================================================================
-- SKK Dictionary Management Utility - Pure Neovim Lua Implementation
-- ================================================================
-- 完全自己完結型SKK辞書管理システム
-- - 自動辞書ダウンロード（非同期）
-- - 透明な初期化（プラグイン読み込み時）
-- - 手動管理コマンド提供

local M = {}
local Job = require("plenary.job")

-- ================================================================
-- 設定
-- ================================================================
M.config = {
	data_dir = vim.fn.stdpath("data") .. "/skk",
	dictionaries = {
		{
			name = "SKK-JISYO.L",
			url = "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L",
			size_mb = 4.5,
			essential = true,
			description = "メイン辞書（大辞書）",
		},
		{
			name = "SKK-JISYO.jinmei",
			url = "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.jinmei",
			size_mb = 0.8,
			essential = false,
			description = "人名辞書",
		},
		{
			name = "SKK-JISYO.geo",
			url = "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.geo",
			size_mb = 0.3,
			essential = false,
			description = "地名辞書",
		},
	},
}

-- ================================================================
-- 自動初期化（プラグイン読み込み時呼び出し）
-- ================================================================
function M.auto_init()
	-- 辞書ディレクトリ作成
	vim.fn.mkdir(M.config.data_dir, "p")

	-- 不足辞書チェック
	local missing_dicts = {}
	for _, dict in ipairs(M.config.dictionaries) do
		local dict_path = M.config.data_dir .. "/" .. dict.name
		if vim.fn.filereadable(dict_path) == 0 then
			table.insert(missing_dicts, dict)
		end
	end

	if #missing_dicts > 0 then
		vim.notify("📚 SKK辞書を自動セットアップ中...", vim.log.levels.INFO)
		M.download_missing_dictionaries(missing_dicts)
	else
		vim.notify("🎌 SKK辞書準備完了", vim.log.levels.INFO)
	end
end

-- ================================================================
-- 非同期辞書ダウンロード
-- ================================================================
function M.download_missing_dictionaries(dict_list)
	local total = #dict_list
	local completed = 0
	local success_count = 0

	for _, dict in ipairs(dict_list) do
		M.download_single_dict(dict, function(success)
			completed = completed + 1
			if success then
				success_count = success_count + 1
				vim.notify(
					"✅ " .. dict.name .. " ダウンロード完了 (" .. dict.description .. ")",
					vim.log.levels.INFO
				)
			else
				if dict.essential then
					vim.notify(
						"❌ " .. dict.name .. " ダウンロード失敗（必須辞書）",
						vim.log.levels.ERROR
					)
				else
					vim.notify(
						"⚠️ " .. dict.name .. " ダウンロード失敗（オプション辞書）",
						vim.log.levels.WARN
					)
				end
			end

			-- 全ダウンロード完了時
			if completed == total then
				if success_count > 0 then
					vim.notify(
						string.format(
							"🎉 SKK辞書セットアップ完了！（%d/%d成功）",
							success_count,
							total
						),
						vim.log.levels.INFO
					)
					-- skkeleton再設定トリガー
					vim.api.nvim_exec_autocmds("User", { pattern = "SKKDictReady" })
				else
					vim.notify("⚠️ 全てのSKK辞書ダウンロードに失敗しました", vim.log.levels.ERROR)
				end
			end
		end)
	end
end

-- ================================================================
-- 単一辞書ダウンロード
-- ================================================================
function M.download_single_dict(dict, callback)
	local target_path = M.config.data_dir .. "/" .. dict.name
	local temp_path = target_path .. ".tmp"

	-- プログレス表示のための辞書情報
	local progress_msg = string.format("%s (%.1fMB)", dict.name, dict.size_mb)
	vim.notify("📥 ダウンロード開始: " .. progress_msg, vim.log.levels.INFO)

	Job:new({
		command = "curl",
		args = {
			"-fsSL",
			"--connect-timeout",
			"30",
			"--max-time",
			"300",
			"-o",
			temp_path,
			dict.url,
		},
		on_exit = function(j, return_val)
			-- vim.schedule を使用してfast event contextを回避
			vim.schedule(function()
				if return_val == 0 then
					-- ファイルサイズチェック（最低1KB以上）
					local file_size = vim.fn.getfsize(temp_path)
					if file_size > 1000 then
						vim.fn.rename(temp_path, target_path)
						callback(true)
					else
						vim.fn.delete(temp_path)
						callback(false)
					end
				else
					vim.fn.delete(temp_path)
					callback(false)
				end
			end)
		end,
		on_stderr = function(_, data)
			if data and #data > 0 then
				vim.notify("ダウンロードエラー: " .. table.concat(data, "\n"), vim.log.levels.DEBUG)
			end
		end,
	}):start()
end

-- ================================================================
-- 利用可能辞書取得
-- ================================================================
function M.get_available_dictionaries()
	local available = {}
	for _, dict in ipairs(M.config.dictionaries) do
		local dict_path = M.config.data_dir .. "/" .. dict.name
		if vim.fn.filereadable(dict_path) == 1 then
			table.insert(available, dict_path)
		end
	end
	return available
end

-- ================================================================
-- 手動更新（全辞書強制再ダウンロード）
-- ================================================================
function M.force_update()
	vim.notify("📚 SKK辞書を強制更新中...", vim.log.levels.INFO)

	-- 既存辞書を一時的にバックアップ
	local backup_dir = M.config.data_dir .. "/backup_" .. os.date("%Y%m%d_%H%M%S")
	vim.fn.mkdir(backup_dir, "p")

	for _, dict in ipairs(M.config.dictionaries) do
		local dict_path = M.config.data_dir .. "/" .. dict.name
		if vim.fn.filereadable(dict_path) == 1 then
			vim.fn.rename(dict_path, backup_dir .. "/" .. dict.name)
		end
	end

	M.download_missing_dictionaries(M.config.dictionaries)
end

-- ================================================================
-- ステータス確認
-- ================================================================
function M.status()
	local available = M.get_available_dictionaries()
	local total = #M.config.dictionaries
	local status_lines = { string.format("📊 SKK辞書ステータス: %d/%d 利用可能", #available, total) }

	for _, dict in ipairs(M.config.dictionaries) do
		local dict_path = M.config.data_dir .. "/" .. dict.name
		if vim.fn.filereadable(dict_path) == 1 then
			local size_kb = math.floor(vim.fn.getfsize(dict_path) / 1024)
			local status_icon = dict.essential and "🔥" or "📖"
			table.insert(
				status_lines,
				string.format("%s ✅ %s (%dKB) - %s", status_icon, dict.name, size_kb, dict.description)
			)
		else
			local status_icon = dict.essential and "🔥" or "📖"
			table.insert(
				status_lines,
				string.format("%s ❌ %s (未ダウンロード) - %s", status_icon, dict.name, dict.description)
			)
		end
	end

	-- 保存場所情報
	table.insert(status_lines, "")
	table.insert(status_lines, "💾 保存場所: " .. M.config.data_dir)

	local status_msg = table.concat(status_lines, "\n")
	vim.notify(status_msg, vim.log.levels.INFO)

	return #available, total
end

-- ================================================================
-- クリーンアップ（辞書ディレクトリ削除）
-- ================================================================
function M.clean()
	if vim.fn.isdirectory(M.config.data_dir) == 1 then
		vim.fn.system("rm -rf " .. vim.fn.shellescape(M.config.data_dir))
		vim.notify(
			"🗑️ SKK辞書ディレクトリをクリアしました: " .. M.config.data_dir,
			vim.log.levels.INFO
		)
	else
		vim.notify("📁 SKK辞書ディレクトリが存在しません", vim.log.levels.INFO)
	end
end

-- ================================================================
-- 辞書パス取得（skkeleton設定用）
-- ================================================================
function M.get_dict_paths()
	return {
		data_dir = M.config.data_dir,
		user_dict = M.config.data_dir .. "/user.dict",
		rank_file = M.config.data_dir .. "/rank.json",
		available_dicts = M.get_available_dictionaries(),
	}
end

-- ================================================================
-- 健全性チェック
-- ================================================================
function M.health_check()
	local health_info = {
		plenary_available = pcall(require, "plenary.job"),
		curl_available = vim.fn.executable("curl") == 1,
		data_dir_writable = vim.fn.filewritable(M.config.data_dir) ~= 0,
		dict_count = #M.get_available_dictionaries(),
		total_dict_count = #M.config.dictionaries,
	}

	return health_info
end

return M

