-- Window Group Store
-- Reads and writes the serialized group state as JSON.

local M = {}

M.DEFAULT_PATH = os.getenv("HOME") .. "/.local/state/hammerspoon/groups.json"

--- Create a directory and its parents
local function mkdirs(dir)
	local path = ""
	for part in dir:gmatch("[^/]+") do
		path = path .. "/" .. part
		if not hs.fs.attributes(path) then
			hs.fs.mkdir(path)
		end
	end
end

--- Read the saved table
--- @return table|nil nil when the file is missing or unreadable
function M.read(path)
	if not hs.fs.attributes(path) then
		return nil
	end
	local ok, data = pcall(hs.json.read, path)
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

--- Write the table (creates the directory if needed)
--- @return boolean
function M.write(path, data)
	local dir = path:match("^(.*)/[^/]+$")
	if dir then
		mkdirs(dir)
	end
	local ok, result = pcall(hs.json.write, data, path, true, true)
	return ok and result == true
end

return M
