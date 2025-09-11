

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

vim.keymap.set("n", "<leader>w", "w<CR>")
vim.keymap.set("n", "<leader>q", "q:<CR>")
vim.keymap.set("n", "<leader>wq", ":wq<CR>")
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

-- Create the directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.keymap.set("n", "<leader>r", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  
  if filetype == "php" then
    vim.cmd("!php " .. filename)
  elseif filetype == "python" then
    vim.cmd("!python " .. filename)
  else
    print("No run command configured for filetype: " .. filetype)
  end
end, { desc = "Run current file" })


