-- lua/custom/plugins/java-kotlin.lua
--
-- This file declares the plugins needed for Java and Kotlin IDE support.
-- Neovim's lazy.nvim plugin manager picks up every file under
-- lua/custom/plugins/ automatically (see init.lua: `{ import = 'custom.plugins' }`).

return {

  -- ───────────────────────────────────────────────────────────────────────────
  -- JAVA: nvim-jdtls
  -- ───────────────────────────────────────────────────────────────────────────
  -- nvim-jdtls wraps the Eclipse JDT Language Server (jdtls) with extra
  -- features that plain lspconfig cannot provide:
  --
  --   • Per-project workspace directories (jdtls requirement)
  --   • Java-specific code actions: organize imports, extract variable/method
  --   • DAP (debugger) integration via java-debug-adapter
  --   • Test runner integration via vscode-java-test
  --   • Hot code replacement during debug sessions
  --
  -- The actual jdtls configuration lives in ftplugin/java.lua, which Neovim
  -- sources automatically whenever a .java file is opened.
  -- We only declare the plugin here so lazy.nvim installs it.
  {
    'mfussenegger/nvim-jdtls',

    -- ft = 'java': lazy-load this plugin — only load it when you open a Java
    -- file. This keeps startup time fast for non-Java work.
    ft = 'java',
  },

  -- ───────────────────────────────────────────────────────────────────────────
  -- KOTLIN: kotlin-lsp (JetBrains, IntelliJ-based) via lspconfig
  -- ───────────────────────────────────────────────────────────────────────────
  -- Kotlin support is handled by JetBrains' kotlin-lsp (Mason package
  -- 'kotlin-lsp', binary `intellij-server`), enabled through mason-lspconfig.
  -- We configure it in init.lua's `servers` table (see the comment there for
  -- why we moved off the lightweight fwcd kotlin-language-server).
  --
  -- Nothing else to declare here for Kotlin — lspconfig handles the rest.
}
