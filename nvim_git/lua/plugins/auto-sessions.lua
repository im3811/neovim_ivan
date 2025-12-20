return {
  'rmagatti/auto-session',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require("auto-session").setup({
      log_level = "error",
      auto_session_suppress_dirs = { 
        "~/", 
        "~/Downloads", 
        "/tmp" 
      },
      auto_session_use_git_branch = false,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      
      -- Don't use session_lens - it's causing the error
    })
    
    -- Simple keymaps without session-lens
    vim.keymap.set("n", "<leader>ss", ":SessionSave<CR>", {
      noremap = true,
      desc = "Save session"
    })
    
    vim.keymap.set("n", "<leader>sd", ":SessionDelete<CR>", {
      noremap = true,
      desc = "Delete session"
    })
    
    vim.keymap.set("n", "<leader>sr", ":SessionRestore<CR>", {
      noremap = true,
      desc = "Restore session"
    })
    
    -- Use telescope to search sessions manually
    vim.keymap.set("n", "<leader>sf", function()
      require("telescope.builtin").find_files({
        prompt_title = "Sessions",
        cwd = vim.fn.stdpath("data") .. "/sessions/",
      })
    end, {
      noremap = true,
      desc = "Find sessions"
    })
  end,
}
