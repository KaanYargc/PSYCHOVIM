local M = {}

local state = { win = nil, buf = nil, row = 6 }
local settings_dir = vim.fn.stdpath("state") .. "/psychovim"
local settings_file = settings_dir .. "/settings.json"

local defaults = {
  mask = "sanity",
  autoformat = true,
  relativenumber = true,
  diagnostics = true,
  cursorline = true,
  pycho_close = true,
  pycho_save = true,
  ctrl_z_undo = true,
  familiar_shortcuts = true,
  safe_visual_paste = true,
  confirm = true,
}

local config = vim.deepcopy(defaults)

local function save()
  vim.fn.mkdir(settings_dir, "p")
  pcall(vim.fn.writefile, { vim.json.encode(config) }, settings_file)
end

local function load()
  if vim.fn.filereadable(settings_file) == 0 then return end
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(settings_file), "\n"))
  if ok and type(decoded) == "table" then
    config = vim.tbl_deep_extend("force", config, decoded)
  end
end

local function apply()
  vim.g.psychovim_mask = config.mask
  vim.g.disable_autoformat = not config.autoformat
  vim.g.pycho_close = config.pycho_close
  vim.g.pycho_save = config.pycho_save
  vim.g.pycho_ctrl_z_undo = config.ctrl_z_undo
  vim.g.pycho_familiar_shortcuts = config.familiar_shortcuts
  vim.g.pycho_safe_visual_paste = config.safe_visual_paste
  vim.o.relativenumber = config.relativenumber
  vim.o.cursorline = config.cursorline
  vim.o.confirm = config.confirm
  vim.diagnostic.enable(config.diagnostics)
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
  state.win, state.buf = nil, nil
end

local function onoff(value) return value and "ON" or "OFF" end

local rows = {
  { section = "WORKSTATION" },
  { key = "mask", name = "Mask", value = function() return config.mask == "after_hours" and "AFTER HOURS" or "SANITY" end,
    toggle = function() config.mask = config.mask == "after_hours" and "sanity" or "after_hours"; require("psychovim.theme").apply(config.mask) end },
  { key = "autoformat", name = "Autoformat", value = function() return onoff(config.autoformat) end },
  { key = "relativenumber", name = "Relative numbers", value = function() return onoff(config.relativenumber) end },
  { key = "diagnostics", name = "Diagnostics", value = function() return onoff(config.diagnostics) end },
  { key = "cursorline", name = "Cursor line", value = function() return onoff(config.cursorline) end },
  { section = "PYCHO PATCHES" },
  { key = "pycho_close", name = "PychoClose C-c/C-d", value = function() return onoff(config.pycho_close) end },
  { key = "pycho_save", name = "PychoSave C-s", value = function() return onoff(config.pycho_save) end },
  { key = "ctrl_z_undo", name = "C-z means undo", value = function() return onoff(config.ctrl_z_undo) end },
  { key = "familiar_shortcuts", name = "C-f/C-p/C-a", value = function() return onoff(config.familiar_shortcuts) end },
  { key = "safe_visual_paste", name = "Safe visual paste", value = function() return onoff(config.safe_visual_paste) end },
  { key = "confirm", name = "Unsaved confirm", value = function() return onoff(config.confirm) end },
}

local selectable = {}
local function rebuild_selectable()
  selectable = {}
  for i, item in ipairs(rows) do if not item.section then selectable[#selectable + 1] = i end end
end
rebuild_selectable()

local function apply_item(item)
  if item.toggle then item.toggle() else config[item.key] = not config[item.key] end
  apply()
  save()
end

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  local lines = {
    "  PIERCE & PIERCE / SYSTEM PREFERENCES",
    "  workstation profile",
    "",
    "  ENTER toggles. q leaves.",
    "",
  }
  for _, item in ipairs(rows) do
    if item.section then
      lines[#lines + 1] = "  " .. item.section
    else
      lines[#lines + 1] = string.format("    %-25s %s", item.name, item.value())
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "  There is an idea of a configuration."
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
end

local function row_to_line(row_index) return 5 + row_index end
local function select(index)
  index = math.max(1, math.min(#selectable, index))
  state.row = index
  vim.api.nvim_win_set_cursor(state.win, { row_to_line(selectable[index]), 0 })
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_set_current_win(state.win); return end
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype, vim.bo[state.buf].bufhidden, vim.bo[state.buf].swapfile = "nofile", "wipe", false
  render()
  local width = math.min(68, math.max(54, vim.o.columns - 12))
  local height = 7 + #rows
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
    local item = rows[selectable[state.row]]
    if item then apply_item(item); render(); select(state.row) end
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
  load()
  apply()
  vim.api.nvim_create_user_command("PychoSettings", M.open, { desc = "Open PSYCHOVIM settings" })
end

function M.get(key) return config[key] end

return M
