return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Git History" },
    { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
    })
  end,
}
