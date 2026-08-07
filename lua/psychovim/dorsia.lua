local M = {}

local session_dir = vim.fn.stdpath("state") .. "/psychovim/dorsia"

local function notify(message, level)
  vim.notify("Dorsia · " .. message, level or vim.log.levels.INFO)
end

local function ensure_dir()
  vim.fn.mkdir(session_dir, "p")
end

local function session_path(cwd)
  cwd = vim.fn.fnamemodify(cwd or vim.fn.getcwd(), ":p"):gsub("/$", "")
  local name = vim.fn.fnamemodify(cwd, ":t")
  if name == "" then name = "root" end
  name = name:gsub("[^%w%._%-]", "_")
  return string.format("%s/%s--%s.vim", session_dir, name, vim.fn.sha256(cwd):sub(1, 10))
end

local function modified_count()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].modified then
      count = count + 1
    end
  end
  return count
end

local function has_project_context()
  if vim.fn.argc() > 0 then return true end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      return true
    end
  end
  return false
end

function M.save(opts)
  opts = opts or {}
  ensure_dir()
  local path = session_path()
  local ok, err = pcall(vim.cmd, "silent mksession! " .. vim.fn.fnameescape(path))
  if not ok then
    if not opts.quiet then notify("Reservation failed: " .. tostring(err), vim.log.levels.ERROR) end
    return false
  end
  if not opts.quiet then
    notify("Reservation confirmed for " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ".")
  end
  return true
end

local function list_sessions()
  ensure_dir()
  local files = vim.fn.globpath(session_dir, "*.vim", false, true)
  table.sort(files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  return files
end

local function display_name(path)
  local name = vim.fn.fnamemodify(path, ":t:r")
  name = name:gsub("%-%-[0-9a-f]+$", "")
  return name:gsub("_", " ")
end

local function load(path)
  if modified_count() > 0 then
    notify("Reservation denied: unsaved buffers are still at the table. Save or SmartClose them first.", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.cmd, "silent source " .. vim.fn.fnameescape(path))
  if not ok then
    notify("Could not seat this reservation: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  notify("Reservation seated.")
end

function M.open()
  local sessions = list_sessions()
  if #sessions == 0 then
    notify("No reservation found. Use :DorsiaSave inside a project first.", vim.log.levels.WARN)
    return
  end

  vim.ui.select(sessions, {
    prompt = "Dorsia — select reservation",
    format_item = display_name,
  }, function(choice)
    if choice then load(choice) end
  end)
end

function M.forget()
  local path = session_path()
  if vim.fn.filereadable(path) == 0 then
    notify("There is no reservation for this project.", vim.log.levels.WARN)
    return
  end
  local ok = vim.fn.delete(path) == 0
  if ok then
    notify("Reservation cancelled.")
  else
    notify("Reservation could not be cancelled.", vim.log.levels.ERROR)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("Dorsia", M.open, { desc = "Open a saved project reservation" })
  vim.api.nvim_create_user_command("DorsiaSave", M.save, { desc = "Reserve the current project session" })
  vim.api.nvim_create_user_command("DorsiaForget", M.forget, { desc = "Forget the current project reservation" })

  local group = vim.api.nvim_create_augroup("PsychovimDorsia", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if has_project_context() then
        pcall(M.save, { quiet = true })
      end
    end,
  })
end

return M
