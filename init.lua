vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("psychovim.options")
require("psychovim.settings").setup()
require("psychovim.keymaps")
require("psychovim.autocmds")
require("psychovim.lazy")
require("psychovim.features").setup()
