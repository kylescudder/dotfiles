-- ~/.config/nvim/lua/plugins/mason.lua
return {
  {
    "williamboman/mason.nvim",
    version = "*",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })
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
          "csharp_ls",
          "omnisharp",
          "bashls",
        },
        -- Automatically install any LSPs you set up via lspconfig below
        automatic_enable = true,
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
      setup("csharp_ls")
      setup("omnisharp", {
        cmd = { "omnisharp", "--languageserver" },
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
      })
      setup("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {},
        },
      })

      -- Auto-start configured servers when entering buffers with matching filetypes
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lsp_autostart", { clear = true }),
        pattern = "*",
        callback = function()
          local ft = vim.bo.filetype

          -- Manually map filetypes → LSP server names
          local ft_to_server = {
            typescript = "ts_ls",
            typescriptreact = "ts_ls",
            javascript = "ts_ls",
            javascriptreact = "ts_ls",
            lua = "lua_ls",
            rust = "rust_analyzer",
            bash = "bashls",
            sh = "bashls",
            csharp = "csharp_ls",
            html = "html",
            astro = "astro",
            css = "tailwindcss",
          }

          local server = ft_to_server[ft] -- will be nil if not mapped
          if server and vim.lsp.config[server] then
            -- start client if not already running
            vim.lsp.start(vim.lsp.config[server])
          end
        end,
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
