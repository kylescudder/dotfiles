return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon.setup({})

    -- Key mappings
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, {
      desc = "Add file to Harpoon",
    })
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, {
       desc = "Open harpoon window"
    })
    vim.keymap.set("n", "<C-1>", function() harpoon:list():select(1) end, {
      desc = "Select first Harpoon file",
    })
    vim.keymap.set("n", "<C-2>", function() harpoon:list():select(2) end, {
      desc = "Select second Harpoon file",
    })
    vim.keymap.set("n", "<C-3>", function() harpoon:list():select(3) end, {
      desc = "Select third Harpoon file",
    })
    vim.keymap.set("n", "<C-4>", function() harpoon:list():select(4) end, {
      desc = "Select fourth Harpoon file",
    })
  end,
}
