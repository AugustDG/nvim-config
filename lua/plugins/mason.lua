return {
  'williamboman/mason.nvim',
  cmd = {
    'Mason',
    'MasonInstall',
    'MasonUninstall',
    'MasonUninstallAll',
    'MasonLog',
  },
  build = ':MasonUpdate',
  opts = {},
}
