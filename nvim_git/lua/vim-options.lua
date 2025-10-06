-- Basic vim options
local options = { 
  number = true,
  relativenumber = true,
  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  cursorline = true
}

for option_name, option_value in pairs(options) do
  vim.opt[option_name] = option_value
end

vim.g.mapleader = " "

-- Your existing keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>wq", ":wq<CR>")

-- Window navigation will be set up later with touchpad control integration

-- Window management shortcuts
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>sc", "<C-w>c", { desc = "Close current window" })
vim.keymap.set("n", "<leader>so", "<C-w>o", { desc = "Close all other windows" })

-- Undo configuration
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Create the directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

-- ===== SMART ARROW KEYS & TOUCHPAD CONTROL =====

-- Disable arrow keys and force proper vim navigation
local function disable_arrows()
  local modes = { 'n', 'i', 'v' }
  local keys = { '<Up>', '<Down>', '<Left>', '<Right>' }

  for _, mode in ipairs(modes) do
    for _, key in ipairs(keys) do
      vim.keymap.set(mode, key, '<Nop>', {
        noremap = true,
        silent = true,
        desc = "Arrow keys disabled - use hjkl"
      })
    end
  end

  -- Show helpful reminder messages when arrow keys are pressed
  vim.keymap.set('n', '<Up>', function()
    vim.notify("Use 'k' to go up!", vim.log.levels.WARN, { title = "Vim Navigation" })
  end, { desc = "Arrow key reminder" })

  vim.keymap.set('n', '<Down>', function()
    vim.notify("Use 'j' to go down!", vim.log.levels.WARN, { title = "Vim Navigation" })
  end, { desc = "Arrow key reminder" })

  vim.keymap.set('n', '<Left>', function()
    vim.notify("Use 'h' to go left!", vim.log.levels.WARN, { title = "Vim Navigation" })
  end, { desc = "Arrow key reminder" })

  vim.keymap.set('n', '<Right>', function()
    vim.notify("Use 'l' to go right!", vim.log.levels.WARN, { title = "Vim Navigation" })
  end, { desc = "Arrow key reminder" })
end

-- Store simple toggle functions globally for debug integration if needed
_G.enable_touchpad = function()
  vim.opt_local.mouse = "a"
end

_G.disable_touchpad = function()
  vim.opt_local.mouse = ""
end

-- Initialize with globally disabled mouse
vim.opt.mouse = ""
disable_arrows()

-- SMART WINDOW-BASED MOUSE CONTROL
-- Function to update mouse state for current window
local function update_mouse_for_window()
  local current_buf = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(current_buf, "buftype")
  
  if buftype == "terminal" then
    vim.opt_local.mouse = "a"  -- Enable mouse ONLY in this window
  else
    vim.opt_local.mouse = ""   -- Disable mouse in code windows
  end
end

-- Update mouse settings when entering any window
vim.api.nvim_create_autocmd({"WinEnter", "BufWinEnter", "TermOpen"}, {
  pattern = "*",
  callback = function()
    update_mouse_for_window()
  end,
})

-- Ensure mouse is disabled in new windows by default
vim.api.nvim_create_autocmd({"BufNew", "BufRead", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    -- Small delay to ensure buffer type is set
    vim.defer_fn(function()
      if vim.bo.buftype ~= "terminal" then
        vim.opt_local.mouse = ""
      end
    end, 10)
  end,
})

-- Override window navigation to update mouse state
vim.keymap.set("n", "<C-h>", function()
  vim.cmd("wincmd h")
  update_mouse_for_window()
end, { desc = "Move to left window" })

vim.keymap.set("n", "<C-j>", function()
  vim.cmd("wincmd j")
  update_mouse_for_window()
end, { desc = "Move to window below" })

vim.keymap.set("n", "<C-k>", function()
  vim.cmd("wincmd k")
  update_mouse_for_window()
end, { desc = "Move to window above" })

vim.keymap.set("n", "<C-l>", function()
  vim.cmd("wincmd l")
  update_mouse_for_window()
end, { desc = "Move to right window" })

-- Terminal mode navigation with mouse update
vim.keymap.set("t", "<C-h>", function()
  vim.cmd([[normal! <C-\><C-n><C-w>h]])
  update_mouse_for_window()
end, { desc = "Move to left window from terminal" })

vim.keymap.set("t", "<C-j>", function()
  vim.cmd([[normal! <C-\><C-n><C-w>j]])
  update_mouse_for_window()
end, { desc = "Move to window below from terminal" })

vim.keymap.set("t", "<C-k>", function()
  vim.cmd([[normal! <C-\><C-n><C-w>k]])
  update_mouse_for_window()
end, { desc = "Move to window above from terminal" })

vim.keymap.set("t", "<C-l>", function()
  vim.cmd([[normal! <C-\><C-n><C-w>l]])
  update_mouse_for_window()
end, { desc = "Move to right window from terminal" })

-- Manual toggle keybinding (for testing or override)
vim.keymap.set('n', '<leader>tm', function()
  if vim.opt_local.mouse:get() == "" then
    vim.opt_local.mouse = "a"
    vim.notify("Mouse enabled in current window", vim.log.levels.INFO)
  else
    vim.opt_local.mouse = ""
    vim.notify("Mouse disabled in current window", vim.log.levels.INFO)
  end
end, { desc = "Toggle mouse in current window" })

-- Run current file (with vertical terminal split)
vim.keymap.set("n", "<leader>r", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local filepath = vim.fn.expand("%:p")

  if filetype == "php" then
    -- Use vertical terminal split
    vim.cmd("rightbelow vsplit | terminal php " .. filename)
    vim.cmd("vertical resize 80")
    vim.cmd("setlocal bufhidden=wipe")  -- Auto-delete buffer when window closes
    
  elseif filetype == "python" then
    -- Use vertical terminal split
    vim.cmd("rightbelow vsplit | terminal python " .. filename)
    vim.cmd("vertical resize 80")
    vim.cmd("setlocal bufhidden=wipe")  -- Auto-delete buffer when window closes
    
  elseif filetype == "java" then
    -- Java compilation and execution
    local class_name = vim.fn.expand("%:t:r")  -- Get class name without extension
    local package_path = ""
    
    -- Try to detect package structure
    local first_line = vim.fn.getline(1)
    local package_match = string.match(first_line, "^package%s+([%w%.]+);")
    
    if package_match then
      -- We're in a package, need to compile from source root
      package_path = string.gsub(package_match, "%.", "/") .. "/"
      
      -- Find the source root (go up until we don't see the package folders)
      local source_root = filepath
      for _ = 1, 10 do
        source_root = vim.fn.fnamemodify(source_root, ":h")
        if not string.find(source_root, package_path:gsub("/", "")) then
          break
        end
      end
      
      -- Compile and run from source root
      vim.cmd("rightbelow vsplit | terminal cd " .. vim.fn.shellescape(source_root) .. 
              " && javac " .. package_path .. class_name .. ".java" ..
              " && java " .. package_match .. "." .. class_name)
    else
      -- No package, simple compilation
      vim.cmd("rightbelow vsplit | terminal javac " .. filename .. " && java " .. class_name)
    end
    
    vim.cmd("vertical resize 80")
    vim.cmd("setlocal bufhidden=wipe")  -- Auto-delete buffer when window closes
    
  elseif filetype == "rust" then
    -- Check if we're in a Cargo project
    local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
    
    if cargo_toml ~= "" then
      -- We're in a Cargo project
      local project_root = vim.fn.fnamemodify(cargo_toml, ":h")
      
      -- Extract just the filename without path for binary name
      local bin_name = vim.fn.fnamemodify(filename, ":t:r")
      
      -- Check if this is a configured binary (check Cargo.toml)
      local cargo_content = vim.fn.readfile(cargo_toml)
      local has_bin_config = false
      
      for _, line in ipairs(cargo_content) do
        if string.match(line, 'name%s*=%s*["\']' .. bin_name .. '["\']') then
          has_bin_config = true
          break
        end
      end
      
      if has_bin_config then
        -- It's a configured binary, use cargo run
        vim.cmd("rightbelow vsplit | terminal cd " .. vim.fn.shellescape(project_root) .. " && cargo run --bin " .. bin_name)
      elseif string.find(filename, "^main%.rs$") or string.find(filepath, "/src/main%.rs$") then
        -- It's main.rs, run the default binary
        vim.cmd("rightbelow vsplit | terminal cd " .. vim.fn.shellescape(project_root) .. " && cargo run")
      else
        -- It's some other .rs file in the project, compile and run standalone
        local simple_exe_name = bin_name
        vim.cmd("rightbelow vsplit | terminal cd " .. vim.fn.shellescape(project_root) .. " && rustc " .. vim.fn.shellescape(filepath) .. " -o /tmp/" .. simple_exe_name .. " && /tmp/" .. simple_exe_name)
      end
    else
      -- Not in a Cargo project, compile and run single file
      local simple_exe_name = vim.fn.fnamemodify(filename, ":t:r")
      vim.cmd("rightbelow vsplit | terminal rustc " .. vim.fn.shellescape(filepath) .. " -o /tmp/" .. simple_exe_name .. " && /tmp/" .. simple_exe_name)
    end
    
    vim.cmd("vertical resize 80")
    vim.cmd("setlocal bufhidden=wipe")  -- Auto-delete buffer when window closes
  else
    print("No run command configured for filetype: " .. filetype)
  end
end, { desc = "Run current file" })

-- Add this to exit terminal mode with Esc
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Press Enter in terminal normal mode to close the terminal
vim.keymap.set("n", "<CR>", function()
  -- Only close if we're in a terminal buffer
  if vim.bo.buftype == "terminal" then
    vim.cmd("close")
  else
    -- Otherwise, do the normal Enter behavior
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end
end, { desc = "Close terminal with Enter (in terminal buffers)" })

-- Auto change directory to project root for Rust files AND handle binaries
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.rs",
  callback = function()
    local current_file = vim.fn.expand("%:p")
    if current_file == "" or vim.fn.filereadable(current_file) == 0 then
      return
    end
    
    -- Find Cargo.toml by going up directories
    local function find_cargo_root(path)
      local dir = vim.fn.fnamemodify(path, ':h')
      while dir ~= '/' and dir ~= '.' do
        if vim.fn.filereadable(dir .. '/Cargo.toml') == 1 then
          return dir
        end
        dir = vim.fn.fnamemodify(dir, ':h')
      end
      return nil
    end
    
    local project_root = find_cargo_root(current_file)
    if project_root then
      local current_cwd = vim.fn.getcwd()
      
      -- Change directory if needed
      if current_cwd ~= project_root then
        vim.cmd('cd ' .. project_root)
        vim.notify("Changed to project root: " .. project_root, vim.log.levels.INFO)
        
        -- For binary files, force rust-analyzer restart after directory change
        local is_binary_file = string.find(current_file, "/bin/") ~= nil
        if is_binary_file then
          vim.defer_fn(function()
            vim.cmd("LspRestart rust_analyzer")
            vim.notify("Restarted rust-analyzer for binary: " .. vim.fn.fnamemodify(current_file, ":t"), vim.log.levels.INFO)
          end, 1500) -- Give it time to settle after cd
        end
      end
    end
  end,
})

-- Auto change directory to project root for Java files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.java",
  callback = function()
    local current_file = vim.fn.expand("%:p")
    if current_file == "" or vim.fn.filereadable(current_file) == 0 then
      return
    end
    
    -- Find Java project root (pom.xml, build.gradle, etc.)
    local function find_java_root(path)
      local dir = vim.fn.fnamemodify(path, ':h')
      local markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".project", ".classpath" }
      
      while dir ~= '/' and dir ~= '.' do
        for _, marker in ipairs(markers) do
          if vim.fn.filereadable(dir .. '/' .. marker) == 1 then
            return dir
          end
        end
        -- Also check for src directory structure
        if vim.fn.isdirectory(dir .. '/src/main/java') == 1 then
          return dir
        end
        dir = vim.fn.fnamemodify(dir, ':h')
      end
      return nil
    end
    
    local project_root = find_java_root(current_file)
    if project_root then
      local current_cwd = vim.fn.getcwd()
      
      -- Change directory if needed
      if current_cwd ~= project_root then
        vim.cmd('cd ' .. project_root)
        vim.notify("Changed to Java project root: " .. project_root, vim.log.levels.INFO)
      end
    end
  end,
})

-- Manual reload command for stubborn cases
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("LspRestart rust_analyzer")
  vim.notify("Manually restarted rust-analyzer", vim.log.levels.INFO)
end, { desc = "Restart rust-analyzer" })
