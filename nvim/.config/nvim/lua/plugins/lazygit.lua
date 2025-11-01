return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
  init = function()
    -- example: load two config files (they get merged by lazygit)
    vim.g.lazygit_use_custom_config_file_path = 1
    vim.g.lazygit_config_file_path = {
      vim.fn.expand("~/.config/lazygit/config.yml"),
      vim.fn.expand("~/.config/lazygit/mauve.yml"),
    }
  end,
}
