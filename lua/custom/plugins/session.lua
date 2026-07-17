return {
  {
    'rmagatti/auto-session',
    lazy = false,
    priority = 1000,
    opts = {
      suppress_session_log = true,
      -- restore into whatever cwd nvim was started in (eg. by tmux-resurrect
      -- re-running `nvim` in a pane after a tmux server restart)
      cwd_change_handling = false,
    },
  },
}
