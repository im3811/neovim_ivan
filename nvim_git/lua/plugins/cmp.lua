
-- Add this to your plugins configuration (in your lazy.nvim setup)
return {
  -- Autocompletion plugin
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP completion source
      "hrsh7th/cmp-buffer",        -- Buffer completion source
      "hrsh7th/cmp-path",          -- Path completion source
      "L3MON4D3/LuaSnip",         -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completion source
      "rafamadriz/friendly-snippets", -- Useful snippets
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      -- Load friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),  -- Manually trigger completion
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP completions (highest priority)
          { name = "luasnip" },    -- Snippets
        }, {
          { name = "buffer" },     -- Buffer completions (lower priority)
          { name = "path" },       -- File path completions
        }),
        -- Make completion menu behavior more like VS Code
        completion = {
          completeopt = "menu,menuone,noinsert",
          keyword_length = 1,  -- Start suggesting after 1 character
        },
        experimental = {
          ghost_text = true,  -- Show preview of completion as ghost text
        },
      })
      
      -- Set configuration for specific filetypes
      cmp.setup.filetype("rust", {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },  -- Prioritize LSP for Rust
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        })
      })
    end,
  },
}
