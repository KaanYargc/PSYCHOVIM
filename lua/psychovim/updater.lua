local M = {}

local state = { running = false }

local function pycho_executable()
  local path = vim.fn.exepath("pycho")
  if path ~= "" then return path end
  return vim.fn.stdpath("config") .. "/bin/pycho"
end

local function notify(message, level)
  if not message or message == "" then return end
  vim.schedule(function()
    vim.notify(message, level or vim.log.levels.INFO, { title = "pychoUpdater" })
  end)
end

local function auto_enabled()
  local settings = require("psychovim.settings")
  return settings.get("auto_update_config") == true
    or settings.get("auto_update_plugins") == true
    or settings.get("auto_update_parsers") == true
end

local function handle_phase(line, terminal)
  local kind, message = line:match("^@@PYCHO|([^|]+)|(.+)$")
  if not kind then return end

  local level = vim.log.levels.INFO
  if kind == "warn" then level = vim.log.levels.WARN end
  if kind == "error" then level = vim.log.levels.ERROR end
  if kind == "done" or kind == "warn" or kind == "error" then terminal.value = true end

  message = message:gsub("PSYCHOVIM", "PychoVIM")
  notify(message, level)
end

function M.run(opts)
  opts = opts or {}
  if state.running then
    if not opts.auto then notify("Update already running.") end
    return
  end
  if opts.auto and not auto_enabled() then return end

  local pycho = pycho_executable()
  if vim.fn.executable(pycho) ~= 1 then
    notify("pycho launcher not found.", vim.log.levels.ERROR)
    return
  end

  state.running = true
  local terminal = { value = false }
  notify(opts.auto and "Checking updates..." or "Checking for PychoVIM updates...")

  local command = { pycho, opts.auto and "auto-update" or "update", "--ui-stream" }
  local job = vim.fn.jobstart(command, {
    stdout_buffered = false,
    stderr_buffered = true,
    on_stdout = function(_, data)
      for _, line in ipairs(data or {}) do
        if line ~= "" then handle_phase(line, terminal) end
      end
    end,
    on_stderr = function(_, data)
      if not data then return end
      local text = table.concat(data, "\n"):gsub("%s+$", "")
      if text ~= "" then vim.g.pycho_updater_last_error = text end
    end,
    on_exit = function(_, code)
      state.running = false
      if code ~= 0 and not terminal.value then
        local message = vim.g.pycho_updater_last_error
        vim.g.pycho_updater_last_error = nil
        notify(message and message ~= "" and message or "Update failed. See ~/.cache/psychovim/.", vim.log.levels.ERROR)
      elseif code == 0 and not terminal.value then
        notify("PychoVIM is up to date.")
      end
    end,
  })

  if job <= 0 then
    state.running = false
    notify("Could not start updater.", vim.log.levels.ERROR)
  end
end

function M.setup()
  if vim.fn.exists(":PychoUpdate") == 0 then
    vim.api.nvim_create_user_command("PychoUpdate", function() M.run() end, { desc = "Run pychoUpdate now" })
  end
  if vim.fn.exists(":PychoUpdater") == 0 then
    vim.api.nvim_create_user_command("PychoUpdater", function() M.run() end, { desc = "Run pychoUpdater now" })
  end

  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("PychoUpdater", { clear = true }),
    once = true,
    callback = function()
      if vim.env.PSYCHOVIM_MAINTENANCE == "1" then return end
      if vim.env.PSYCHOVIM_AUTOUPDATE_REQUEST ~= "1" then return end
      vim.env.PSYCHOVIM_AUTOUPDATE_REQUEST = nil
      vim.defer_fn(function() M.run({ auto = true }) end, 120)
    end,
  })
end

return M
