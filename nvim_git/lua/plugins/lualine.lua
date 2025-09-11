return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Custom transparent theme
    local custom_transparent = require('lualine.themes.auto')

    -- Make all backgrounds transparent
    custom_transparent.normal.c.bg = 'None'
    custom_transparent.normal.a.bg = 'None'
    custom_transparent.normal.b.bg = 'None'
    custom_transparent.insert.a.bg = 'None'
    custom_transparent.insert.b.bg = 'None'
    custom_transparent.insert.c.bg = 'None'
    custom_transparent.visual.a.bg = 'None'
    custom_transparent.visual.b.bg = 'None'
    custom_transparent.visual.c.bg = 'None'
    custom_transparent.replace.a.bg = 'None'
    custom_transparent.replace.b.bg = 'None'
    custom_transparent.replace.c.bg = 'None'
    custom_transparent.command.a.bg = 'None'
    custom_transparent.command.b.bg = 'None'
    custom_transparent.command.c.bg = 'None'
    custom_transparent.inactive.a.bg = 'None'
    custom_transparent.inactive.b.bg = 'None'
    custom_transparent.inactive.c.bg = 'None'

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = custom_transparent,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        always_divide_middle = true,
        globalstatus = true,
      },

      -- Status line with gruvbox colors
      sections = {
        lualine_a = {
          {
            'mode',
            color = { fg = '#689d6a', gui = 'bold' },
            fmt = function(str)
              return str:sub(1, 1)
            end,
          }
        },
        lualine_b = {
          {
            'branch',
            icon = '',
            color = { fg = '#fabd2f' },
          },
          {
            'diff',
            symbols = { added = '+', modified = '~', removed = '-' },
            diff_color = {
              added = { fg = '#b8bb26' },
              modified = { fg = '#fabd2f' },
              removed = { fg = '#fb4934' },
            },
          }
        },
        lualine_c = {
          {
            'filename',
            path = 1,
            color = { fg = '#ebdbb2' },
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
            }
          }
        },
        lualine_x = {
          {
            'diagnostics',
            sources = { 'nvim_lsp' },
            symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            diagnostics_color = {
              error = { fg = '#fb4934' },
              warn = { fg = '#fabd2f' },
              info = { fg = '#83a598' },
              hint = { fg = '#689d6a' },
            },
          },
          {
            'filetype',
            color = { fg = '#d3869b' },
          }
        },
        lualine_y = {
          {
            'progress',
            color = { fg = '#a89984' },
          }
        },
        lualine_z = {
          {
            'location',
            color = { fg = '#689d6a' },
          }
        }
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },

      -- Tabline with no truncation
      tabline = {
        lualine_a = {
          {
            'buffers',
            show_filename_only = true,
            hide_filename_extension = false,
            show_modified = true,
            mode = 2,
            max_length = vim.o.columns,  -- Use full width
            
            -- Use vertical bars as separators
            component_separators = {
              left = '',
              right = ''
            },
            
            symbols = {
              modified = ' ●',
              alternate_file = '',
              directory = '',
            },
            
            -- Colors with transparent background
            buffers_color = {
              -- Active tab: orange text with transparent bg
              active = {
                fg = '#FF9900',   -- Orange text
                bg = 'NONE',      -- Transparent background
                gui = 'bold',
              },
              -- Inactive tabs: gray text
              inactive = {
                fg = '#606060',   -- Dimmed gray
                bg = 'NONE',      -- Transparent
              },
            },
            
            -- Custom formatter without truncation
            fmt = function(name, context)
              local filename = vim.fn.fnamemodify(name, ':t')
              -- No truncation - show full filename
              
              -- For active buffer
              if context.current then
                return filename
              else
                return '  ' .. filename .. '  '
              end
            end,
          }
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },

      extensions = {}
    }
    
    -- Custom highlight groups without underline
    vim.api.nvim_create_autocmd({"VimEnter", "ColorScheme"}, {
      callback = function()
        vim.defer_fn(function()
          -- Active buffer with orange coloring (NO underline)
          vim.api.nvim_set_hl(0, 'lualine_a_buffers_active', { 
            fg = '#FF9900',     -- Orange text
            bg = 'NONE',        -- Transparent background
            bold = true,
            -- Removed: underline = true,
            -- Removed: sp = '#FF9900'
          })
          
          -- Inactive buffers
          vim.api.nvim_set_hl(0, 'lualine_a_buffers_inactive', { 
            fg = '#606060',
            bg = 'NONE'
          })
        end, 10)
      end
    })
    
    -- Apply immediately (NO underline)
    vim.api.nvim_set_hl(0, 'lualine_a_buffers_active', { 
      fg = '#FF9900',
      bg = 'NONE',
      bold = true,
      -- Removed: underline = true,
      -- Removed: sp = '#FF9900'
    })
    vim.api.nvim_set_hl(0, 'lualine_a_buffers_inactive', { 
      fg = '#606060',
      bg = 'NONE'
    })
  end,
}
