local M = {}

local function command(name, fn, desc)
  if vim.fn.exists(":" .. name) == 0 then
    vim.api.nvim_create_user_command(name, fn, { desc = desc })
  end
end

function M.setup()
  local theme = require("psychovim.theme")
  local card = require("psychovim.business_card")
  local dorsia = require("psychovim.dorsia")
  local routine = require("psychovim.routine")
  local settings = require("psychovim.settings")
  local marketplace = require("psychovim.marketplace")
  local updater = require("psychovim.updater")
  local default_editor = require("psychovim.default_editor")
  local actions = require("psychovim.pycho_actions")
  local close = require("psychovim.pycho_close")

  theme.setup()
  card.setup()
  dorsia.setup()
  routine.setup()
  marketplace.setup()
  updater.setup()
  theme.apply(vim.g.psychovim_mask or "sanity")

  command("PychoSave", actions.save, "Save the current buffer")
  command("PychoClose", close.open, "Open PychoClose")
  command("PychoBufferClose", actions.close_buffer, "Close the current buffer safely")
  command("PychoMakeDefault", function() default_editor.make_default() end, "Make Pycho the default text editor")

  local map = vim.keymap.set
  map("n", "<leader>pb", card.open, { desc = "Pycho Business Card" })
  map("n", "<leader>pm", theme.toggle, { desc = "Pycho Mask" })
  map("n", "<leader>pr", routine.open, { desc = "Pycho Morning Routine" })
  map("n", "<leader>pd", dorsia.open, { desc = "Pycho Dorsia" })
  map("n", "<leader>pS", dorsia.save, { desc = "Pycho Dorsia Save" })
  map("n", "<leader>px", dorsia.forget, { desc = "Pycho Dorsia Forget" })
  map("n", "<leader>ps", settings.open, { desc = "⚙ Pycho Settings" })
  map("n", "<leader>pp", marketplace.open, { desc = "󰏗 Pycho Marketplace" })
  map("n", "<leader>pu", updater.run, { desc = "pychoUpdater" })

  local system_group = vim.api.nvim_create_augroup("PychoDefaultEditorWatch", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = system_group,
    once = true,
    callback = function()
      if vim.env.PSYCHOVIM_MAINTENANCE ~= "1" then default_editor.warn_if_changed() end
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = system_group,
    callback = function()
      if vim.env.PSYCHOVIM_MAINTENANCE == "1" then return end
      default_editor.refresh()
      vim.cmd("redrawstatus")
    end,
  })
end

return M
