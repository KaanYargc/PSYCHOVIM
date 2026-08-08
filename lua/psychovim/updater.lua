local M = {}

local function pycho_executable()
  local path = vim.fn.exepath("pycho")
  if path ~= "" then return path end
  return vim.fn.stdpath("config") .. "/bin/pycho"
end

function M.run()
  vim.notify("Checking config, plugins, tools and parsers...", vim.log.levels.INFO, { title = "pychoUpdater" })
  vim.system({ pycho_executable(), "update" }, { text = true }, function(result)
    vim.schedule(function()
      local output = (result.stdout or ""):gsub("%s+$", "")
      if result.code == 0 then
        vim.notify(output ~= "" and output or "Update complete.", vim.log.levels.INFO, { title = "pychoUpdater" })
      else
        local err = (result.stderr or ""):gsub("%s+$", "")
        vim.notify(err ~= "" and err or output ~= "" and output or "Update failed.", vim.log.levels.ERROR, { title = "pychoUpdater" })
      end
    end)
  end)
end

function M.notice()
  local message = vim.env.PSYCHOVIM_UPDATER_NOTICE
  if not message or message == "" then return end
  local warning = vim.env.PSYCHOVIM_UPDATER_WARNING == "1"
  vim.env.PSYCHOVIM_UPDATER_NOTICE = nil
  vim.env.PSYCHOVIM_UPDATER_WARNING = nil
  vim.schedule(function()
    vim.notify(message, warning and vim.log.levels.WARN or vim.log.levels.INFO, { title = "pychoUpdater" })
  end)
end

function M.setup()
  if vim.fn.exists(":PychoUpdate") == 0 then
    vim.api.nvim_create_user_command("PychoUpdate", M.run, { desc = "Run pychoUpdater now" })
  end
  if vim.fn.exists(":PychoUpdater") == 0 then
    vim.api.nvim_create_user_command("PychoUpdater", M.run, { desc = "Run pychoUpdater now" })
  end

  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("PychoUpdaterNotice", { clear = true }),
    once = true,
    callback = M.notice,
  })
end

return M
