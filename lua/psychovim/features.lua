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
  marketplace.apply_active_theme()
  theme.apply(vim.g.psychovim_mask or "sanity")

  command("PychoSave", actions.save, "Save the current buffer")
  command("PychoClose", close.open, "Open PychoClose")
  command("PychoBufferClose", actions.close_buffer, "Close the current buffer safely")
  command("PychoMakeDefault", function() default_editor.make_default({ notify = true }) end, "Apply the PychoVIM default editor policy")

  local map = vim.keymap.set
  map("n", "<leader>pb", card.open, { desc = "PychoVIM Business Card" })
  map("n", "<leader>pm", theme.toggle, { desc = "PychoVIM Mask" })
  map("n", "<leader>pr", routine.open, { desc = "PychoVIM Morning Routine" })
  map("n", "<leader>pd", dorsia.open, { desc = "PychoVIM Dorsia" })
  map("n", "<leader>pS", dorsia.save, { desc = "PychoVIM Dorsia Save" })
  map("n", "<leader>px", dorsia.forget, { desc = "PychoVIM Dorsia Forget" })
  map("n", "<leader>ps", settings.open, { desc = "⚙ PychoVIM Settings" })
  map("n", "<leader>pp", marketplace.open, { desc = "󰏗 PychoVIM Extensions" })
  map("n", "<leader>pu", updater.run, { desc = "pychoUpdater" })

  local group = vim.api.nvim_create_augroup("PychoDefaultEditorPolicy", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      vim.defer_fn(default_editor.enforce, 250)
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      vim.defer_fn(default_editor.enforce, 100)
    end,
  })
end

return M
