local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

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
      { "Failed to install lazy.nvim:\n", "ErrorMsg" },
      { result, "WarningMsg" },
    }, true, {})
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
  { import = "psychovim.plugin_overrides" },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  install = { colorscheme = { "catppuccin" } },
  ui = {
    border = "rounded",
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
