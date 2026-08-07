local M = {}

function M.setup()
  local theme = require("psychovim.theme")
  local card = require("psychovim.business_card")
  local dorsia = require("psychovim.dorsia")
  local routine = require("psychovim.routine")

  theme.setup()
  card.setup()
  dorsia.setup()
  routine.setup()
  theme.apply(vim.g.psychovim_mask or "sanity")

  local map = vim.keymap.set
  map("n", "<leader>pb", card.open, { desc = "PSYCHOVIM business card" })
  map("n", "<leader>pm", theme.toggle, { desc = "Toggle Mask / After Hours" })
  map("n", "<leader>pr", routine.open, { desc = "Morning Routine" })
  map("n", "<leader>pd", dorsia.open, { desc = "Dorsia reservations" })
  map("n", "<leader>ps", dorsia.save, { desc = "Save Dorsia reservation" })
  map("n", "<leader>px", dorsia.forget, { desc = "Cancel Dorsia reservation" })
end

return M
