return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {},
  config = function()
    -- Set the highlight color to #BFBFBF
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#BFBFBF" })
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#BFBFBF" })
    
    require("ibl").setup({
      indent = {
        char = "│",  -- The character for indent lines
        -- You can also try: "┊", "┆", "¦", "│", "▏"
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
    })
  end,
}
