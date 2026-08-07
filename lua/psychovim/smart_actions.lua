local M = {}

local state = { win = nil, buf = nil }

local function notify(message, level)
  vim.notify("PSYCHOVIM · " .. message, level or vim.log.levels.INFO)
end

local function close_popup()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

local function is_writable_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].modifiable
end

local function write_buffer(buf, after)
  if not is_writable_buffer(buf) then
    notify("This buffer is not a writable file.", vim.log.levels.WARN)
    return
  end

  local function finish(ok, err)
    if not ok then
      notify("Save failed: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    notify("Filed. Immaculate.")
    if after then
      after()
    end
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    vim.ui.input({ prompt = "Save as: " }, function(path)
      if not path or vim.trim(path) == "" then
        notify("Save cancelled.", vim.log.levels.WARN)
        return
      end
      local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
        vim.cmd("write " .. vim.fn.fnameescape(vim.fn.expand(path)))
      end)
      finish(ok, err)
    end)
    return
  end

  local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
    vim.cmd("silent update")
  end)
  finish(ok, err)
end

function M.save()
  write_buffer(vim.api.nvim_get_current_buf())
end

local function delete_buffer(force)
  close_popup()
  local command = force and "bdelete!" or "bdelete"
  local ok, err = pcall(vim.cmd, command)
  if not ok then
    notify("Could not close buffer: " .. tostring(err), vim.log.levels.ERROR)
  end
end

local function save_and_delete()
  close_popup()
  local buf = vim.api.nvim_get_current_buf()
  write_buffer(buf, function()
    if vim.api.nvim_buf_is_valid(buf) then
      local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = false })
      if not ok then
        notify("Saved, but could not close buffer: " .. tostring(err), vim.log.levels.ERROR)
      end
    end
  end)
end

local actions = {
  [3] = save_and_delete,
  [4] = function() delete_buffer(true) end,
  [5] = close_popup,
}

local function select_line(line)
  line = math.max(3, math.min(5, line))
  vim.api.nvim_win_set_cursor(state.win, { line, 0 })
end

local function open_close_popup()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local name = vim.api.nvim_buf_get_name(0)
  local display = name == "" and "Untitled" or vim.fn.fnamemodify(name, ":t")
  local lines = {
    string.format("Unsaved changes in %s", display),
    "",
    "  1  Save & close",
    "  2  Close without saving",
    "  3  Cancel",
  }

  local width = math.max(46, math.min(70, #lines[1] + 6))
  local height = #lines
  local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " SmartBufferClose ",
    title_pos = "center",
    noautocmd = true,
  })

  vim.wo[state.win].cursorline = true
  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:DiagnosticWarn,CursorLine:Visual"
  select_line(3)

  local opts = { buffer = state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "1", save_and_delete, opts)
  vim.keymap.set("n", "2", function() delete_buffer(true) end, opts)
  vim.keymap.set("n", "3", close_popup, opts)
  vim.keymap.set("n", "<Esc>", close_popup, opts)
  vim.keymap.set("n", "q", close_popup, opts)
  vim.keymap.set("n", "j", function()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    select_line(line == 5 and 3 or line + 1)
  end, opts)
  vim.keymap.set("n", "k", function()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    select_line(line == 3 and 5 or line - 1)
  end, opts)
  vim.keymap.set("n", "<Down>", "j", { buffer = state.buf, remap = true, silent = true })
  vim.keymap.set("n", "<Up>", "k", { buffer = state.buf, remap = true, silent = true })
  vim.keymap.set("n", "<CR>", function()
    local action = actions[vim.api.nvim_win_get_cursor(state.win)[1]]
    if action then action() end
  end, opts)
end

function M.close_buffer()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified and is_writable_buffer(buf) then
    open_close_popup()
    return
  end
  delete_buffer(false)
end

function M.terminal_ctrl_s()
  notify("Ctrl+S blocked in terminal mode to prevent flow-control freeze. Use it in an editor buffer to save.", vim.log.levels.WARN)
end

return M
