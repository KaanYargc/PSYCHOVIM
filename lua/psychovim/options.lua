local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.updatetime = 200
opt.timeoutlen = 300

-- Native safety net for commands we do not wrap ourselves. Instead of E37/E89,
-- Neovim asks what to do with unsaved changes.
opt.confirm = true

-- Dorsia sessions restore the useful shape of a project without carrying UI noise.
opt.sessionoptions = {
  "buffers",
  "curdir",
  "folds",
  "help",
  "tabpages",
  "winsize",
  "terminal",
  "localoptions",
}

opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12

opt.list = true
opt.listchars = {
  tab = "→ ",
  trail = "·",
  extends = "»",
  precedes = "«",
  nbsp = "␣",
}

opt.fillchars = {
  eob = " ",
  fold = "─",
  foldopen = "▼",
  foldclose = "▶",
  foldsep = "│",
  diff = "╱",
  vert = "│",
}
