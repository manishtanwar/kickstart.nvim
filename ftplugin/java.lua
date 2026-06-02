-- Google Java Style as enforced by indihood-server's checkstyle 8.45
-- (config/checkstyle/checkstyle.xml): 100-char lines, 2-space indent
-- (4 for line wraps — google-java-format handles those on save).
-- Set explicitly so guess-indent can't mis-detect a wrap-heavy file.
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = '101'
