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

-- ===== JAVA FILE TEMPLATES WITH AUTO-PACKAGING =====
-- Function to extract package name from file path
local function get_package_name(filepath)
  -- Look for src/main/java or src/test/java in the path
  local java_path_pattern = "src/main/java/(.+)/"
  local test_path_pattern = "src/test/java/(.+)/"
  
  -- Try main java path first
  local package_path = filepath:match(java_path_pattern)
  if not package_path then
    -- Try test java path
    package_path = filepath:match(test_path_pattern)
  end
  
  if package_path then
    -- Convert file path to package name (replace / with .)
    return package_path:gsub("/", ".")
  end
  
  return nil
end

-- Function to generate Java file template
local function generate_java_template(file_type, class_name, package_name)
  local templates = {
    class = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "public class " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    interface = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "public interface " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    abstract_class = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "public abstract class " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    enum = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "public enum " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    record = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "public record " .. name .. "() {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    service = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "import org.springframework.stereotype.Service;")
      table.insert(lines, "")
      table.insert(lines, "@Service")
      table.insert(lines, "public class " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    controller = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "import org.springframework.web.bind.annotation.RestController;")
      table.insert(lines, "import org.springframework.web.bind.annotation.RequestMapping;")
      table.insert(lines, "")
      table.insert(lines, "@RestController")
      table.insert(lines, "@RequestMapping")
      table.insert(lines, "public class " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    repository = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "import org.springframework.data.jpa.repository.JpaRepository;")
      table.insert(lines, "import org.springframework.stereotype.Repository;")
      table.insert(lines, "")
      table.insert(lines, "@Repository")
      table.insert(lines, "public interface " .. name .. " extends JpaRepository<Entity, Long> {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    component = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "import org.springframework.stereotype.Component;")
      table.insert(lines, "")
      table.insert(lines, "@Component")
      table.insert(lines, "public class " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
    
    entity = function(name, pkg)
      local lines = {}
      if pkg then
        table.insert(lines, "package " .. pkg .. ";")
        table.insert(lines, "")
      end
      table.insert(lines, "import jakarta.persistence.Entity;")
      table.insert(lines, "import jakarta.persistence.Id;")
      table.insert(lines, "import jakarta.persistence.GeneratedValue;")
      table.insert(lines, "import jakarta.persistence.GenerationType;")
      table.insert(lines, "")
      table.insert(lines, "@Entity")
      table.insert(lines, "public class " .. name .. " {")
      table.insert(lines, "    ")
      table.insert(lines, "    @Id")
      table.insert(lines, "    @GeneratedValue(strategy = GenerationType.IDENTITY)")
      table.insert(lines, "    private Long id;")
      table.insert(lines, "    ")
      table.insert(lines, "}")
      return lines
    end,
  }
  
  local generator = templates[file_type]
  if generator then
    return generator(class_name, package_name)
  end
  
  return nil
end

-- Track which files we've already templated
local templated_files = {}

-- Auto-generate Java file templates when opening EMPTY .java files
vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
  pattern = "*.java",
  callback = function()
    -- Get buffer info
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.fn.expand("%:p")
    
    -- Skip if already templated
    if templated_files[filepath] then
      return
    end
    
    -- Check if buffer is empty
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local is_empty = #lines == 0 or (#lines == 1 and lines[1] == "")
    
    if not is_empty then
      return
    end
    
    -- Mark as templated to avoid re-triggering
    templated_files[filepath] = true
    
    local filename = vim.fn.expand("%:t:r")  -- Get filename without extension
    local package_name = get_package_name(filepath)
    
    -- File type options
    local file_types = {
      "class",
      "interface", 
      "abstract_class",
      "enum",
      "record",
      "service",
      "controller",
      "repository",
      "component",
      "entity"
    }
    
    local display_names = {
      "Class",
      "Interface",
      "Abstract Class",
      "Enum",
      "Record",
      "Service (Spring)",
      "Controller (Spring)",
      "Repository (Spring)",
      "Component (Spring)",
      "Entity (JPA)"
    }
    
    -- Small delay to ensure buffer is ready
    vim.defer_fn(function()
      -- Prompt user for file type
      vim.ui.select(display_names, {
        prompt = "Select Java file type:",
      }, function(choice, idx)
        if not choice then
          -- User cancelled, just insert package if available
          if package_name then
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
              "package " .. package_name .. ";",
              "",
              ""
            })
          end
          return
        end
        
        local file_type = file_types[idx]
        local template = generate_java_template(file_type, filename, package_name)
        
        if template then
          -- Insert template
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, template)
          
          -- Move cursor to the blank line inside the class/interface
          vim.api.nvim_win_set_cursor(0, {#template - 1, 4})
          
          -- Enter insert mode
          vim.cmd("startinsert!")
          
          vim.notify("Created " .. choice .. ": " .. filename, vim.log.levels.INFO)
        end
      end)
    end, 100)  -- 100ms delay
  end,
})

-- Manual Java template generator command
vim.api.nvim_create_user_command("JavaTemplate", function()
  local filepath = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t:r")
  local package_name = get_package_name(filepath)
  
  local file_types = {
    "class",
    "interface", 
    "abstract_class",
    "enum",
    "record",
    "service",
    "controller",
    "repository",
    "component",
    "entity"
  }
  
  local display_names = {
    "Class",
    "Interface",
    "Abstract Class",
    "Enum",
    "Record",
    "Service (Spring)",
    "Controller (Spring)",
    "Repository (Spring)",
    "Component (Spring)",
    "Entity (JPA)"
  }
  
  vim.ui.select(display_names, {
    prompt = "Select Java file type:",
  }, function(choice, idx)
    if not choice then
      return
    end
    
    local file_type = file_types[idx]
    local template = generate_java_template(file_type, filename, package_name)
    
    if template then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
      vim.api.nvim_win_set_cursor(0, {#template - 1, 4})
      vim.cmd("startinsert!")
      vim.notify("Created " .. choice .. ": " .. filename, vim.log.levels.INFO)
    end
  end)
end, {})

-- ===== SMART RUN CURRENT FILE (WITH SPRING BOOT DETECTION) =====
vim.keymap.set("n", "<leader>r", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local filepath = vim.fn.expand("%:p")
  
  -- FIRST: Check if we're in a Spring Boot/Maven project
  local pom_xml = vim.fn.findfile("pom.xml", ".;")
  local build_gradle = vim.fn.findfile("build.gradle", ".;")
  
  if filetype == "java" and (pom_xml ~= "" or build_gradle ~= "") then
    -- We're in a Maven/Gradle project - run Spring Boot!
    vim.notify("Detected Spring Boot project - running with Maven/Gradle", vim.log.levels.INFO)
    
    if pom_xml ~= "" then
      local project_root = vim.fn.fnamemodify(pom_xml, ":h")
      vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && ./mvnw spring-boot:run")
    elseif build_gradle ~= "" then
      local project_root = vim.fn.fnamemodify(build_gradle, ":h")
      vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && ./gradlew bootRun")
    end
    
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
    return
  end
  
  -- FALLBACK: Original behavior for other file types
  if filetype == "php" then
    vim.cmd("botright split | terminal php " .. filename)
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
    
  elseif filetype == "python" then
    vim.cmd("botright split | terminal python " .. filename)
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
    
  elseif filetype == "java" then
    -- Single file Java (no Maven/Gradle)
    local class_name = vim.fn.expand("%:t:r")
    local package_path = ""
    
    local first_line = vim.fn.getline(1)
    local package_match = string.match(first_line, "^package%s+([%w%.]+);")
    
    if package_match then
      package_path = string.gsub(package_match, "%.", "/") .. "/"
      local source_root = filepath
      for _ = 1, 10 do
        source_root = vim.fn.fnamemodify(source_root, ":h")
        if not string.find(source_root, package_path:gsub("/", "")) then
          break
        end
      end
      
      vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(source_root) .. 
              " && javac " .. package_path .. class_name .. ".java" ..
              " && java " .. package_match .. "." .. class_name)
    else
      vim.cmd("botright split | terminal javac " .. filename .. " && java " .. class_name)
    end
    
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
    
  elseif filetype == "rust" then
    local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
    
    if cargo_toml ~= "" then
      local project_root = vim.fn.fnamemodify(cargo_toml, ":h")
      local bin_name = vim.fn.fnamemodify(filename, ":t:r")
      local cargo_content = vim.fn.readfile(cargo_toml)
      local has_bin_config = false
      
      for _, line in ipairs(cargo_content) do
        if string.match(line, 'name%s*=%s*["\']' .. bin_name .. '["\']') then
          has_bin_config = true
          break
        end
      end
      
      if has_bin_config then
        vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && cargo run --bin " .. bin_name)
      elseif string.find(filename, "^main%.rs$") or string.find(filepath, "/src/main%.rs$") then
        vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && cargo run")
      else
        local simple_exe_name = bin_name
        vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && rustc " .. vim.fn.shellescape(filepath) .. " -o /tmp/" .. simple_exe_name .. " && /tmp/" .. simple_exe_name)
      end
    else
      local simple_exe_name = vim.fn.fnamemodify(filename, ":t:r")
      vim.cmd("botright split | terminal rustc " .. vim.fn.shellescape(filepath) .. " -o /tmp/" .. simple_exe_name .. " && /tmp/" .. simple_exe_name)
    end
    
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
  else
    print("No run command configured for filetype: " .. filetype)
  end
end, { desc = "Smart run: Spring Boot (if Maven/Gradle) or single file" })

-- Spring Boot specific runner
vim.keymap.set("n", "<leader>rs", function()
  local pom_xml = vim.fn.findfile("pom.xml", ".;")
  local build_gradle = vim.fn.findfile("build.gradle", ".;")
  
  if pom_xml ~= "" then
    local project_root = vim.fn.fnamemodify(pom_xml, ":h")
    vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && ./mvnw spring-boot:run")
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
  elseif build_gradle ~= "" then
    local project_root = vim.fn.fnamemodify(build_gradle, ":h")
    vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && ./gradlew bootRun")
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
  else
    vim.notify("No Maven or Gradle project found", vim.log.levels.ERROR)
  end
end, { desc = "Run Spring Boot application (Maven/Gradle)" })

-- Maven test runner
vim.keymap.set("n", "<leader>rt", function()
  local pom_xml = vim.fn.findfile("pom.xml", ".;")
  if pom_xml ~= "" then
    local project_root = vim.fn.fnamemodify(pom_xml, ":h")
    vim.cmd("botright split | terminal cd " .. vim.fn.shellescape(project_root) .. " && ./mvnw test")
    vim.cmd("resize 15")
    vim.cmd("setlocal bufhidden=wipe")
  else
    vim.notify("No Maven project found", vim.log.levels.ERROR)
  end
end, { desc = "Run Maven tests" })

-- Kill Spring Boot server
vim.keymap.set("n", "<leader>rk", function()
  vim.cmd("botright split | terminal sudo fuser -k 8080/tcp")
  vim.cmd("resize 10")
  vim.defer_fn(function()
    vim.cmd("close")
  end, 2000)
  vim.notify("Killed Spring Boot server on port 8080", vim.log.levels.INFO)
end, { desc = "Kill Spring Boot server" })

-- Terminal mode keymaps
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Press Enter in terminal normal mode to close the terminal
vim.keymap.set("n", "<CR>", function()
  if vim.bo.buftype == "terminal" then
    vim.cmd("close")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end
end, { desc = "Close terminal with Enter (in terminal buffers)" })

-- Auto change directory to project root for Rust files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.rs",
  callback = function()
    local current_file = vim.fn.expand("%:p")
    if current_file == "" or vim.fn.filereadable(current_file) == 0 then
      return
    end
    
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
      
      if current_cwd ~= project_root then
        vim.cmd('cd ' .. project_root)
        vim.notify("Changed to project root: " .. project_root, vim.log.levels.INFO)
        
        local is_binary_file = string.find(current_file, "/bin/") ~= nil
        if is_binary_file then
          vim.defer_fn(function()
            vim.cmd("LspRestart rust_analyzer")
            vim.notify("Restarted rust-analyzer for binary: " .. vim.fn.fnamemodify(current_file, ":t"), vim.log.levels.INFO)
          end, 1500)
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
    
    local function find_java_root(path)
      local dir = vim.fn.fnamemodify(path, ':h')
      local markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".project", ".classpath" }
      
      while dir ~= '/' and dir ~= '.' do
        for _, marker in ipairs(markers) do
          if vim.fn.filereadable(dir .. '/' .. marker) == 1 then
            return dir
          end
        end
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
      
      if current_cwd ~= project_root then
        vim.cmd('cd ' .. project_root)
        vim.notify("Changed to Java project root: " .. project_root, vim.log.levels.INFO)
      end
    end
  end,
})

-- Manual LSP restart
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("LspRestart rust_analyzer")
  vim.notify("Manually restarted rust-analyzer", vim.log.levels.INFO)
end, { desc = "Restart rust-analyzer" })

-- Maven reload after pom.xml changes
vim.keymap.set("n", "<leader>mr", function()
  vim.cmd("LspRestart")
  vim.notify("Restarted LSP servers", vim.log.levels.INFO)
end, { desc = "Restart LSP (for pom.xml changes)" })

-- ===== JAVA AUTO-IMPORT AND ORGANIZE IMPORTS =====
-- Auto-organize imports on save for Java files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.java",
  callback = function()
    -- Check if jdtls is available
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == "jdtls" then
        require('jdtls').organize_imports()
        break
      end
    end
  end,
})

-- Manual organize imports keymap for Java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local opts = { buffer = true, silent = true }
    
    -- Organize imports manually
    vim.keymap.set("n", "<leader>i", function()
      require('jdtls').organize_imports()
    end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
    
    -- Alternative: <leader>io for organize imports
    vim.keymap.set("n", "<leader>io", function()
      require('jdtls').organize_imports()
    end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
  end,
})

-- ===== INSTANT BUFFER SWITCHING =====
-- Helper function for instant buffer switching
local function jump_to_buffer(index)
  local buffers = vim.fn.getbufinfo({buflisted = 1})
  if index <= #buffers and index > 0 then
    local target_buf = buffers[index].bufnr
    vim.api.nvim_set_current_buf(target_buf)
  else
    vim.notify("Buffer " .. index .. " doesn't exist (only " .. #buffers .. " buffers open)", vim.log.levels.WARN)
  end
end

-- Alt + number (1-9) for INSTANT buffer switching
for i = 1, 9 do
  vim.keymap.set("n", "<M-" .. i .. ">", function()
    jump_to_buffer(i)
  end, { 
    desc = "Jump to buffer " .. i, 
    silent = true,
    noremap = true
  })
end

-- Buffer navigation helpers
vim.keymap.set("n", "gtn", ":bnext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "gtp", ":bprevious<CR>", { desc = "Previous buffer", silent = true })

-- Smart buffer delete
vim.keymap.set("n", "<leader>bd", ":bp|bd #<CR>", { desc = "Delete current buffer", silent = true })

-- Telescope buffer picker
vim.keymap.set("n", "<leader>b", ":Telescope buffers<CR>", { desc = "List all buffers", silent = true })
