-- lua/plugins/c-cpp-debug.lua
-- C/C++ debugging setup with CodeLLDB (standalone, no changes needed to debug.lua)
return {
  -- Mason setup to ensure CodeLLDB is installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "codelldb",      -- C/C++ debugger (also used by Rust)
      },
    },
  },
  
  -- C/C++ debugging configuration
  {
    "mfussenegger/nvim-dap",
    -- REMOVED ft restriction so it loads immediately
    config = function()
      local dap = require("dap")
      
      -- C/C++ adapter using CodeLLDB (shared with Rust)
      -- Only set up if not already configured
      if not dap.adapters.codelldb then
        dap.adapters.codelldb = {
          type = 'server',
          port = "${port}",
          executable = {
            command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
            args = {"--port", "${port}"},
          }
        }
      end
      
      -- C debug configurations
      dap.configurations.c = {
        {
          name = "Launch C Program",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Get the current file without extension
            local file = vim.fn.expand("%:p")
            local file_no_ext = vim.fn.expand("%:p:r")
            
            -- Compile the program with debug symbols
            vim.notify("Compiling C program...", vim.log.levels.INFO)
            local compile_result = vim.fn.system(string.format("gcc -g -o %s %s", file_no_ext, file))
            
            if vim.v.shell_error ~= 0 then
              vim.notify("Compilation failed!\n" .. compile_result, vim.log.levels.ERROR)
              return nil
            end
            
            vim.notify("Compilation successful!", vim.log.levels.INFO)
            return file_no_ext
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Launch C Program (with input file)",
          type = "codelldb",
          request = "launch",
          program = function()
            local file = vim.fn.expand("%:p")
            local file_no_ext = vim.fn.expand("%:p:r")
            
            vim.notify("Compiling C program...", vim.log.levels.INFO)
            local compile_result = vim.fn.system(string.format("gcc -g -o %s %s", file_no_ext, file))
            
            if vim.v.shell_error ~= 0 then
              vim.notify("Compilation failed!\n" .. compile_result, vim.log.levels.ERROR)
              return nil
            end
            
            vim.notify("Compilation successful!", vim.log.levels.INFO)
            return file_no_ext
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          -- Redirect input from a file
          stdio = function()
            local input_file = vim.fn.input("Input file: ", "", "file")
            if input_file ~= "" then
              return { input_file, nil, nil }
            end
            return nil
          end,
        },
        {
          name = "Attach to C Process",
          type = "codelldb",
          request = "attach",
          pid = require('dap.utils').pick_process,
        },
      }
      
      -- C++ debug configurations (using g++ instead of gcc)
      dap.configurations.cpp = {
        {
          name = "Launch C++ Program",
          type = "codelldb",
          request = "launch",
          program = function()
            local file = vim.fn.expand("%:p")
            local file_no_ext = vim.fn.expand("%:p:r")
            
            vim.notify("Compiling C++ program...", vim.log.levels.INFO)
            local compile_result = vim.fn.system(string.format("g++ -g -o %s %s", file_no_ext, file))
            
            if vim.v.shell_error ~= 0 then
              vim.notify("Compilation failed!\n" .. compile_result, vim.log.levels.ERROR)
              return nil
            end
            
            vim.notify("Compilation successful!", vim.log.levels.INFO)
            return file_no_ext
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Launch C++ Program (with input file)",
          type = "codelldb",
          request = "launch",
          program = function()
            local file = vim.fn.expand("%:p")
            local file_no_ext = vim.fn.expand("%:p:r")
            
            vim.notify("Compiling C++ program...", vim.log.levels.INFO)
            local compile_result = vim.fn.system(string.format("g++ -g -o %s %s", file_no_ext, file))
            
            if vim.v.shell_error ~= 0 then
              vim.notify("Compilation failed!\n" .. compile_result, vim.log.levels.ERROR)
              return nil
            end
            
            vim.notify("Compilation successful!", vim.log.levels.INFO)
            return file_no_ext
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          stdio = function()
            local input_file = vim.fn.input("Input file: ", "", "file")
            if input_file ~= "" then
              return { input_file, nil, nil }
            end
            return nil
          end,
        },
        {
          name = "Attach to C++ Process",
          type = "codelldb",
          request = "attach",
          pid = require('dap.utils').pick_process,
        },
      }
    end,
  },
  
  -- C/C++ specific debugging keybindings
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dcc",
        function()
          -- Compile and debug current C/C++ file
          local filetype = vim.bo.filetype
          if filetype == "c" or filetype == "cpp" then
            vim.notify("Starting C/C++ debugger...", vim.log.levels.INFO)
            require("dap").continue()
          else
            vim.notify("Not a C/C++ file!", vim.log.levels.WARN)
          end
        end,
        desc = "Debug C/C++ file (compile & debug)",
        ft = { "c", "cpp" }
      },
    },
  },
}
