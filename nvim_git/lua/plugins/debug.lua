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

      -- Key mappings
      local keymap = vim.keymap.set

      -- Debug session controls
      keymap("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      keymap("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Set conditional breakpoint" })

      keymap("n", "<leader>dc", dap.continue, { desc = "Continue" })
      keymap("n", "<leader>ds", dap.step_over, { desc = "Step over" })
      keymap("n", "<leader>di", dap.step_into, { desc = "Step into" })
      keymap("n", "<leader>do", dap.step_out, { desc = "Step out" })

      -- Debug UI controls
      keymap("n", "<leader>du", function()
        require("dapui").toggle()
      end, { desc = "Toggle debug UI" })

      keymap("n", "<leader>dr", dap.repl.open, { desc = "Open debug REPL" })
      keymap("n", "<leader>dl", dap.run_last, { desc = "Run last debug session" })

      -- Python-specific
      keymap("n", "<leader>dpy", dap_python.test_method, { desc = "Debug Python test method" })
      keymap("n", "<leader>dpc", dap_python.test_class, { desc = "Debug Python test class" })

      -- Terminate session
      keymap("n", "<leader>dt", dap.terminate, { desc = "Terminate debug session" })

      -- Evaluate expression
      keymap("v", "<leader>de", function()
        require("dapui").eval()
      end, { desc = "Evaluate selection" })
    end,
  },
}
