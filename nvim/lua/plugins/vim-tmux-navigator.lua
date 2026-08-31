return {
  "christoomey/vim-tmux-navigator",
  config = function()
    local function nav(win, dir)
      return function()
        local prev = vim.api.nvim_get_current_win()
        vim.cmd.wincmd(win)
        if vim.api.nvim_get_current_win() == prev then
          vim.system({ "herdr", "pane", "focus", "--direction", dir, "--current" })
        end
      end
    end
    for k, m in pairs({
      ["<C-h>"] = { "h", "left" },
      ["<C-j>"] = { "j", "down" },
      ["<C-k>"] = { "k", "up" },
      ["<C-l>"] = { "l", "right" },
    }) do
      vim.keymap.set("n", k, nav(m[1], m[2]), { desc = "herdr nav " .. m[2] })
    end
  end,
}
