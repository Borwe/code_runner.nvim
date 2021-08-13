local o = require("code_runner.options")
local M = {}

-- Load json config and convert to table
local loadTable = require("code_runner.load_json")
local fileCommands = loadTable()

-- Message if json file not exist
local function file_not_found()
  print(vim.inspect("File not exist or format invalid, please execute :SRunCode"))
end
if not fileCommands then
  M.Run = file_not_found
  return M
end

-- Create prefix for run commands
local prefix = string.format("%s %dsplit term://", o.get().term.position, o.get().term.size)
local suffix = "<CR>"

-- Create autocmd for each file type and add map for ececute file type
local function shellcmd(lang, command)
	vim.cmd ("autocmd FileType " .. lang .. " nnoremap <buffer> " .. o.get().map .. " :" .. prefix .. "" .. command .. suffix)
end

local function vimcmd(lang, config)
	vim.cmd ("autocmd FileType " .. lang .. " nnoremap <buffer> " .. o.get().map .. " :" .. config .. "<CR>")
end

-- Substitute json vars to vim vars in commands for each file type.
-- If a command has no arguments, one is added with the current file path
local function sub_var_command(command)
	local vars_json = {
		["%$fileNameWithoutExt"] = "%%:r",
		["$fileName"] = "%%:t",
		["$file"] = "%%",
		["$dir"] = "%%:p:h"
	}
	for var, var_vim in pairs(vars_json) do
		command = command:gsub(var, var_vim)
	end
	return command
end

function M.get_supported_langs()
  langs = {}
  if fileCommands ~=nil then
    for lang, _ in pairs(fileCommands) do
      table.insert(langs,lang)
    end
  end
  return langs
end

function M.term_cmd_runner(lang_to_use)
  -- check if cmd exists
  if fileCommands[lang_to_use] == nil then
    vim.api.nvim_echo({{"No such "..lang_to_use.."language as found"
      ,"WarningMsg"}},true,{})
    return
  end

  -- we reach here means it exists so go ahead and run it
  local command = prefix..sub_var_command(
    fileCommands[lang_to_use])
  -- execute the command gotten
  vim.api.nvim_exec(command,true)
end

-- Create shellcmd
function M.Run()
	for lang, command in pairs(fileCommands) do
		local command_vim = sub_var_command(command)
		shellcmd(lang, command_vim)
	end
	-- vimcmd("markdown", defaults.commands.markdown)
	vimcmd("vim", "source %")
	vimcmd("lua", "luafile %")
end

return M
