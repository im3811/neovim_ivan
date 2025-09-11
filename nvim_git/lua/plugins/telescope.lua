return {
  {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      
      -- Telescope setup
      telescope.setup({
        defaults = {
          -- Better file previews
          file_previewer = require('telescope.previewers').vim_buffer_cat.new,
          grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
          
          -- Better sorting
          file_sorter = require('telescope.sorters').get_fuzzy_file,
          generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
          
          -- Layout
          layout_config = {
            horizontal = {
              preview_width = 0.6,
            },
          },
        },
      })
      
      -- Essential keymaps
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
      
      -- Additional useful pickers
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
      vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
      
      -- LSP integration (works with your existing LSP setup)
      vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
      vim.keymap.set('n', '<leader>fw', builtin.lsp_workspace_symbols, { desc = 'Workspace symbols' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
      
      -- Git integration
      vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
      vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
      vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
    end,
  },
}
