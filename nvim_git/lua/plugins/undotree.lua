return {
  "mbbill/undotree",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
  },
  config = function()
    -- Optional configuration
    vim.g.undotree_WindowLayout = 2        -- Layout style
    vim.g.undotree_SplitWidth = 35         -- Width of undo tree window
    vim.g.undotree_SetFocusWhenToggle = 1  -- Focus the undo tree when opened
    vim.g.undotree_ShortIndicators = 1     -- Use short time indicators
    vim.g.undotree_DiffpanelHeight = 15    -- Height of diff panel
    
    -- Enable persistent undo if not already set
    vim.opt.undofile = true
    vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
    
    -- Create undodir if it doesn't exist
    local undodir = vim.fn.expand("~/.vim/undodir")
    if vim.fn.isdirectory(undodir) == 0 then
      vim.fn.mkdir(undodir, "p")
    end
  end,
}
