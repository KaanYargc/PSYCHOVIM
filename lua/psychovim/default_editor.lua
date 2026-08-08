local M = {}

local cache = { ok = nil, issues = {}, checked_at = 0 }
local ttl_ns = 5 * 1e9
local enforcing = false

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function is_pycho(value)
  value = trim(value):lower()
  return value:match("pycho[%s\"']*$") ~= nil or value:find("/pycho", 1, true) ~= nil
end

local function command_output(argv)
  local ok, result = pcall(function()
    return vim.system(argv, { text = true }):wait()
  end)
  if not ok or not result or result.code ~= 0 then return nil end
  return trim(result.stdout)
end

local function inspect()
  local issues = {}
  local editor = vim.env.EDITOR or ""
  local visual = vim.env.VISUAL or ""

  if not is_pycho(editor) then issues[#issues + 1] = "EDITOR" end
  if not is_pycho(visual) then issues[#issues + 1] = "VISUAL" end

  local sysname = (vim.uv.os_uname().sysname or ""):lower()
  if sysname == "linux" and vim.fn.executable("xdg-mime") == 1 then
    local mime = command_output({ "xdg-mime", "query", "default", "text/plain" })
    if mime ~= "psychovim.desktop" then issues[#issues + 1] = "text/plain" end
  end

  if vim.fn.executable("git") == 1 then
    local git_editor = command_output({ "git", "config", "--global", "--get", "core.editor" })
    if git_editor and git_editor ~= "" and not is_pycho(git_editor) then
      issues[#issues + 1] = "git editor"
    end
  end

  cache.ok = #issues == 0
  cache.issues = issues
  cache.checked_at = vim.uv.hrtime()
  return cache.ok, cache.issues
end

local function pycho_executable()
  local pycho = vim.fn.exepath("pycho")
  if pycho ~= "" then return pycho end
  return vim.fn.stdpath("config") .. "/bin/pycho"
end

function M.refresh()
  return inspect()
end

function M.status(force)
  local stale = cache.ok == nil or (vim.uv.hrtime() - cache.checked_at) > ttl_ns
  if force or stale then return inspect() end
  return cache.ok, cache.issues
end

function M.is_default(force)
  local ok = M.status(force)
  return ok
end

function M.make_default(opts)
  opts = opts or {}
  if enforcing then return end

  local pycho = pycho_executable()
  if vim.fn.executable(pycho) ~= 1 then return end

  enforcing = true
  vim.system({ pycho, "default-editor", "--quiet" }, { text = true }, function(result)
    vim.schedule(function()
      enforcing = false
      if result.code == 0 then
        vim.env.EDITOR = pycho
        vim.env.VISUAL = pycho
        vim.env.GIT_EDITOR = pycho
        M.refresh()
        vim.cmd("redrawstatus")
        if opts.notify then
          vim.notify("Default editor policy set to PychoVIM.", vim.log.levels.INFO, { title = "PychoVIM" })
        end
      elseif opts.notify_errors ~= false then
        local message = trim(result.stderr ~= "" and result.stderr or result.stdout)
        vim.notify(
          message ~= "" and message or "Default editor policy could not be applied.",
          vim.log.levels.ERROR,
          { title = "PychoVIM" }
        )
      end
      if opts.done then opts.done(result.code == 0) end
    end)
  end)
end

function M.enforce()
  if vim.env.PSYCHOVIM_MAINTENANCE == "1" then return end
  local ok = M.status(false)
  if ok then return end
  M.make_default({ notify = false, notify_errors = true })
end

return M
