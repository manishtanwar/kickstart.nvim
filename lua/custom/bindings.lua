-- cycle through tabs
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', { noremap = true })

-- Replace word under cursor, press . to repeat (similar to multiple cursors)
vim.api.nvim_set_keymap('n', '<Leader>x', [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn]], { noremap = true })

-- Replace word under cursor in reverse, press . to repeat
vim.api.nvim_set_keymap('n', '<Leader>X', [[/\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN]], { noremap = true })

-- cd into current buffer's directory
vim.api.nvim_set_keymap('n', '<leader>cd', [[:cd %:p:h<CR>]], { noremap = true })

-- Paste the last yanked text, deleted text does not count
vim.api.nvim_set_keymap('n', 'yp', [["0p]], { noremap = true })
vim.api.nvim_set_keymap('n', 'yP', [["0P]], { noremap = true })

-- Select all
vim.api.nvim_set_keymap('n', '<leader>a', 'ggVG', { noremap = true })

-- Resize splits
vim.api.nvim_set_keymap('n', '<leader>i', ':vertical resize +10<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>I', ':resize +3<CR>', { noremap = true, silent = true })

-- Nvim tree find file
vim.api.nvim_set_keymap('n', '<leader>N', ':NvimTreeFindFile<CR>', { silent = true })

vim.opt.fixendofline = false
