local config = {
  cmd = { vim.fn.expand '~/.local/share/nvim/mason/bin/jdtls' },
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
}

-- Function to filter out Kotlin files
local function filter_kotlin_file(uri)
  return vim.fn.expand(uri):match '%.kt$' == nil
end

-- Function to modify config to ignore Kotlin files
local function ignore_kotlin_files()
  -- Add a filter to ignore Kotlin files
  config.on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
    client.resolved_capabilities.rename = false

    -- Filter out Kotlin files
    client.resolved_capabilities.document_symbol = {
      dynamic_registration = false,
      symbol_kind = { valueSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 } },
      work_done_progress_options = {
        work_done_progress = true,
      },
    }

    -- Filter out Kotlin files from code actions
    client.resolved_capabilities.code_action = {
      codeActionLiteralSupport = {
        codeActionKind = {
          valueSet = {
            '',
            'quickfix',
            'refactor',
            'refactor.extract',
            'refactor.inline',
            'refactor.rewrite',
            'source',
            'source.organizeImports',
          },
        },
      },
      dynamicRegistration = false,
    }
  end
end

-- Call the function to ignore Kotlin files
ignore_kotlin_files()

require('jdtls').start_or_attach(config)
