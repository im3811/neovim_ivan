
return {
-- Main completion engine 
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", --LSP completions
      "hrsh7th/cmp-buffer",   -- Buffer completions
      "hrsh7th/cmp-path",     -- Path completions
      "L3MON4D3/LuaSnip",     -- Snippet engine
      "saadparwaiz1/cmp_luasnip", --Snippet completions
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,

  },

      mapping = cmp.mapping.preset.insert({

        -- Navigate completion menu
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),


        -- Scroll documentation
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),

        -- Trigger completion
        ["<C-Space>"] = cmp.mapping.complete(),

        -- Cancel completion
        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirm selection 
        ["<CR>"] = cmp.mapping.confirm({ select = true}),

        -- Tab for completion and snipper jumping 
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else 
            fallback()
          end
        end, {"i", "s" }),


        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else 
            fallback()
          end
        end, {"i", "s"}),

}),

sources = cmp.config.sources({
  { name = "nvim_lsp" }, --LSP completions (PHP functions, classes, etc.)
  { name = "luasnip" },  --Snippet completions
}, {
  {name = "buffer" },   -- Buffer text completions
  {name = "path" },     -- File path completions
}),
  

  --Completion window appearance
window = {
  completion = cmp.config.window.bordered(),
  documentation = cmp.config.window.bordered(),

},

-- Add icons to completion items  
  formatting = {

    format = function(entry, vim_item)
      -- Set icons  for different completion sources
      local icons = {
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
      }

      vim_item.menu = icons[entry.source.name] or "[Unknown]"
      return vim_item
    end,
  },
})
end,
},
}




