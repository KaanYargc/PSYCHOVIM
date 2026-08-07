local M = {}

local state = { win = nil, buf = nil, row = 5 }

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
  state.win, state.buf = nil, nil
end

local function onoff(v) return v and "ON" or "OFF" end

local items = {
  {
    name = "Mask",
    value = function() return vim.g.psychovim_mask == "after_hours" and "AFTER HOURS" or "SANITY" end,
    toggle = function() require("psychovim.theme").toggle() end,
  },
  {
    name = "Autoformat",
    value = function() return onoff(not vim.g.disable_autoformat) end,
    toggle = function() vim.g.disable_autoformat = not vim.g.disable_autoformat end,
  },
  {
    name = "Relative numbers",
    value = function() return onoff(vim.o.relativenumber) end,
    toggle = function() vim.o.relativenumber = not vim.o.relativenumber end,
  },
  {
    name = "Diagnostics",
    value = function() return onoff(vim.diagnostic.is_enabled()) end,
    toggle = function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
  },
  {
    name = "Cursor line",
    value = function() return onoff(vim.o.cursorline) end,
    toggle = function() vim.o.cursorline = not vim.o.cursorline end,
  },
}

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  local lines = {
    "  PIERCE & PIERCE / SYSTEM PREFERENCES",
    "  PSYCHOVIM workstation profile",
    "",
    "  ENTER toggles. q leaves.",
  }
  for i, item in ipairs(items) do
    lines[#lines + 1] = string.format("  %-22s %s", item.name, item.value())
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "  There is an idea of a configuration."
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
end

local function select(row)
  row = math.max(5, math.min(4 + #items, row))
  state.row = row
  vim.api.nvim_win_set_cursor(state.win, { row, 0 })
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_set_current_win(state.win); return end
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  render()

  local width = math.min(62, math.max(48, vim.o.columns - 12))
  local height = 5 + #items + 1
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor", width = width, height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal", border = "single", title = " PYCHO SETTINGS ", title_pos = "center",
  })
  vim.wo[state.win].cursorline = true
  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:PsychovimCardTitle,CursorLine:Visual"
  select(state.row)

  local opts = { buffer = state.buf, silent = true, nowait = true }
  local function move(delta) select(state.row + delta) end
  local function toggle()
    local item = items[state.row - 4]
    if item then item.toggle(); render(); select(state.row) end
  end
  vim.keymap.set("n", "j", function() move(1) end, opts)
  vim.keymap.set("n", "k", function() move(-1) end, opts)
  vim.keymap.set("n", "<Down>", function() move(1) end, opts)
  vim.keymap.set("n", "<Up>", function() move(-1) end, opts)
  vim.keymap.set("n", "<CR>", toggle, opts)
  vim.keymap.set("n", "<Space>", toggle, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

function M.setup()
  vim.api.nvim_create_user_command("PychoSettings", M.open, { desc = "Open PSYCHOVIM settings" })
end

return M
