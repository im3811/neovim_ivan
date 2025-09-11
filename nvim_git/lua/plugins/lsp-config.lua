return {
  -- Mason: Package manager for LSP servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  --Mason-LSPConfig: Bridge between Mason and nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" }, 
    config = function()
      require("mason-lspconfig").setup({
      ensure_installed = {
        "intelephense", -- PHP LSP
        "pyright",      -- Python LSP
      },
      automatic_installation = true,
    })
  end,
  },
  
  -- nvim-lspconfig: Configure LSP servers
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- Autocompletion
    },
    config = function() 
      local lspconfig = require("lspconfig")
      -- Get capabilities for autocompletion
      local capabilities = require("cmp_nvim_lsp").default_capabilities() 
      -- Setup PHP LSP (Intelephense)
      lspconfig.intelephense.setup ({ 
        capabilities = capabilities, 

        root_dir = function (fname)
          return lspconfig.util.root_pattern("composer.json", ".git", "index.php")(fname)
            or lspconfig.util.path.dirname(fname)
        end,
        settings = {
          intelephense = {
            files = {
              maxSize = 1000000,
              associations = {"*.php", "*.phtml"},
            },
            environment = {
              includePaths = {},
            },
          },
        },
          }) 

          lspconfig.pyright.setup({
            capabilities = capabilities,
            settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        })

  
      -- PHP LSP keymaps
      local keymap = vim.keymap
      -- Navigation 
      keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" }) 
      
      -- Documentation
      keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
      
      -- Code actions 
      keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      -- Formatting 
      keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format PHP code" })
      -- Diagnostics (errors/warnings)
      keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous error" }) 
      keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next error" })
      -- Show error details 
      keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error details" }) 
    end,
    },
}
