return {
  -- GitHub Copilot base plugin (suggestions DISABLED, chat only)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    lazy = false,  -- Load immediately for chat
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,  -- Disable panel
        },
        suggestion = {
          enabled = false,  -- DISABLE inline suggestions
          auto_trigger = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      })
    end,
  },

  -- Copilot Chat integration
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",  -- Changed from canary to main
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = false,
      
      -- Chat window settings
      window = {
        layout = 'vertical',  -- 'vertical', 'horizontal', 'float'
        width = 0.4,          -- Width of chat window (40% of screen)
        height = 0.8,
        relative = 'editor',
        border = 'rounded',
        title = 'Copilot Chat',
      },
      
      -- Model selection
      model = 'gpt-4',  -- 'gpt-4' or 'gpt-3.5-turbo'
      
      -- Temperature for responses
      temperature = 0.1,
      
      -- Question header
      question_header = '## User ',
      answer_header = '## Copilot ',
      error_header = '## Error ',
      
      -- Prompts (customize these for your workflow)
      prompts = {
        Explain = {
          prompt = '/COPILOT_EXPLAIN Write an explanation for the selected code as paragraphs of text.',
        },
        Review = {
          prompt = '/COPILOT_REVIEW Review the selected code.',
        },
        Fix = {
          prompt = '/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.',
        },
        Optimize = {
          prompt = '/COPILOT_GENERATE Optimize the selected code to improve performance and readability.',
        },
        Docs = {
          prompt = '/COPILOT_GENERATE Please add documentation comment for the selection.',
        },
        Tests = {
          prompt = '/COPILOT_GENERATE Please generate tests for my code.',
        },
        FixDiagnostic = {
          prompt = 'Please assist with the following diagnostic issue in file:',
        },
        Commit = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
        },
        CommitStaged = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
        },
      },
      
      -- Auto-follow cursor
      auto_follow_cursor = true,
      
      -- Auto insert mode
      auto_insert_mode = false,
      
      -- Clear chat on new conversation
      clear_chat_on_new_message = false,
      
      -- Context
      context = nil,
      
      -- History path
      history_path = vim.fn.stdpath('data') .. '/copilotchat_history',
      
      -- Callback on response
      callback = nil,
      
      -- Selection
      selection = function(source)
        local select = require('CopilotChat.select')
        return select.visual(source) or select.buffer(source)
      end,
    },
    
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      
      chat.setup(opts)
      
      -- Keymaps for CopilotChat
      vim.keymap.set('n', '<leader>cc', function()
        chat.toggle()
      end, { desc = 'Toggle Copilot Chat' })
      
      vim.keymap.set('n', '<leader>cx', function()
        chat.reset()
      end, { desc = 'Clear Copilot Chat' })
      
      vim.keymap.set('n', '<leader>cq', function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          chat.ask(input, { selection = select.buffer })
        end
      end, { desc = 'Quick chat (buffer context)' })
      
      -- Visual mode: ask about selection
      vim.keymap.set('v', '<leader>cc', function()
        chat.toggle({
          selection = select.visual,
        })
      end, { desc = 'Copilot Chat with selection' })
      
      vim.keymap.set('v', '<leader>cq', function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          chat.ask(input, { selection = select.visual })
        end
      end, { desc = 'Quick chat (visual selection)' })
      
      -- Prompt actions (using the prompts defined in opts)
      vim.keymap.set('n', '<leader>ce', function()
        chat.ask(opts.prompts.Explain.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Explain code' })
      
      vim.keymap.set('v', '<leader>ce', function()
        chat.ask(opts.prompts.Explain.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Explain code' })
      
      vim.keymap.set('n', '<leader>cr', function()
        chat.ask(opts.prompts.Review.prompt, {
          selection = select.buffer,
        })
      end, { desc = 'Review code' })
      
      vim.keymap.set('v', '<leader>cr', function()
        chat.ask(opts.prompts.Review.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Review selection' })
      
      vim.keymap.set('n', '<leader>cf', function()
        chat.ask(opts.prompts.Fix.prompt, {
          selection = select.buffer,
        })
      end, { desc = 'Fix code' })
      
      vim.keymap.set('v', '<leader>cf', function()
        chat.ask(opts.prompts.Fix.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Fix selection' })
      
      vim.keymap.set('n', '<leader>co', function()
        chat.ask(opts.prompts.Optimize.prompt, {
          selection = select.buffer,
        })
      end, { desc = 'Optimize code' })
      
      vim.keymap.set('v', '<leader>co', function()
        chat.ask(opts.prompts.Optimize.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Optimize selection' })
      
      vim.keymap.set('n', '<leader>cd', function()
        chat.ask(opts.prompts.Docs.prompt, {
          selection = select.buffer,
        })
      end, { desc = 'Generate docs' })
      
      vim.keymap.set('v', '<leader>cd', function()
        chat.ask(opts.prompts.Docs.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Generate docs for selection' })
      
      vim.keymap.set('n', '<leader>ct', function()
        chat.ask(opts.prompts.Tests.prompt, {
          selection = select.buffer,
        })
      end, { desc = 'Generate tests' })
      
      vim.keymap.set('v', '<leader>ct', function()
        chat.ask(opts.prompts.Tests.prompt, {
          selection = select.visual,
        })
      end, { desc = 'Generate tests for selection' })
      
      vim.keymap.set('n', '<leader>cD', function()
        chat.ask(opts.prompts.FixDiagnostic.prompt, {
          selection = select.diagnostics,
        })
      end, { desc = 'Fix diagnostic' })
      
      vim.keymap.set('n', '<leader>cm', function()
        local select = require('CopilotChat.select')
        chat.ask(opts.prompts.Commit.prompt, {
          selection = select.gitdiff,
        })
      end, { desc = 'Generate commit message' })
      
      vim.keymap.set('n', '<leader>cs', function()
        local select = require('CopilotChat.select')
        chat.ask(opts.prompts.CommitStaged.prompt, {
          selection = function(source)
            return select.gitdiff(source, true)
          end,
        })
      end, { desc = 'Generate commit message (staged)' })
      
      -- Stop current response
      vim.keymap.set('n', '<leader>cS', function()
        chat.stop()
      end, { desc = 'Stop Copilot response' })
      
      -- Show help
      vim.keymap.set('n', '<leader>ch', function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.help_actions())
      end, { desc = 'Copilot Chat help actions' })
      
      -- Show prompts (if telescope is available)
      vim.keymap.set('n', '<leader>cp', function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end, { desc = 'Copilot Chat prompt actions' })
    end,
    
    -- Load on these commands
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatDebugInfo",
    },
    
    -- Load on these keys
    keys = {
      { "<leader>cc", mode = { "n", "v" }, desc = "Toggle Copilot Chat" },
      { "<leader>cq", mode = { "n", "v" }, desc = "Quick Chat" },
    },
  },
}
