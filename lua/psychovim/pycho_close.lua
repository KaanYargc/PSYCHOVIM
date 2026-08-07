local M = {}

local state = { win = nil, buf = nil }

local function modified_buffer_count()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].modified then
      count = count + 1
    end
  end
  return count
end

local function close_popup()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
  state.win, state.buf = nil, nil
end

local function save_and_quit()
  close_popup()
  local ok, err = pcall(vim.cmd, "wall")
  if not ok then
    vim.notify("PychoClose · save failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.cmd("qa")
end

local function quit_without_saving()
  close_popup()
  vim.cmd("qa!")
end

local actions = { [3] = save_and_quit, [4] = quit_without_saving, [5] = close_popup }

local function select_line(line)
  line = math.max(3, math.min(5, line))
  vim.api.nvim_win_set_cursor(state.win, { line, 0 })
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local modified = modified_buffer_count()
  local lines = {
    modified == 0 and "Clean." or string.format("Dirty buffers: %d", modified),
    "",
    "  1  Save all & exit",
    "  2  Exit dirty",
    "  3  Cancel",
  }

  local width, height = 44, #lines
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
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = "rounded",
    title = " PychoClose ",
    title_pos = "center",
    noautocmd = true,
  })

  vim.wo[state.win].cursorline = true
  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:DiagnosticError,CursorLine:Visual"
  select_line(3)

  local opts = { buffer = state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "1", save_and_quit, opts)
  vim.keymap.set("n", "2", quit_without_saving, opts)
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

return M
