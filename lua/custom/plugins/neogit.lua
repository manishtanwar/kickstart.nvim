-- Neogit: a Magit-like Git interface for Neovim
return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional, Magit-style diff view
      'nvim-telescope/telescope.nvim', -- optional, for selection UI
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Neo[g]it status' },
      { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Neogit [c]ommit' },
      { '<leader>gp', '<cmd>Neogit pull<cr>', desc = 'Neogit [p]ull' },
      { '<leader>gP', '<cmd>Neogit push<cr>', desc = 'Neogit [P]ush' },
      { '<leader>gb', '<cmd>Telescope git_branches<cr>', desc = 'Neogit [b]ranches' },
    },
    config = function()
      require('neogit').setup {}
    end,
  },
}
