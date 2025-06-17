-- Terminal Colors
vim.opt.termguicolors = true

-- Tokyo Night Colorscheme（安全な読み込み）
local function setup_colorscheme()
    local ok, _ = pcall(vim.cmd.colorscheme, "tokyonight")
    if not ok then
        -- フォールバックカラースキーム
        vim.cmd.colorscheme("default")
        vim.notify("tokyonight colorscheme not found, using default", vim.log.levels.WARN)
    end
end

-- プラグイン読み込み後に実行されるように遅延
vim.defer_fn(setup_colorscheme, 100)

-- Custom Highlights
vim.cmd("hi Comment gui=NONE")
