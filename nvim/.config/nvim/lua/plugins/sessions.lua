return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      session_lens = {
        -- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
        load_on_setup = true,
        previewer = false,
        -- Can also set some Telescope picker options
        -- For all options, see: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
        theme_conf = {
          border = true,
          -- layout_config = {
          --   width = 0.8, -- Can set width and height as percent of window
          --   height = 0.5,
          -- },
        },
      },
      vim.keymap.set("n", "<leader>ls", require("auto-session.session-lens").search_session, {
        noremap = true,
      }),
    })
  end,
}
