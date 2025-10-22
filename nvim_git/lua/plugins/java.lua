-- lua/plugins/java.lua
-- Complete Java development setup with LSP and debugging
return {
  -- Java LSP using nvim-jdtls
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local home = os.getenv("HOME")
      local jdtls = require("jdtls")
      local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      
      -- Function to get project name
      local function get_project_name()
        local project_dir = vim.fn.getcwd()
        return vim.fn.fnamemodify(project_dir, ":p:h:t")
      end
      
      -- Function to detect root directory
      local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      if not root_dir then
        root_dir = vim.fn.getcwd()
      end
      
      -- Workspace directory (stores project-specific data)
      local workspace_dir = home .. "/.cache/jdtls/workspace/" .. get_project_name()
      
      -- Create workspace directory if it doesn't exist
      vim.fn.mkdir(workspace_dir, "p")
      
      -- Bundles for debugging
      local bundles = {}
      
      -- Add java-debug-adapter
      local java_debug_path = vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter"
      if vim.fn.isdirectory(java_debug_path) then
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1), "\n"))
      end
      
      -- Add java-test for running tests
      local java_test_path = vim.fn.stdpath("data") .. "/mason/packages/java-test"
      if vim.fn.isdirectory(java_test_path) then
        vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))
      end
      
      -- JDTLS configuration
      local config = {
        cmd = {
          -- Use the system Java 21
          "/usr/bin/java",
          
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          
          "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration", jdtls_path .. "/config_linux",
          "-data", workspace_dir,
        },
        
        root_dir = root_dir,
        
        -- LSP settings
        settings = {
          java = {
            -- No need to specify home since we're using system Java
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
              -- Define Java 21 runtime
              runtimes = {
                {
                  name = "JavaSE-21",
                  path = "/usr/lib/jvm/java-21-openjdk",
                },
              },
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            -- DISABLE inlay hints to prevent errors
            inlayHints = {
              parameterNames = {
                enabled = "none",  -- Changed from "all" to "none"
              },
            },
            format = {
              enabled = true,
            },
            signatureHelp = {
              enabled = true,
            },
            contentProvider = {
              preferred = "fernflower",
            },
            completion = {
              favoriteStaticMembers = {
                "org.hamcrest.MatcherAssert.assertThat",
                "org.hamcrest.Matchers.*",
                "org.hamcrest.CoreMatchers.*",
                "org.junit.jupiter.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
                "org.mockito.Mockito.*",
              },
              importOrder = {
                "java",
                "javax",
                "com",
                "org"
              },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              useBlocks = true,
            },
          },
        },
        
        -- Completion capabilities
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        
        -- Handlers
        handlers = {
          ["language/status"] = function()
            -- Ignore status updates
          end,
          ["$/progress"] = function()
            -- Ignore progress updates or handle them if you want
          end,
        },
        
        -- Enable debugging
        init_options = {
          bundles = bundles,
          extendedClientCapabilities = {
            progressReportProvider = false,
            classFileContentsSupport = true,
            generateToStringPromptSupport = true,
            hashCodeEqualsPromptSupport = true,
            advancedExtractRefactoringSupport = true,
            advancedOrganizeImportsSupport = true,
            generateConstructorsPromptSupport = true,
            generateDelegateMethodsPromptSupport = true,
            moveRefactoringSupport = true,
            overrideMethodsPromptSupport = true,
            inferSelectionSupport = {"extractMethod", "extractVariable", "extractConstant", "extractInterface"},
          },
        },
        
        on_attach = function(client, bufnr)
          -- Enable completion
          vim.api.nvim_set_option_value('omnifunc', 'v:lua.vim.lsp.omnifunc', { buf = bufnr })
          
          -- Java-specific keymaps
          local opts = { buffer = bufnr, noremap = true, silent = true }
          local keymap = vim.keymap.set
          
          -- Standard LSP mappings
          keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
          keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
          keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
          keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
          keymap("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
          keymap("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
          keymap("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, vim.tbl_extend("force", opts, { desc = "Format code" }))
          
          -- Java-specific commands
          keymap("n", "<leader>jo", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
          keymap("n", "<leader>jv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
          keymap("n", "<leader>jc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
          keymap("n", "<leader>jm", jdtls.extract_method, vim.tbl_extend("force", opts, { desc = "Extract method" }))
          
          -- Visual mode extractions
          keymap("v", "<leader>jv", function()
            jdtls.extract_variable(true)
          end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
          keymap("v", "<leader>jc", function()
            jdtls.extract_constant(true)
          end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
          keymap("v", "<leader>jm", function()
            jdtls.extract_method(true)
          end, vim.tbl_extend("force", opts, { desc = "Extract method" }))
          
          -- Test runner commands
          keymap("n", "<leader>jt", jdtls.test_nearest_method, vim.tbl_extend("force", opts, { desc = "Test nearest method" }))
          keymap("n", "<leader>jT", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "Test class" }))
          
          -- Debug commands
          keymap("n", "<leader>jd", function()
            jdtls.test_nearest_method({ config = { console = "internalConsole" } })
          end, vim.tbl_extend("force", opts, { desc = "Debug nearest test" }))
          
          -- Setup DAP (Debug Adapter Protocol)
          jdtls.setup_dap({ hotcodereplace = "auto" })
          require("jdtls.dap").setup_dap_main_class_configs()
          
          -- DO NOT enable inlay hints - they cause errors
          -- Inlay hints disabled to prevent "col out of range" errors
        end,
      }
      
      -- Start or attach JDTLS
      jdtls.start_or_attach(config)
    end,
  },
  
  -- Mason setup to install Java tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls",               -- Java LSP
        "java-debug-adapter",  -- Java DAP
        "java-test",          -- Java test runner
      },
    },
  },
  
  -- Java debugging configuration
  {
    "mfussenegger/nvim-dap",
    ft = { "java" },
    config = function()
      local dap = require("dap")
      
      -- Java DAP configuration (handled by jdtls)
      dap.configurations.java = {
        {
          type = "java",
          request = "launch",
          name = "Launch",
          program = "${file}",
        },
        {
          type = "java",
          request = "launch", 
          name = "Launch with Arguments",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input("Program arguments: ")
            return vim.split(args_string, " ")
          end,
        },
        {
          type = "java",
          request = "launch",
          name = "Launch Main Class",
          mainClass = function()
            return vim.fn.input("Main class (e.g., com.example.Main): ")
          end,
        },
        {
          type = "java",
          request = "attach",
          name = "Attach to Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
  },
}
