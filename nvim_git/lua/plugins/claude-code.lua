-- lua/plugins/claude-code.lua
-- Claude Code integration using coder/claudecode.nvim
-- This provides a similar experience to CopilotChat but with Claude Code
return {
  {
    "coder/claudecode.nvim",
    config = function()
      require("claudecode").setup({
        -- Terminal configuration (vertical split like your Copilot setup)
        terminal = {
          provider = "nvim",  -- Use built-in Neovim terminal
          provider_opts = {
            position = "vertical",  -- Vertical split
            size = 80,  -- 80 columns wide
          },
        },
        
        -- Auto-reload files modified by Claude Code
        auto_reload = true,
        
        -- Show notifications
        notifications = {
          enabled = true,
        },
      })
    end,
    
    keys = {
      -- Main toggle (similar to <leader>cc for Copilot)
      {
        "<leader>ac",
        "<cmd>ClaudeCode<cr>",
        desc = "Toggle Claude Code",
        mode = { "n", "v" }
      },
      
      -- Continue previous conversation
      {
        "<leader>aC",
        "<cmd>ClaudeCode --continue<cr>",
        desc = "Continue Claude Code conversation"
      },
      
      -- Quick ask with current file context
      {
        "<leader>aq",
        function()
          local question = vim.fn.input("Ask Claude Code: ")
          if question ~= "" then
            vim.cmd(string.format("ClaudeCode %s", vim.fn.shellescape(question)))
          end
        end,
        desc = "Quick ask Claude Code"
      },
      
      -- Ask about visual selection
      {
        "<leader>aq",
        function()
          local question = vim.fn.input("Ask about selection: ")
          if question ~= "" then
            vim.cmd(string.format("ClaudeCode %s", vim.fn.shellescape(question)))
          end
        end,
        mode = "v",
        desc = "Ask Claude Code about selection"
      },
      
      -- Code review
      {
        "<leader>ar",
        "<cmd>ClaudeCode Review this code for potential issues and improvements<cr>",
        desc = "Review with Claude Code"
      },
      
      -- Code explanation
      {
        "<leader>ae",
        "<cmd>ClaudeCode Explain what this code does<cr>",
        desc = "Explain with Claude Code"
      },
      
      -- Optimize code
      {
        "<leader>ao",
        "<cmd>ClaudeCode Optimize this code for better performance and readability<cr>",
        desc = "Optimize with Claude Code"
      },
      
      -- Fix issues
      {
        "<leader>af",
        "<cmd>ClaudeCode Fix any issues in this code<cr>",
        desc = "Fix with Claude Code"
      },
      
      -- Generate tests
      {
        "<leader>at",
        "<cmd>ClaudeCode Generate tests for this code<cr>",
        desc = "Generate tests with Claude Code"
      },
      
      -- Add documentation
      {
        "<leader>ad",
        "<cmd>ClaudeCode Add documentation comments to this code<cr>",
        desc = "Document with Claude Code"
      },
    },
  },
}
