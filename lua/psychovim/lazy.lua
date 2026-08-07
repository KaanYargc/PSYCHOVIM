local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local pycho_state = vim.fn.stdpath("state") .. "/psychovim"
vim.fn.mkdir(pycho_state, "p")

if not vim.uv.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "lazy.nvim bootstrap failed:\n", "ErrorMsg" },
      { result, "WarningMsg" },
    }, true, {})
    return
  end
end

vim.opt.rtp:prepend(lazypath)

local settings = require("psychovim.settings")

require("lazy").setup({
  { import = "plugins" },
  { import = "psychovim.plugin_overrides" },
}, {
  lockfile = pycho_state .. "/lazy-lock.json",
  concurrency = 2,
  git = {
    timeout = 300,
    throttle = {
      enabled = true,
      rate = 2,
      duration = 3000,
    },
  },
  checker = {
    enabled = settings.get("plugin_update_check") == true,
    notify = false,
    frequency = 0,
    concurrency = 1,
  },
  change_detection = { notify = false },
  install = { colorscheme = { "catppuccin" } },
  headless = {
    process = true,
    log = true,
    task = true,
    colors = false,
  },
  ui = {
    border = settings.get("popup_border") or "rounded",
    icons = {
      cmd = "⌘",
      config = "⚙",
      event = "◉",
      ft = "󰈙",
      init = "⚡",
      keys = "󰌌",
      lazy = "󰒲",
      plugin = "󰏗",
      runtime = "󰅪",
      source = "󰈮",
      start = "󰐕",
      task = "󰄬",
    },
  },
})
