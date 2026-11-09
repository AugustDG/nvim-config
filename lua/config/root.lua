-- Where a buffer's path starts for display (breadcrumbs, tab titles):
-- the nearest git root, or the cwd outside a repo.
-- codediff:///<root>///<rev>/<file> buffers start at <root>/<rev>.
local M = {}

---@param buf integer
---@return string? root, string? rev, string? file
local function codediff(buf)
  return vim.api.nvim_buf_get_name(buf):match('^codediff://(.-)///([^/]+)/(.+)$')
end

---@param buf integer
---@param win? integer
---@return string
function M.root(buf, win)
  local root, rev = codediff(buf)
  if root then
    return root .. '/' .. rev
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.b[buf].git_root_for ~= name then
    vim.b[buf].git_root_for = name
    vim.b[buf].git_root = vim.fs.root(buf, '.git') or false
  end
  if vim.b[buf].git_root then
    return vim.b[buf].git_root
  end
  local ok, cwd = pcall(vim.fn.getcwd, win or 0)
  return ok and cwd or vim.fn.getcwd()
end

---Buffer path relative to `M.root()`, or '' for unnamed buffers.
---@param buf integer
---@return string
function M.relpath(buf)
  local _, _, file = codediff(buf)
  if file then
    return file
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return ''
  end
  return vim.fs.relpath(M.root(buf), name) or vim.fn.fnamemodify(name, ':~')
end

return M
