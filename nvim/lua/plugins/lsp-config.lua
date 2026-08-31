-- ~/.config/nvim/lua/plugins/mason.lua
return {
  {
    "williamboman/mason.nvim",
    version = "*",
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

      -- Ensure non-LSP tools (formatters) are installed
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs({ "stylua", "prettier", "html-lsp" }) do
          local ok, pkg = pcall(registry.get_package, name)
          if not ok then
            vim.schedule(function()
              vim.notify("mason: unknown package '" .. name .. "'", vim.log.levels.WARN)
            end)
          elseif not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    version = "1.32.0",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- The servers that should always be installed
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "tailwindcss",
          "astro",
          "bashls",
        },
        -- Servers are enabled explicitly via vim.lsp.enable() below
        automatic_enable = false,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Capabilities from nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Helper to register servers
      local function setup(server, opts)
        vim.lsp.config[server] = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
        }, opts or {})
      end

      -- Register servers
      setup("lua_ls")
      setup("ts_ls")
      setup("tailwindcss")
      setup("html")
      setup("astro")
      setup("bashls")
      setup("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {},
        },
      })

      -- Enable servers; nvim auto-starts each on its filetypes and resolves
      -- function-based root_dir (which vim.lsp.start cannot).
      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "tailwindcss",
        "html",
        "astro",
        "bashls",
        "rust_analyzer",
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
        noremap = true,
        silent = true,
        desc = "Show diagnostics in a floating window",
      })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
