return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" },
  keys = {
    { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
    { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
    { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
    { "<leader>gP", "<cmd>Git pull<cr>", desc = "Git Pull" },
  },
}
