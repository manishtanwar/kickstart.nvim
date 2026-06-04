return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        -- checkstyle for Java: jdtls gives compiler diagnostics but knows
        -- nothing about the repo's style rules (Google Java Style, 100-char
        -- lines, import order, javadoc requirements). checkstyle fills that
        -- gap using the config checked into the repo (see below).
        java = { 'checkstyle' },
      }

      -- Point checkstyle at the project's own config when the buffer lives in
      -- a Gradle repo that carries one (indihood-server keeps it at
      -- config/checkstyle/checkstyle.xml); otherwise fall back to the
      -- google_checks.xml bundled inside the checkstyle jar.
      local checkstyle = lint.linters.checkstyle
      local bundled_config = checkstyle.config_file
      local function checkstyle_config()
        local root = vim.fs.root(0, { 'settings.gradle', 'settings.gradle.kts' })
        if root then
          local cfg = root .. '/config/checkstyle/checkstyle.xml'
          if vim.uv.fs_stat(cfg) then
            return cfg
          end
        end
        return bundled_config
      end
      checkstyle.args = {
        '-f',
        'sarif',
        -- The repo config references ${config_loc}/custom_suppressions.xml —
        -- a property the Gradle checkstyle plugin defines but the CLI does
        -- not, so supply it via a generated properties file.
        '-p',
        function()
          local props = vim.fn.stdpath 'cache' .. '/checkstyle.properties'
          vim.fn.writefile({ 'config_loc=' .. vim.fs.dirname(checkstyle_config()) }, props)
          return props
        end,
        '-c',
        checkstyle_config,
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if not vim.bo.modifiable then
            return
          end
          -- Run from the buffer's project root so checkstyle resolves the
          -- repo's config even when nvim was started elsewhere (worktrees).
          local root = vim.fs.root(0, { '.editorconfig', 'settings.gradle', 'settings.gradle.kts' })
          lint.try_lint(nil, { cwd = root })
        end,
      })
    end,
  },
}
