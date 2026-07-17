-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- { 'mfussenegger/nvim-jdtls' },
  {
    'nvim-tree/nvim-tree.lua',

    config = function()
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- optionally enable 24-bit colour
      vim.opt.termguicolors = true

      require('nvim-tree').setup {
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          width = 30,
        },
        update_focused_file = {
          -- highlight & reveal the current buffer in the tree as you switch files
          enable = true,
          update_root = false,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
        git = {
          -- default is 400ms; bump it so git jobs don't time out and
          -- disable git integration in larger repos
          timeout = 5000,
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          -- keep all of nvim-tree's default mappings
          api.map.on_attach.default(bufnr)
          -- nvim-tree crashes (E5108) when an open/preview action runs on a line
          -- with no node (e.g. the blank area below the last entry). Guard <Tab>.
          vim.keymap.set('n', '<Tab>', function()
            if api.tree.get_node_under_cursor() then
              api.node.open.preview()
            end
          end, { desc = 'nvim-tree: Open Preview', buffer = bufnr, noremap = true, silent = true, nowait = true })
        end,
      }

      -- Key mappings
      vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { silent = true })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',

    config = function()
      require('lualine').setup()
    end,

    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  -- markdown plugin
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
}
