-- ==========================================
-- 1. BOOTSTRAP LAZY.NVIM
-- ==========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================
-- 2. PLUGINS
-- ==========================================
require("lazy").setup({
  -- Theme: Tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        italic_comments = true,
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "tokyonight" } }
  },
  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "bash", "python" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  }
})

-- ==========================================
-- 3. SETTINGS
-- ==========================================
vim.opt.number = true     -- Show line numbers
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 10    -- Keep 10 lines context
vim.opt.visualbell = true -- Flash instead of beep
vim.opt.mouse = "a"       -- Enable mouse

-- Indentation
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Behavior
vim.opt.ignorecase = true         -- Ignore case when searching...
vim.opt.smartcase = true          -- ...unless uppercase is used
vim.opt.updatetime = 250          -- Faster completion
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- ==========================================
-- 4. CLIPBOARD & OS HANDLING
-- ==========================================
local uname = vim.loop.os_uname().sysname

if uname == "Darwin" then
  -- MacOS
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
  }
elseif uname == "Linux" then
  -- Arch (Wayland/Caelestia)
  if os.getenv("WAYLAND_DISPLAY") then
    vim.g.clipboard = {
      name = "wl-clipboard",
      copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
      paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
    }
  -- Remote Server via SSH
  elseif os.getenv("SSH_TTY") then
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  end
end

-- ==========================================
-- 5. MAPPINGS
-- ==========================================
vim.keymap.set("v", "<C-c>", '"+y')         -- Copy
vim.keymap.set("n", "<C-v>", '"+p')         -- Paste normal mode
vim.keymap.set("i", "<C-v>", '<C-r><C-o>+') -- Paste insert mode

