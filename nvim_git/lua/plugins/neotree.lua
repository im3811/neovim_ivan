return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      window = {
        width = 30,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    })
    
    -- Keybindings - CHANGED TO <leader>n
    vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { 
      desc = 'Toggle file explorer',
      noremap = true,
      silent = true 
    })
    vim.keymap.set('n', '<leader>o', ':Neotree focus<CR>', { 
      desc = 'Focus file explorer',
      noremap = true,
      silent = true 
    })
  end,
}
