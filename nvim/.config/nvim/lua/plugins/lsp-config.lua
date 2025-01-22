return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "tailwindcss",
          "astro",
          "csharp_ls",      -- C# Language Server
          "omnisharp",      -- Another popular C# Language Server
          "bashls"
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
      })
      lspconfig.html.setup({
        capabilities = capabilities,
      })
      lspconfig.astro.setup({
        capabilities = capabilities,
      })
      lspconfig.bashls.setup({
        capabilities = capabilities,
      })
      -- C# Language Server configurations
      lspconfig.csharp_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.omnisharp.setup({
        capabilities = capabilities,
        cmd = { "omnisharp", "--languageserver" },
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
      })

      -- Set up a keybinding for `vim.diagnostic.open_float` in LazyVim
      vim.keymap.set("n", "<leader>e", function()
        vim.diagnostic.open_float()
      end, { noremap = true, silent = true, desc = "Show diagnostics in a floating window" })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
      lspconfig.rust_analyzer.setup({
        -- Server-specific settings. See `:help lspconfig-setup`
        settings = {
          ["rust-analyzer"] = {},
        },
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
