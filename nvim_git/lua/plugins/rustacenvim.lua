return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
    config = function()
      -- Advanced root detection function
      local function find_rust_project_root(fname)
        local current_dir = fname and vim.fn.fnamemodify(fname, ':h') or vim.fn.getcwd()
        
        -- Start from the file's directory and go up
        local function search_upward(path)
          local cargo_toml = path .. '/Cargo.toml'
          if vim.fn.filereadable(cargo_toml) == 1 then
            return path
          end
          
          local parent = vim.fn.fnamemodify(path, ':h')
          if parent == path then -- reached filesystem root
            return nil
          end
          
          return search_upward(parent)
        end
        
        local root = search_upward(current_dir)
        if root then
          return root
        end
        
        return vim.fn.getcwd() -- ultimate fallback
      end

      vim.g.rustaceanvim = {
        tools = {
          -- Enable hover actions
          hover_actions = {
            auto_focus = false,
          },
          -- Inlay hints
          inlay_hints = {
            auto = true,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
          },
        },
        
        server = {
          on_attach = function(client, bufnr)
            -- Custom on_attach for Rust files
            local opts = { buffer = bufnr, noremap = true, silent = true }
            local keymap = vim.keymap.set
            
            -- Standard LSP keymaps
            keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
            keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
            keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
            keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
            keymap("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
            keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
            keymap("n", "<leader>f", function()
              vim.lsp.buf.format({ async = true })
            end, vim.tbl_extend("force", opts, { desc = "Format code" }))
          end,
          
          -- Custom root directory detection
          root_dir = find_rust_project_root,
          
          default_settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
                allTargets = true, -- Critical for binaries
              },
              checkOnSave = {
                enable = true,
                command = "clippy",
                allTargets = true, -- Check all targets including binaries
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  tokio_macros = { "main" },
                },
              },
              diagnostics = {
                enable = true,
                enableExperimental = false,
                refreshSupport = true,
              },
              assist = {
                importGranularity = "module",
                importPrefix = "by_self",
              },
              lens = {
                enable = true,
                methodReferences = true,
                references = true,
              },
              completion = {
                addCallParenthesis = true,
                addCallArgumentSnippets = true,
                postfix = {
                  enable = true,
                },
              },
              inlayHints = {
                bindingModeHints = {
                  enable = false,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = "never",
                },
                lifetimeElisionHints = {
                  enable = "never",
                  useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = "never",
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },
        },
        
        dap = {
          -- DAP configuration if needed
        },
      }
      
      -- Auto-restart rust-analyzer when opening Rust files from different projects
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.rs",
        callback = function()
          local current_file = vim.fn.expand("%:p")
          if current_file == "" then return end
          
          local expected_root = find_rust_project_root(current_file)
          local clients = vim.lsp.get_clients({ name = "rust_analyzer" })
          
          -- If rust-analyzer is running but with wrong root, restart it
          for _, client in ipairs(clients) do
            if client.config.root_dir ~= expected_root then
              vim.notify("Restarting rust-analyzer for new project: " .. expected_root, vim.log.levels.INFO)
              vim.schedule(function()
                vim.cmd("LspRestart rust_analyzer")
              end)
              break
            end
          end
        end,
      })
    end,
  },
}
