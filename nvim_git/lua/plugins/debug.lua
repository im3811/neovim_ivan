return {
  -- Debug Adapter Protocol client
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
  },

  -- Debug UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup dapui
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

      -- Auto open/close UI and enable/disable touchpad
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        -- Enable touchpad when debugging starts
        if _G.enable_touchpad then
          _G.enable_touchpad()
          vim.notify("Debug mode: Touchpad enabled", vim.log.levels.INFO)
        end
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        -- Disable touchpad when debugging ends
        if _G.disable_touchpad then
          _G.disable_touchpad()
          vim.notify("Debug ended: Touchpad disabled", vim.log.levels.INFO)
        end
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        -- Disable touchpad when debugging exits
        if _G.disable_touchpad then
          _G.disable_touchpad()
          vim.notify("Debug ended: Touchpad disabled", vim.log.levels.INFO)
        end
      end
    end,
  },

  -- Virtual text support
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = '<module',
        virt_text_pos = 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      })
    end,
  },

  -- Python-specific debug adapter
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap_python = require("dap-python")

      -- Setup debugpy (you'll need to install this)
      dap_python.setup("python") -- Use system python, or specify path like "/usr/bin/python3"

      -- Configure Python debugging
      local dap = require("dap")

      -- Python debug configuration
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "/usr/bin/python3" -- Adjust path as needed
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file with arguments",
          program = "${file}",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " ")
          end,
          pythonPath = function()
            return "/usr/bin/python3"
          end,
        },
        {
          type = "python",
          request = "attach",
          name = "Attach remote",
          connect = function()
            local host = vim.fn.input("Host [127.0.0.1]: ")
            host = host ~= "" and host or "127.0.0.1"
            local port = tonumber(vim.fn.input("Port [5678]: ")) or 5678
            return { host = host, port = port }
          end,
        },
      }
    end,
  },

  -- PHP Debug Configuration
  {
    "mfussenegger/nvim-dap",
    ft = { "php" },
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      
      -- PHP adapter configuration
      dap.adapters.php = {
        type = "executable",
        command = "node",
        -- You need to install vscode-php-debug
        -- Mason will install it to: ~/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js
        args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" }
      }
      
      -- PHP debug configurations
      dap.configurations.php = {
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug (9003)",
          port = 9003,  -- Modern Xdebug uses port 9003 by default
          pathMappings = {
            -- Adjust these mappings based on your setup
            -- ["/var/www/html"] = "${workspaceFolder}",
          },
          log = false,
          -- serverSourceRoot = "/var/www/html",  -- Uncomment if using Docker
          -- localSourceRoot = "${workspaceFolder}",  -- Uncomment if using Docker
        },
        {
          type = "php",
          request = "launch",
          name = "Listen for Xdebug (9000)",
          port = 9000,  -- Legacy Xdebug port
          pathMappings = {
            -- ["/var/www/html"] = "${workspaceFolder}",
          },
          log = false,
        },
        {
          type = "php",
          request = "launch",
          name = "Launch currently open script",
          program = "${file}",
          cwd = "${fileDirname}",
          port = 9003,
          runtimeArgs = {
            "-dxdebug.mode=debug",
            "-dxdebug.start_with_request=yes",
            "-dxdebug.client_port=9003"
          },
          runtimeExecutable = "php",
        },
        {
          type = "php",
          request = "launch",
          name = "Launch with built-in server",
          program = "${file}",
          cwd = "${fileDirname}",
          port = 9003,
          runtimeArgs = {
            "-dxdebug.mode=debug",
            "-dxdebug.start_with_request=yes",
            "-dxdebug.client_port=9003",
            "-S",
            "localhost:8000"
          },
          runtimeExecutable = "php",
          serverReadyAction = {
            pattern = "Development Server \\(http://localhost:([0-9]+)\\) started",
            uriFormat = "http://localhost:%s",
            action = "openExternally"
          },
        },
      }
    end,
  },

  -- Rust Debug Configuration
  {
    "mfussenegger/nvim-dap",
    ft = { "rust" },
    config = function()
      local dap = require("dap")
      
      -- Rust adapter using CodeLLDB
      dap.adapters.codelldb = {
        type = 'server',
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
          args = {"--port", "${port}"},
        }
      }
      
      -- Alternative: Using lldb-vscode (fallback)
      dap.adapters.lldb = {
        type = 'executable',
        command = '/usr/bin/lldb-vscode', -- Adjust path as needed
        name = 'lldb'
      }
      
      -- Rust configurations
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            -- First try to find the binary in target/debug
            local cwd = vim.fn.getcwd()
            local cargo_toml = vim.fn.findfile("Cargo.toml", cwd .. ";")
            
            if cargo_toml ~= "" then
              -- Parse Cargo.toml to find binary name
              local project_root = vim.fn.fnamemodify(cargo_toml, ":h")
              local handle = io.popen("cd " .. project_root .. " && cargo metadata --no-deps --format-version 1 | grep '\"name\"' | head -1")
              if handle then
                local result = handle:read("*a")
                handle:close()
                local pkg_name = result:match('"name"%s*:%s*"([^"]+)"')
                if pkg_name then
                  local binary_path = project_root .. "/target/debug/" .. pkg_name
                  if vim.fn.filereadable(binary_path) == 1 then
                    return binary_path
                  end
                end
              end
            end
            
            -- Fallback: ask user for binary path
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
          end,
          runInTerminal = false,
          -- Environment variables
          env = function()
            local variables = {}
            for k, v in pairs(vim.fn.environ()) do
              table.insert(variables, string.format("%s=%s", k, v))
            end
            return variables
          end,
        },
        {
          name = "Launch (from cargo)",
          type = "codelldb",
          request = "launch",
          program = function()
            os.execute("cargo build")
            local handle = io.popen("cargo metadata --no-deps --format-version 1 | grep '\"name\"' | head -1")
            if handle then
              local result = handle:read("*a")
              handle:close()
              local pkg_name = result:match('"name"%s*:%s*"([^"]+)"')
              if pkg_name then
                return vim.fn.getcwd() .. "/target/debug/" .. pkg_name
              end
            end
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          runInTerminal = false,
        },
        {
          name = "Launch test",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Build tests first
            os.execute("cargo test --no-run")
            -- Find the test binary
            local handle = io.popen("find target/debug/deps -type f -executable -name '*-*' | head -1")
            if handle then
              local result = handle:read("*a"):gsub("\n", "")
              handle:close()
              if result ~= "" then
                return result
              end
            end
            return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/target/debug/deps/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {"--nocapture"},
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require('dap.utils').pick_process,
          args = {},
        },
      }
    end,
  },

  -- Mason DAP to automatically install debug adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { 
          "python",           -- Python debugger (debugpy)
          "php",              -- PHP debugger (vscode-php-debug)
          "codelldb",         -- Rust/C/C++ debugger
          "java-debug-adapter", -- Java debugger
          "java-test",        -- Java test runner
        },
        automatic_installation = true,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
          -- PHP needs special handling for the path
          php = function(config)
            config.adapters = {
              type = "executable",
              command = "node",
              args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" }
            }
            require("mason-nvim-dap").default_setup(config)
          end,
          -- Rust/CodeLLDB handling
          codelldb = function(config)
            config.adapters = {
              type = 'server',
              port = "${port}",
              executable = {
                command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
                args = {"--port", "${port}"},
              }
            }
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })
    end,
  },

  -- Global keymappings for debugging (works for all languages)
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle breakpoint"
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Set conditional breakpoint"
      },
      {
        "<leader>dc",
        function() require("dap").continue() end,
        desc = "Continue/Start debugging"
      },
      {
        "<leader>ds",
        function() require("dap").step_over() end,
        desc = "Step over"
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc = "Step into"
      },
      {
        "<leader>do",
        function() require("dap").step_out() end,
        desc = "Step out"
      },
      {
        "<leader>du",
        function() require("dapui").toggle() end,
        desc = "Toggle debug UI"
      },
      {
        "<leader>dr",
        function() require("dap").repl.open() end,
        desc = "Open debug REPL"
      },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc = "Run last debug session"
      },
      {
        "<leader>dt",
        function() require("dap").terminate() end,
        desc = "Terminate debug session"
      },
      {
        "<leader>de",
        function() require("dapui").eval() end,
        desc = "Evaluate selection",
        mode = "v"
      },
      -- Python-specific
      {
        "<leader>dpy",
        function() require("dap-python").test_method() end,
        desc = "Debug Python test method",
        ft = "python"
      },
      {
        "<leader>dpc",
        function() require("dap-python").test_class() end,
        desc = "Debug Python test class",
        ft = "python"
      },
      -- PHP-specific helper to start debugging
      {
        "<leader>dph",
        function()
          -- Prompt for Xdebug session
          vim.notify("Starting PHP Debug Session - Make sure Xdebug is configured!", vim.log.levels.INFO)
          require("dap").continue()
        end,
        desc = "Start PHP debugging session",
        ft = "php"
      },
      -- Rust-specific debugging commands
      {
        "<leader>drs",
        function()
          -- Build and debug current Rust project
          vim.notify("Building Rust project...", vim.log.levels.INFO)
          vim.fn.system("cargo build")
          vim.notify("Starting Rust debugger", vim.log.levels.INFO)
          require("dap").continue()
        end,
        desc = "Build and debug Rust project",
        ft = "rust"
      },
      {
        "<leader>drt",
        function()
          -- Debug Rust tests
          vim.notify("Building tests...", vim.log.levels.INFO)
          vim.fn.system("cargo test --no-run")
          vim.notify("Starting test debugger", vim.log.levels.INFO)
          require("dap").continue()
        end,
        desc = "Debug Rust tests",
        ft = "rust"
      },
      -- Java-specific debugging commands
      {
        "<leader>djr",
        function()
          -- Run Java file
          local file = vim.fn.expand("%")
          local class_name = vim.fn.expand("%:t:r")
          vim.notify("Compiling and debugging Java...", vim.log.levels.INFO)
          vim.fn.system("javac " .. file)
          require("dap").continue()
        end,
        desc = "Debug Java file",
        ft = "java"
      },
      {
        "<leader>djt",
        function()
          -- Debug Java test
          if vim.fn.exists(":JdtTestClass") > 0 then
            vim.cmd("JdtTestClass")
          else
            vim.notify("Java test debugging requires active JDTLS", vim.log.levels.WARN)
          end
        end,
        desc = "Debug Java test class",
        ft = "java"
      },
      {
        "<leader>djm",
        function()
          -- Debug Java test method
          if vim.fn.exists(":JdtTestMethod") > 0 then
            vim.cmd("JdtTestMethod")
          else
            vim.notify("Java test debugging requires active JDTLS", vim.log.levels.WARN)
          end
        end,
        desc = "Debug Java test method",
        ft = "java"
      },
    },
  },
}
