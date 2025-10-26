-- lua/plugins/csharp.lua
-- C# development setup with LSP and debugging
return {
  -- Mason setup to install C# tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "omnisharp",      -- C# LSP
        "netcoredbg",     -- C# debugger
      },
    },
  },
  
  -- C# debugging configuration
  {
    "mfussenegger/nvim-dap",
    ft = { "cs" },
    config = function()
      local dap = require("dap")
      
      -- C# adapter using netcoredbg
      dap.adapters.coreclr = {
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/bin/netcoredbg',
        args = {'--interpreter=vscode'}
      }
      
      -- C# debug configurations
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            -- Automatically find the DLL in bin/Debug
            local cwd = vim.fn.getcwd()
            -- Try to find .csproj file
            local csproj = vim.fn.glob(cwd .. "/*.csproj")
            if csproj ~= "" then
              -- Extract project name from .csproj filename
              local project_name = vim.fn.fnamemodify(csproj, ":t:r")
              -- Look for the DLL in common locations
              local dll_path = cwd .. "/bin/Debug/net8.0/" .. project_name .. ".dll"
              if vim.fn.filereadable(dll_path) == 1 then
                return dll_path
              end
            end
            -- Fallback: ask user
            return vim.fn.input('Path to dll: ', cwd .. '/bin/Debug/', 'file')
          end,
        },
        {
          type = "coreclr",
          name = "attach - netcoredbg",
          request = "attach",
          processId = require('dap.utils').pick_process,
        },
      }
    end,
  },
  
  -- C#-specific debugging keybindings
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dcs",
        function()
          -- Build before debugging
          vim.notify("Building C# project...", vim.log.levels.INFO)
          vim.fn.system("dotnet build")
          vim.notify("Starting C# debugger", vim.log.levels.INFO)
          require("dap").continue()
        end,
        desc = "Build and debug C# project",
        ft = "cs"
      },
    },
  },
}
