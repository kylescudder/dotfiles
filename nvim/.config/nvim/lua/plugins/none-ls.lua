return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        --require("none-ls.diagnostics.eslint_d"),
        null_ls.builtins.formatting.stylua.with({
          MiniExtra = { "--config-path", vim.fn.stdpath("config") .. "/stylua.toml" },
        }),
        null_ls.builtins.formatting.prettier.with({
          extra_args = {
            "--tab-width", "4",
            "--use-tabs", "true",
          },
          filetypes = {
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "html",
            "css",
            "json",
          },
        }),
      },
    })

    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
  end,
}
