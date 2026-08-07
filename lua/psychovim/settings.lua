local M = {}

local state = { win = nil, buf = nil, row = 1 }
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
  terminal_escape = true,
  plugin_update_check = false,
}

local config = vim.deepcopy(defaults)

local function save()
  vim.fn.mkdir(settings_dir, "p")
  local ok, encoded = pcall(vim.json.encode, config)
  if not ok then return false end
  return pcall(vim.fn.writefile, { encoded }, settings_file)
end

function M.load()
  config = vim.deepcopy(defaults)
  if vim.fn.filereadable(settings_file) == 1 then
    local ok_read, raw = pcall(vim.fn.readfile, settings_file)
    if ok_read then
      local ok_json, decoded = pcall(vim.json.decode, table.concat(raw, "\n"))
      if ok_json and type(decoded) == "table" then
        config = vim.tbl_deep_extend("force", config, decoded)
      end
    end
  end

  vim.g.psychovim_mask = config.mask
  vim.g.disable_autoformat = not config.autoformat
  vim.o.relativenumber = config.relativenumber
  vim.o.cursorline = config.cursorline
  vim.o.confirm = config.confirm
  vim.diagnostic.enable(config.diagnostics)
  return config
end

function M.get(key)
  if key then return config[key] end
  return config
end

local function apply_item(key)
  if key == "mask" then
    vim.g.psychovim_mask = config.mask
    local ok, theme = pcall(require, "psychovim.theme")
    if ok then theme.apply(config.mask) end
  elseif key == "autoformat" then
    vim.g.disable_autoformat = not config.autoformat
  elseif key == "relativenumber" then
    vim.o.relativenumber = config.relativenumber
  elseif key == "diagnostics" then
    vim.diagnostic.enable(config.diagnostics)
  elseif key == "cursorline" then
    vim.o.cursorline = config.cursorline
  elseif key == "confirm" then
    vim.o.confirm = config.confirm
  elseif key == "plugin_update_check" then
    vim.notify("Pycho · checker changes after restart")
  end
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_win_close(state.win, true) end
  state.win, state.buf = nil, nil
end

local function onoff(value)
  return value and "ON" or "OFF"
end

local rows = {
  { section = "WORKSTATION" },
  { key = "mask", name = "Mask", value = function() return config.mask == "after_hours" and "AFTER HOURS" or "SANITY" end },
  { key = "autoformat", name = "Format on save", value = function() return onoff(config.autoformat) end },
  { key = "relativenumber", name = "Relative numbers", value = function() return onoff(config.relativenumber) end },
  { key = "diagnostics", name = "Diagnostics", value = function() return onoff(config.diagnostics) end },
  { key = "cursorline", name = "Cursor line", value = function() return onoff(config.cursorline) end },
  { key = "plugin_update_check", name = "Plugin update checker", value = function() return onoff(config.plugin_update_check) end },
  { section = "PYCHO PATCHES" },
  { key = "pycho_close", name = "Ctrl+C/D -> PychoClose", value = function() return onoff(config.pycho_close) end },
  { key = "pycho_save", name = "Ctrl+S -> PychoSave", value = function() return onoff(config.pycho_save) end },
  { key = "ctrl_z_undo", name = "Ctrl+Z -> undo", value = function() return onoff(config.ctrl_z_undo) end },
  { key = "familiar_shortcuts", name = "Ctrl+F/P/A familiar keys", value = function() return onoff(config.familiar_shortcuts) end },
  { key = "safe_visual_paste", name = "Visual paste keeps yank", value = function() return onoff(config.safe_visual_paste) end },
  { key = "confirm", name = "Prompt on dirty exit", value = function() return onoff(config.confirm) end },
  { key = "terminal_escape", name = "Terminal Esc exits insert", value = function() return onoff(config.terminal_escape) end },
}

local selectable = {}
for row_index, item in ipairs(rows) do
  if not item.section then selectable[#selectable + 1] = row_index end
end

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  local lines = {
    "  PIERCE & PIERCE / SYSTEMS",
    "  workstation policy",
    "",
  }
  for _, item in ipairs(rows) do
    if item.section then
      lines[#lines + 1] = "  " .. item.section
    else
      lines[#lines + 1] = string.format("    %-31s %s", item.name, item.value())
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "  enter/space change   r reset   q leave"
  lines[#lines + 1] = "  saved immediately; survives pycho update"

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_cursor(state.win, { 3 + selectable[state.row], 2 })
  end
end

local function move(delta)
  state.row = ((state.row - 1 + delta) % #selectable) + 1
  render()
end

local function toggle_current()
  local item = rows[selectable[state.row]]
  if not item then return end

  if item.key == "mask" then
    config.mask = config.mask == "after_hours" and "sanity" or "after_hours"
  else
    config[item.key] = not config[item.key]
  end

  apply_item(item.key)
  save()
  render()
end

local function reset_all()
  config = vim.deepcopy(defaults)
  vim.g.psychovim_mask = config.mask
  vim.g.disable_autoformat = not config.autoformat
  vim.o.relativenumber = config.relativenumber
  vim.o.cursorline = config.cursorline
  vim.o.confirm = config.confirm
  vim.diagnostic.enable(config.diagnostics)
  local ok, theme = pcall(require, "psychovim.theme")
  if ok then theme.apply(config.mask) end
  save()
  render()
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then vim.api.nvim_set_current_win(state.win); return end

  state.row = 1
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false

  local width = math.max(40, math.min(76, vim.o.columns - 4))
  local height = math.max(10, math.min(#rows + 7, vim.o.lines - 4))
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = "single",
    title = " PYCHO SETTINGS ",
    title_pos = "center",
    noautocmd = true,
  })
  vim.wo[state.win].cursorline = true
  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:PsychovimCardTitle,CursorLine:Visual"

  local opts = { buffer = state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "j", function() move(1) end, opts)
  vim.keymap.set("n", "k", function() move(-1) end, opts)
  vim.keymap.set("n", "<Down>", function() move(1) end, opts)
  vim.keymap.set("n", "<Up>", function() move(-1) end, opts)
  vim.keymap.set("n", "<CR>", toggle_current, opts)
  vim.keymap.set("n", "<Space>", toggle_current, opts)
  vim.keymap.set("n", "r", reset_all, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
  render()
end

function M.setup()
  M.load()
  if vim.fn.exists(":PychoSettings") == 0 then
    vim.api.nvim_create_user_command("PychoSettings", M.open, { desc = "Open Pycho settings" })
  end
end

return M
