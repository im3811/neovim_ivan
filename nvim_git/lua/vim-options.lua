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
  -- print("Set " .. option_name .. " = " .. tostring(option_value))
end

vim.g.mapleader = " "

-- Your existing keymaps
vim.keymap.set("n", "<leader>w", "w<CR>")
vim.keymap.set("n", "<leader>q", "q:<CR>")
vim.keymap.set("n", "<leader>wq", ":wq<CR>")

-- Window navigation with Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Also work in terminal mode
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window from terminal" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to window below from terminal" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to window above from terminal" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window from terminal" })

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

-- Run current file (UPDATED with Rust support)
vim.keymap.set("n", "<leader>r", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local filepath = vim.fn.expand("%:p")

  if filetype == "php" then
    -- Use terminal split for cleaner output
    vim.cmd("botright split | terminal php " .. filename)
    vim.cmd("resize 10")
    vim.cmd("setlocal bufhidden=wipe")  -- Auto-delete buffer when window closes
    
  elseif filetype == "python" then
    -- Use terminal split for cleaner output
    vim.cmd("botright split | terminal python " .. filename)
    vim.cmd("resize 10")
    vim.cmd("setlocal bufhidden=wipe")  -- Auto-delete buffer when window closes
    
  elseif filetype == "rust" then
    -- Check if we're in a Cargo project
    local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
    
    if cargo_toml ~= "" then
      -- We're in a Cargo project
      local project_root = vim.fn.fnamemodify(cargo_toml, ":h")
      
      -- Check if this is a bin file in src/bin/
      if string.find(filepath, "/bin/") then
        -- Extract the binary name from the file path
        local bin_name = vim.fn.fnamemodify(filename, ":t:r")
        -- Try to run as a cargo binary first, if it fails it will show the error
        -- User needs to add [[bin]] entry in Cargo.toml for it to work
        vim.cmd("botright split | terminal cd " .. project_root .. " && cargo run --bin " .. bin_name .. " 2>&1 || (echo 'Failed to run as cargo binary. Add [[bin]] entry to Cargo.toml:' && echo '[[bin]]' && echo 'name = \"" .. bin_name .. "\"' && echo 'path = \"src/bin/" .. filename .. "\"')")
      elseif string.find(filename, "^main%.rs$") or string.find(filepath, "/src/main%.rs$") then
        -- It's main.rs, run the default binary
        vim.cmd("botright split | terminal cd " .. project_root .. " && cargo run")
      else
        -- It's some other .rs file in the project
        -- Just compile and run it standalone with rustc
        local exe_name = vim.fn.fnamemodify(filename, ":r")
        vim.cmd("botright split | terminal rustc " .. filepath .. " -o /tmp/" .. exe_name .. " && /tmp/" .. exe_name)
      end
    else
      -- Not in a Cargo project, compile and run single file
      local exe_name = vim.fn.fnamemodify(filename, ":r")
      vim.cmd("botright split | terminal rustc " .. filename .. " -o /tmp/" .. exe_name .. " && /tmp/" .. exe_name)
    end
    
    vim.cmd("resize 10")
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

-- ===== ARROW KEYS & TOUCHPAD CONTROL =====

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

-- Disable mouse/touchpad in Neovim
local function disable_mouse()
  vim.opt.mouse = "" -- Disable mouse completely in Neovim
end

-- Enable mouse/touchpad in Neovim
local function enable_mouse()
  vim.opt.mouse = "a" -- Enable mouse in all modes
end

-- System-level touchpad control functions
local function disable_touchpad_system()
  -- Linux/Ubuntu - adjust command for your system
  vim.fn.system("xinput disable $(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | grep -o '[0-9]*') 2>/dev/null")

  -- Alternative for different systems:
  -- macOS: vim.fn.system("sudo kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext")
  -- Windows: You'd need a PowerShell script
end

local function enable_touchpad_system()
  -- Linux/Ubuntu - adjust command for your system
  vim.fn.system("xinput enable $(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | grep -o '[0-9]*') 2>/dev/null")

  -- Alternative for different systems:
  -- macOS: vim.fn.system("sudo kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext")
end

-- Initialize with disabled state
disable_arrows()
disable_mouse()
disable_touchpad_system()

-- Manual toggle keybinding
vim.keymap.set('n', '<leader>tm', function()
  if vim.opt.mouse:get() == "" then
    enable_mouse()
    enable_touchpad_system()
    vim.notify("Mouse/Touchpad enabled", vim.log.levels.INFO)
  else
    disable_mouse()
    disable_touchpad_system()
    vim.notify("Mouse/Touchpad disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle mouse/touchpad" })

-- Store functions globally for debug integration
_G.enable_touchpad = function()
  enable_mouse()
  enable_touchpad_system()
end

_G.disable_touchpad = function()
  disable_mouse()
  disable_touchpad_system()
end
