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

      -- empty setup using defaults
      require('nvim-tree').setup()

      -- OR setup with some options
      require('nvim-tree').setup {
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
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
  {
    'lervag/vimtex',
    -- lazy-load vimtex on .tex files
    ft = { 'tex', 'bib' },
    config = function()
      -- This is the default, but it's good to be explicit
      vim.g.vimtex_compiler_method = 'latexmk'

      -- Configure your PDF viewer
      -- On Linux/macOS with Zathura
      vim.g.vimtex_view_method = 'zathura'

      -- On Windows with SumatraPDF, you might need something like this:
      -- vim.g.vimtex_view_method = 'sumatrapdf'
      -- vim.g.vimtex_view_sumatrapdf_options = '-forward-search @tex @line @pdf'

      -- Enable continuous compilation and viewing (compiles on save)
      vim.g.vimtex_compiler_continuous_automatic = 1
      vim.g.vimtex_view_automatic = 1
    end,
  },
}
