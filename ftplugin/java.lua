-- ftplugin/java.lua
--
-- WHY THIS FILE EXISTS:
--   Neovim has a concept called "filetype plugins" (ftplugin). Any file you put
--   in ~/.config/nvim/ftplugin/<filetype>.lua gets automatically sourced by
--   Neovim when you open a file of that type. So ftplugin/java.lua runs every
--   time you open a .java file.
--
-- WHY NOT lspconfig?
--   jdtls (Eclipse JDT Language Server) is unusual. Every LSP uses a single
--   running server instance per machine, but jdtls needs a *separate workspace
--   directory per project* because it stores compiled class files, indexes, and
--   project metadata there. The nvim-jdtls plugin handles all of this correctly,
--   while plain lspconfig cannot. nvim-jdtls also unlocks Java-specific IDE
--   actions that lspconfig can't surface: organize imports, extract
--   variable/method, run/debug tests, etc.

-- ─────────────────────────────────────────────────────────────────────────────
-- WORKSPACE DIRECTORY
-- ─────────────────────────────────────────────────────────────────────────────
-- jdtls stores compiled class files and an index of your project here.
-- We give each project its own folder so different projects don't interfere.
-- vim.fn.getcwd() → /home/you/projects/myapp
-- fnamemodify(..., ':p:h:t') → myapp  (the last directory component)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.expand '~/.local/share/nvim/jdtls-workspace/' .. project_name

-- ─────────────────────────────────────────────────────────────────────────────
-- BUNDLES (optional extras: DAP debug adapter, test runner)
-- ─────────────────────────────────────────────────────────────────────────────
-- jdtls can load "bundles" — JAR files that add capabilities.
-- The two most useful ones are:
--   1. java-debug-adapter  → lets nvim-dap step-debug Java code
--   2. vscode-java-test    → lets you run/debug individual JUnit tests
-- Mason installs these in predictable paths. We collect them here and pass them
-- to jdtls so it loads them on startup. If they're not installed yet, the table
-- stays empty and you just won't have debugger integration (everything else works).
local bundles = {}

-- java-debug-adapter bundle (installed by Mason as 'java-debug-adapter')
local debug_bundle = vim.fn.glob(
  vim.fn.expand '~/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar',
  true,   -- nosuf: don't add a suffix
  true    -- list: return a list instead of a newline-separated string
)
vim.list_extend(bundles, debug_bundle)

-- vscode-java-test (JUnit runner) is not in Mason's registry.
-- If you install it manually, uncomment and adjust the path below:
-- local test_bundles = vim.fn.glob(
--   vim.fn.expand '~/.local/share/nvim/mason/packages/vscode-java-test/extension/server/*.jar',
--   true, true
-- )
-- vim.list_extend(bundles, test_bundles)

-- ─────────────────────────────────────────────────────────────────────────────
-- EXTENDED CLIENT CAPABILITIES
-- ─────────────────────────────────────────────────────────────────────────────
-- jdtls supports features beyond the standard LSP spec (e.g. resolve class paths,
-- decompile .class files, organize imports). We tell it which extras Neovim can
-- handle via extendedClientCapabilities.
local jdtls = require 'jdtls'
local extendedClientCapabilities = jdtls.extendedClientCapabilities
-- actionableRuntimeNotificationIsSupportedNatively: suppresses a popup that asks
-- you to switch JDK versions — jdtls will just use whatever Java is on PATH.
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- ─────────────────────────────────────────────────────────────────────────────
-- ON_ATTACH — runs once per buffer when jdtls connects
-- ─────────────────────────────────────────────────────────────────────────────
-- This is where we set up Java-specific keymaps that are *in addition to* the
-- generic LSP keymaps defined in init.lua's LspAttach autocommand.
local on_attach = function(client, bufnr)
  -- nvim-jdtls ships its own set of code-action shortcuts. This call registers
  -- them. They show up in the which-key menu under <leader>j.
  jdtls.setup_dap { hotcodereplace = 'auto' }
  require('jdtls.dap').setup_dap_main_class_configs()

  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
  end

  -- Organize imports: removes unused imports and sorts the remaining ones.
  -- Super useful — you'd normally do Ctrl+Shift+O in IntelliJ.
  map('<leader>jo', jdtls.organize_imports, '[O]rganize imports')

  -- Extract variable: takes the expression under the cursor and assigns it to
  -- a new local variable. Equivalent to IntelliJ's "Introduce Variable".
  map('<leader>jv', jdtls.extract_variable, 'Extract [V]ariable')

  -- Extract constant: like extract variable, but makes it a static final field.
  map('<leader>jc', jdtls.extract_constant, 'Extract [C]onstant')

  -- Extract method: takes the selected block and turns it into a new method.
  -- Works in both normal mode (whole line) and visual mode (selected lines).
  map('<leader>jm', jdtls.extract_method, 'Extract [M]ethod')
  vim.keymap.set('v', '<leader>jm', function()
    jdtls.extract_method(true) -- true = use visual selection
  end, { buffer = bufnr, desc = 'Java: Extract [M]ethod (visual)' })

  -- Test runner keymaps (only work if vscode-java-test bundle is installed)
  map('<leader>jt', jdtls.test_class, '[T]est class (all tests in file)')
  map('<leader>jn', jdtls.test_nearest_method, 'Test [N]earest method')

  -- Update project config: re-reads build.gradle / pom.xml. Useful when you
  -- add a new dependency and want jdtls to pick it up without restarting.
  map('<leader>ju', jdtls.update_project_config, '[U]pdate project config')
end

-- ─────────────────────────────────────────────────────────────────────────────
-- JDTLS CONFIGURATION
-- ─────────────────────────────────────────────────────────────────────────────
local config = {
  -- cmd: how Neovim launches the jdtls process.
  -- Mason installs the jdtls wrapper script at this path.
  -- The '-data' flag tells jdtls where to store its workspace.
  cmd = {
    vim.fn.expand '~/.local/share/nvim/mason/bin/jdtls',
    '-data', workspace_dir,
  },

  -- root_dir: jdtls needs to know the project root to find all source files.
  -- We look upward from the current file for common Java project markers:
  --   gradlew  → Gradle wrapper (most Android/modern Java projects)
  --   mvnw     → Maven wrapper
  --   pom.xml  → plain Maven project
  --   build.gradle / build.gradle.kts → plain Gradle project
  --   .git     → fallback to git root
  -- vim.fs.find returns the first match; vim.fs.dirname strips the filename.
  root_dir = vim.fs.dirname(
    vim.fs.find({ 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' }, { upward = true })[1]
  ),

  -- on_attach: our custom function defined above.
  on_attach = on_attach,

  -- capabilities: tells jdtls what Neovim + blink.cmp can do (e.g. snippet
  -- completion). We merge blink.cmp's capabilities on top of the defaults.
  capabilities = require('blink.cmp').get_lsp_capabilities(),

  -- init_options: passed to jdtls at startup (before any file is opened).
  init_options = {
    -- bundles: the JAR files for debug adapter + test runner loaded above.
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities,
  },

  -- settings: Java-specific behaviour. These map to jdtls's own settings keys.
  -- Full reference: https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line
  settings = {
    java = {
      -- Download source JARs so you can jump to library source code (e.g.
      -- open ArrayList.java from the JDK), not just decompiled bytecode.
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      gradle = { enabled = true },

      -- When you change build.gradle or pom.xml, ask whether to reload the
      -- project instead of doing it silently ('interactive' | 'automatic' | 'disabled')
      configuration = { updateBuildConfiguration = 'interactive' },

      -- Code lens annotations above methods showing "X references | Y implementations".
      -- Useful at a glance but can slow down large projects.
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },

      -- Include decompiled class files from JARs when searching references.
      references = { includeDecompiledSources = true },

      -- Formatting: let google-java-format (via conform) handle formatting
      -- so we disable jdtls's own formatter to avoid conflicts.
      format = { enabled = false },

      -- Signature help: shows parameter types when you're inside a method call.
      signatureHelp = { enabled = true },

      -- Completion extras: these static members get special treatment in the
      -- autocomplete list (they appear even without an import being present).
      completion = {
        favoriteStaticMembers = {
          'org.junit.Assert.*',
          'org.junit.Assume.*',
          'org.junit.jupiter.api.Assertions.*',
          'org.mockito.Mockito.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
        },
        -- How many completions to show before truncating the list.
        maxResults = 20,
      },

      -- Import organisation: only collapse to a wildcard import (e.g.
      -- "import java.util.*") when there are more than 9999 imports from that
      -- package — effectively disabling wildcard imports so every import stays
      -- explicit.
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },

      -- Code generation templates used when jdtls auto-generates boilerplate.
      codeGeneration = {
        -- toString() template: generates "ClassName{field1=value1, field2=value2}"
        toString = {
          template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
        },
        -- Use braces even for single-statement if/for bodies (style preference).
        useBlocks = true,
      },

      -- Inlay hints: inline type annotations shown in the editor like
      --   String result = getValue()  →  String result = getValue() /*:String*/
      -- Toggle them with <leader>th (defined in init.lua's LspAttach).
      inlayHints = {
        parameterNames = { enabled = 'all' },
      },
    },
  },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- START (OR REATTACH TO) THE SERVER
-- ─────────────────────────────────────────────────────────────────────────────
-- start_or_attach() is smart: if a jdtls instance is already running for this
-- project root, the new buffer just attaches to it instead of spawning another
-- process. This is why jdtls is handled differently from other LSPs — lspconfig
-- doesn't have this "reuse the same server per project root" behaviour built in
-- for jdtls's specific workspace model.
jdtls.start_or_attach(config)
