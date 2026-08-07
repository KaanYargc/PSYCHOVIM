local M = {}

function M.setup()
  local theme = require("psychovim.theme")
  local card = require("psychovim.business_card")
  local dorsia = require("psychovim.dorsia")
  local routine = require("psychovim.routine")
  local settings = require("psychovim.settings")

  theme.setup()
  card.setup()
  dorsia.setup()
  routine.setup()
  theme.apply(vim.g.psychovim_mask or "sanity")

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
