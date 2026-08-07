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
  local actions = require("psychovim.pycho_actions")
  local close = require("psychovim.pycho_close")

  theme.setup()
  card.setup()
  dorsia.setup()
  routine.setup()
  theme.apply(vim.g.psychovim_mask or "sanity")

  command("PychoSave", actions.save, "Save the current buffer")
  command("PychoClose", close.open, "Open PychoClose")
  command("PychoBufferClose", actions.close_buffer, "Close the current buffer safely")

  local map = vim.keymap.set
  map("n", "<leader>pb", card.open, { desc = "Pycho Business Card" })
  map("n", "<leader>pm", theme.toggle, { desc = "Pycho Mask" })
  map("n", "<leader>pr", routine.open, { desc = "Pycho Morning Routine" })
  map("n", "<leader>pd", dorsia.open, { desc = "Pycho Dorsia" })
  map("n", "<leader>pS", dorsia.save, { desc = "Pycho Dorsia Save" })
  map("n", "<leader>px", dorsia.forget, { desc = "Pycho Dorsia Forget" })
  map("n", "<leader>ps", settings.open, { desc = "Pycho Settings" })
end

return M
