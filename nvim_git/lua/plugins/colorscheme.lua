return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      -- Enable transparent background to show your cityscape wallpaper
      transparent_mode = true,
      
      -- Override the specific purple colors in the palette
      palette_overrides = {
        bright_purple = "#C4C3D0",  -- Replace bright purple with lavender grey
        neutral_purple = "#C4C3D0", -- Replace neutral purple with lavender grey
        
        -- Use #1A1D1E for UI elements that need a background
        dark1 = "#1A1D1E",          -- Sidebar backgrounds
        dark2 = "#1A1D1E",          -- Popup backgrounds
      },
    })
    
    vim.cmd("colorscheme gruvbox")
  end,
}
