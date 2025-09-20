return {
  -- Mason: Package manager for LSP servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  
  -- Mason-LSPConfig: Bridge between Mason and nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "intelephense", -- PHP LSP
          "pyright",      -- Python LSP
          -- rust_analyzer removed - handled by rustaceanvim
        },
        automatic_installation = true,
      })
    end,
  },
  
  -- LSP Configuration using Neovim 0.11+ native API
  {
    "hrsh7th/cmp-nvim-lsp",
    config = function()
      -- Get capabilities for autocompletion
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- Common on_attach function for all LSPs
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
        
        -- Mappings
        local opts = { buffer = bufnr, noremap = true, silent = true }
        local keymap = vim.keymap.set
        
        -- Navigation
        keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
        keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        keymap("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
        
        -- Documentation
        keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        keymap("n", "<leader>sh", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
        
        -- Code actions
        keymap("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
        keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
        
        -- Formatting
        keymap("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "Format code" }))
        
        -- Workspace
        keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
        keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
        keymap("n", "<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))
      end
      
      -- Helper function to find project root
      local function find_root(markers, fname)
        local path = fname
        for _ = 1, 10 do
          for _, marker in ipairs(markers) do
            if vim.fn.filereadable(path .. '/' .. marker) == 1 or
               vim.fn.isdirectory(path .. '/' .. marker) == 1 then
              return path
            end
          end
          local parent = vim.fn.fnamemodify(path, ':h')
          if parent == path then
            break
          end
          path = parent
        end
        return vim.fn.getcwd()
      end
      
      -- Configure PHP LSP (Intelephense)
      vim.lsp.config('intelephense', {
        cmd = { 'intelephense', '--stdio' },
        filetypes = { 'php' },
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return find_root({ 'composer.json', '.git', 'index.php' }, fname)
        end,
        settings = {
          intelephense = {
            files = {
              maxSize = 1000000,
              associations = { "*.php", "*.phtml" },
            },
            environment = {
              includePaths = {},
            },
          },
        },
      })
      
      -- Configure Python LSP (Pyright)
      vim.lsp.config('pyright', {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = function(fname)
          return find_root({
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
            '.git'
          }, fname)
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
            },
          },
        },
      })
      
      -- Rust LSP is now handled by rustaceanvim plugin
      -- No manual rust_analyzer configuration needed
      
      -- Enable the configured LSP servers (rust_analyzer removed)
      vim.lsp.enable('intelephense')
      vim.lsp.enable('pyright')
      
      -- FIXED: Global diagnostics configuration with modern approach
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',
          source = "if_many",
        },
        float = {
          source = "always",
          border = "rounded",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
          },
          linehl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
      
      -- Global diagnostic keymaps (not buffer-specific)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic details" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Set diagnostics to loclist" })
      
      -- Border for hover and signature help
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = "rounded" }
      )
      
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = "rounded" }
      )
    end,
  },
}
