local o = require("code_runner.options")
local M = {}

M.setup = function(user_options)
  o.set(user_options)
  vim.api.nvim_exec([[
  command! SRunCode lua require('code_runner').open_filetype_suported()
  ]], false)
  vim.api.nvim_exec([[
  function! CodeRunner_Get_Langs(A,L,P)
    return luaeval('require("code_runner.commands").get_supported_langs()')
  endfunction

  command! -nargs=1 -complete=custom,CodeRunner_Get_Langs  SRunCmd :lua require("code_runner.commands").term_cmd_runner("<args>")
  ]],true)
  M.run_code()
end

M.run_code = function()
  local runner = require("code_runner.commands")
  runner.Run()
end

M.open_filetype_suported = function()
  local command ="tabnew " .. o.get().json_path
  vim.cmd(command)
end

return M
