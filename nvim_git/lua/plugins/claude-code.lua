-- lua/plugins/claude-code.lua
-- Claude Code integration using coder/claudecode.nvim
return {
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim"
    },
    config = function()
      require("claudecode").setup({
        -- Terminal configuration (vertical split)
        terminal = {
          split_side = "right",
          split_width_percentage = 0.35,
          provider = "auto",
          auto_close = true,
        },
        
        -- Selection tracking (REQUIRED for ClaudeCodeSend)
        track_selection = true,
        
        -- Diff integration
        diff_opts = {
          auto_close_on_accept = true,
          vertical_split = true,
        },
      })
    end,
    
    keys = {
      -- ===== MAIN TOGGLE =====
      -- Normal and Visual mode
      {
        "<C-\\>",
        "<cmd>ClaudeCode<cr>",
        desc = "Toggle Claude Code",
        mode = { "n", "v" }
      },
      
      -- Terminal mode (special handling to exit terminal first)
      {
        "<C-\\>",
        function()
          -- Exit terminal mode first
          local escape = vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true)
          vim.api.nvim_feedkeys(escape, 'n', false)
          -- Then toggle Claude
          vim.defer_fn(function()
            vim.cmd("ClaudeCode")
          end, 10)
        end,
        desc = "Toggle Claude Code from terminal",
        mode = { "t" }
      },
      
      {
        "<leader>cf",
        "<cmd>ClaudeCodeFocus<cr>",
        desc = "Focus Claude Code",
        mode = { "n" }
      },
      
      {
        "<leader>cc",
        "<cmd>ClaudeCode --continue<cr>",
        desc = "Continue Claude conversation",
        mode = { "n", "v" }
      },
      
      -- ===== SEND TO CLAUDE =====
      {
        "<leader>cs",
        "<cmd>ClaudeCodeSend<cr>",
        desc = "Send selection to Claude",
        mode = { "v" }
      },
      
      {
        "<leader>cd",
        "<cmd>ClaudeCodeAdd %<cr>",
        desc = "Add current file to Claude context",
        mode = { "n" }
      },
      
      -- ===== QUICK ASK =====
      {
        "<leader>cq",
        function()
          local question = vim.fn.input("Ask Claude: ")
          if question ~= "" then
            vim.fn.setreg('c', question)
            vim.cmd("ClaudeCode")
            vim.notify("Question saved! In Claude terminal, press: i then Ctrl+r c", vim.log.levels.INFO, {
              title = "Claude Code",
              timeout = 3000,
            })
          end
        end,
        desc = "Quick ask (saves to @c, paste with Ctrl+r c)",
        mode = { "n" }
      },
      
      -- Visual mode quick ask with code
      {
        "<leader>cq",
        function()
          vim.cmd("ClaudeCodeSend")
          vim.defer_fn(function()
            local question = vim.fn.input("Ask about selection: ")
            if question ~= "" then
              vim.fn.setreg('c', question)
              vim.notify("Question saved! In Claude terminal: i then Ctrl+r c", vim.log.levels.INFO, {
                title = "Claude Code",
                timeout = 3000,
              })
            end
          end, 500)
        end,
        desc = "Send code + ask question",
        mode = { "v" }
      },
      
      -- ===== DIFF MANAGEMENT =====
      {
        "<leader>cA",
        "<cmd>ClaudeCodeDiffAccept<cr>",
        desc = "Accept Claude's changes",
        mode = { "n" }
      },
      
      {
        "<leader>cD",
        "<cmd>ClaudeCodeDiffDeny<cr>",
        desc = "Reject Claude's changes",
        mode = { "n" }
      },
      
      -- ===== MODEL SELECTION =====
      {
        "<leader>cm",
        "<cmd>ClaudeCodeSelectModel<cr>",
        desc = "Select Claude model",
        mode = { "n" }
      },
    },
  },
}
