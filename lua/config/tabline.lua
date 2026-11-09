-- Tab titles show the current buffer's path from its git root,
-- shortened like the built-in tabline (p/w/s/ingest.tsx).
local root = require('config.root')

function _G.tabline()
  local parts = {}
  local current = vim.api.nvim_get_current_tabpage()
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local path = root.relpath(buf)
    local label = path == '' and '[No Name]' or vim.fn.pathshorten(path)
    local wins = #vim.tbl_filter(function(w)
      return vim.api.nvim_win_get_config(w).relative == ''
    end, vim.api.nvim_tabpage_list_wins(tab))
    local modified = vim.bo[buf].modified and ' +' or ''
    local hl = tab == current and '%#TabLineSel#' or '%#TabLine#'
    local count = wins > 1 and ('%#Title#' .. wins .. hl .. ' ') or ''
    -- %T makes the label clickable; escape % in file names
    table.insert(parts, ('%s%%%dT %s%s%s '):format(hl, i, count, label:gsub('%%', '%%%%'), modified))
  end
  return table.concat(parts) .. '%#TabLineFill#%T%=%#TabLine#%999XX'
end

vim.o.tabline = '%!v:lua.tabline()'
