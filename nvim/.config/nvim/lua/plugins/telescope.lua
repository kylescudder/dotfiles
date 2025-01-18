return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden", -- Add this line to include hidden files in the search
          },
          -- other Telescope setup options here
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.85, -- Adjust the height of the floating window
          width = 0.80,  -- Adjust the width of the floating window
          row = 0.35,    -- Adjust the row position
          col = 0.50,    -- Adjust the column position
        },
         grep = {
          rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case",
        },       -- other fzf-lua setup options here
      })
      vim.keymap.set("n", "<C-p>", ":FzfLua files<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fg", ":FzfLua grep<CR>", { noremap = true, silent = true })
    end,
  },
}
