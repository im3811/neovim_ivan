return {
  -- Main completion engine 
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Essential completion sources
      "hrsh7th/cmp-nvim-lsp",              -- LSP completions
      "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signatures with current parameter emphasized
      "hrsh7th/cmp-buffer",                -- Buffer completions
      "hrsh7th/cmp-path",                  -- Path completions
      "hrsh7th/cmp-nvim-lua",              -- Neovim Lua API completions
      
      -- Snippet support (using LuaSnip)
      "L3MON4D3/LuaSnip",                  -- Snippet engine
      "saadparwaiz1/cmp_luasnip",          -- Snippet completions
      "rafamadriz/friendly-snippets",      -- Collection of snippets
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
        
        -- AUTO-TRIGGER COMPLETION - Essential for auto-popup!
        completion = {
          autocomplete = { 
            require("cmp.types").cmp.TriggerEvent.TextChanged,
          },
          completeopt = "menu,menuone,noselect",
        },

        mapping = cmp.mapping.preset.insert({
          -- Navigate completion menu
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),

          -- Scroll documentation
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),

          -- Trigger completion manually (if needed)
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Cancel completion
          ["<C-e>"] = cmp.mapping.close(),

          -- Confirm selection 
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),

          -- Tab for completion and snippet jumping 
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else 
              fallback()
            end
          end, {"i", "s"}),

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

        -- Installed sources (ORDER MATTERS!)
        sources = {
          { name = 'path' },                              -- file paths
          { name = 'nvim_lsp', keyword_length = 1 },      -- from language server
          { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
          { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
          { name = 'buffer', keyword_length = 2 },        -- source current buffer
          { name = 'luasnip', keyword_length = 2 },       -- nvim-cmp source for luasnip
          { name = 'calc'},                              -- source for math calculation
        },

        -- Completion window appearance
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        -- Formatting with icons and source labels
        formatting = {
          fields = {'menu', 'abbr', 'kind'},
          format = function(entry, item)
            -- Kind icons
            local kind_icons = {
              Text = "󰉿",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰜢",
              Variable = "󰀫",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "󰙅",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "",
            }
            
            -- Menu icons for sources
            local menu_icon = {
              nvim_lsp = 'λ',
              nvim_lua = '🌙',
              luasnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
              nvim_lsp_signature_help = '🖊',
            }
            
            item.menu = menu_icon[entry.source.name]
            item.kind = string.format("%s %s", kind_icons[item.kind] or "", item.kind)
            
            return item
          end,
        },
      })
    end,
  },
  
  -- Add friendly snippets collection
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },
}
