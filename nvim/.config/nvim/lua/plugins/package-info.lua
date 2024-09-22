return {
  "vuki656/package-info.nvim",
  dependencies = "MunifTanjim/nui.nvim", -- Required dependency
  config = function()
    require("package-info").setup({
      -- Optionally configure icons
      icons = {
        enable = true,
        style = {
          up_to_date = "", -- Optional: icon for up-to-date versions
          outdated = "", -- Optional: icon for outdated versions
        },
      },
    })
    -- Show package versions in package.json
    vim.keymap.set("n", "<leader>ns", require("package-info").show, { desc = "Show package versions" })
    -- Hide package versions
    vim.keymap.set("n", "<leader>nc", require("package-info").hide, { desc = "Hide package versions" })
    -- Update a package on the current line
    vim.keymap.set("n", "<leader>nu", require("package-info").update, { desc = "Update package" })
    -- Delete a package
    vim.keymap.set("n", "<leader>nd", require("package-info").delete, { desc = "Delete package" })
    -- Install a new package
    vim.keymap.set("n", "<leader>ni", require("package-info").install, { desc = "Install new package" })
    -- Reinstall all packages
    vim.keymap.set("n", "<leader>nr", require("package-info").reinstall, { desc = "Reinstall all packages" })
    -- Update all packages
    vim.keymap.set("n", "<leader>na", require("package-info").update_all, { desc = "Update all packages" })
  end
}
