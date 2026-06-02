-- indihood-server .editorconfig ([*.{kt,kts}]): 2-space indent. The repo
-- disables ktlint's max-line-length rule, but checkstyle's 100-char limit is
-- the house style, so keep the same visual guide as Java.
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = '101'
