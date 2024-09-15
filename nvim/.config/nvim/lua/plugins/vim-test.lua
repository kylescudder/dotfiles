return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux"
  },
  vim.keymap.set('leader>t', ':TestNearest<CR>'),
  vim.keymap.set('leader>T', ':TestFile<CR>'),
  vim.keymap.set('leader>a', ':TestSuite<CR>'),
  vim.keymap.set('leader>l', ':TestLast<CR>'),
  vim.keymap.set('leader>g', ':TestVisit<CR>'),
  vim.cmd("let test#strategy = 'vimux'")
}
