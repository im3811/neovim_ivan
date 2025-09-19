return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  config = function()
    require("marks").setup({
      -- Whether to map keybinds or not
      default_mappings = true,
      
      -- DISABLE showing builtin marks (this stops ., <, >, ^ from showing)
      builtin_marks = {},  -- Empty = don't show any builtin marks
      
      -- Whether movements cycle back to the beginning/end of buffer
      cyclic = true,
      
      -- How often (in ms) to redraw signs/recompute mark positions
      refresh_interval = 150,
      
      -- Sign priorities
      sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
      
      -- IMPORTANT: This makes the actual letter show in the sign column
      signs = true,
      
      -- Exclude numeric marks (0-9) from being shown
      excluded_filetypes = {},
      excluded_buftypes = {},
      
      -- Refresh on these events
      refresh_interval = 250,
      
      mappings = {
        set_next = "m,",          -- Set next available lowercase mark
        toggle = false,           -- Disable toggle to keep default behavior
        next = "]m",             -- Go to next mark  
        prev = "[m",             -- Go to previous mark
        delete_line = "dm-",      -- Delete all marks on current line
        delete_buf = "dm<space>", -- Delete all marks in buffer
      }
    })
    
    -- Set highlight colors for marks (bright orange to stand out)
    vim.api.nvim_set_hl(0, 'MarkSignHL', { fg = '#FF9900', bold = true })
    vim.api.nvim_set_hl(0, 'MarkSignNumHL', { fg = '#FF9900' })
    vim.api.nvim_set_hl(0, 'MarkVirtTextHL', { fg = '#FF9900' })
  end
}
