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
      { "lazy.nvim bootstrap failed:\n", "ErrorMsg" },
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
  -- Unlimited parallel Git jobs are fast on a datacenter and stupid on flaky Wi-Fi.
  concurrency = 2,
  git = {
    timeout = 300,
    throttle = {
      enabled = true,
      rate = 2,
      duration = 3000,
    },
  },
  -- Don't turn every startup into a GitHub update sweep. :Lazy check exists.
  checker = { enabled = false, notify = false },
  change_detection = { notify = false },
  install = { colorscheme = { "catppuccin" } },
  headless = {
    process = true,
    log = true,
    task = true,
    colors = false,
  },
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
