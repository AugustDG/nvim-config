-- Esc closes tool views: floats, tool tabs (neogit), and tool windows
-- (quickfix, help, grug-far, ...). Regular editing windows are never closed.
-- codediff closes its own tab on Esc (see plugins/git.lua).
local M = {}

-- Filetypes whose tab is a tool view: close the whole tab
local tab_tools = { '^Neogit' }

-- Filetypes shown in a tool window: close just that window
local window_tools = {
  'qf', 'help', 'man', 'checkhealth', 'grug-far', 'lazy', 'mason',
  'gitsigns-blame', 'codediff-help', 'snacks_picker_list', 'nvim-undotree',
}

local function matches(ft, patterns)
  for _, p in ipairs(patterns) do
    if ft:match(p) and (p:sub(1, 1) == '^' or ft == p) then
      return true
    end
  end
  return false
end

--- Close the tool view under the cursor. Returns true if something closed.
function M.close()
  local win = vim.api.nvim_get_current_win()
  local ft = vim.bo.filetype

  if vim.api.nvim_win_get_config(win).relative ~= '' then
    pcall(vim.api.nvim_win_close, win, false)
    return true
  end

  if matches(ft, tab_tools) then
    -- Keep a commit/rebase message being written: close only this window
    local editing = vim.iter(vim.fn.tabpagebuflist()):any(function(buf)
      return vim.tbl_contains({ 'gitcommit', 'gitrebase' }, vim.bo[buf].filetype)
    end)
    if editing then
      pcall(vim.cmd.close)
    elseif vim.fn.tabpagenr('$') > 1 then
      vim.cmd.tabclose()
    end
    return true
  end

  if matches(ft, window_tools) then
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      pcall(vim.cmd.close)
    else
      pcall(vim.cmd.bdelete)
    end
    return true
  end

  return false
end

--- Close every tool view in all tabs (used before saving a session).
function M.close_all_tools()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if ft:match('^codediff') or matches(ft, tab_tools) then
        if #vim.api.nvim_list_tabpages() > 1 then
          pcall(vim.cmd.tabclose, vim.api.nvim_tabpage_get_number(tab))
        end
        break
      end
    end
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    local float = vim.api.nvim_win_get_config(win).relative ~= ''
    if float or matches(ft, window_tools) then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
end

return M
