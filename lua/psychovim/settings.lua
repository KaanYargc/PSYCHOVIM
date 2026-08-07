local M = {}

local state = { win = nil, buf = nil, row = 1 }
local settings_dir = vim.fn.stdpath("state") .. "/psychovim"
local settings_file = settings_dir .. "/settings.json"

local defaults = {
  mask = "sanity",

  number = true,
  relativenumber = true,
  tab_width = 4,
  expandtab = true,
  wrap = false,
  mouse = true,
  clipboard = true,
  undofile = true,
  smart_search = true,
  scrolloff = 8,

  cursorline = true,
  listchars = true,
  popup_border = "rounded",
  notifications = true,
  diagnostics = true,
  diagnostic_virtual_text = true,
  statusline = true,
  bufferline = true,

  completion = true,
  lsp = true,
  formatting = true,
  autoformat = true,
  treesitter = true,
  telescope = true,
  file_tree = true,
  gitsigns = true,
  indent_guides = true,
  todo_comments = true,
  autopairs = true,
  surround = true,
  which_key = true,

  highlight_yank = true,
  trim_whitespace = true,
  restore_cursor = true,
  startup_quip = false,

  pycho_close = true,
  pycho_save = true,
  ctrl_z_undo = true,
  familiar_shortcuts = true,
  safe_visual_paste = true,
  confirm = true,
  terminal_escape = true,

  auto_update_config = true,
  auto_update_plugins = true,
  auto_update_parsers = true,
  plugin_update_check = true,
}

local config = vim.deepcopy(defaults)

local restart_keys = {
  notifications = true,
  statusline = true,
  bufferline = true,
  completion = true,
  lsp = true,
  formatting = true,
  treesitter = true,
  telescope = true,
  file_tree = true,
  gitsigns = true,
  indent_guides = true,
  todo_comments = true,
  autopairs = true,
  surround = true,
  which_key = true,
  plugin_update_check = true,
}

local function save()
  vim.fn.mkdir(settings_dir, "p")
  local ok, encoded = pcall(vim.json.encode, config)
  if not ok then return false end
  return pcall(vim.fn.writefile, { encoded }, settings_file)
end

local function read()
  config = vim.deepcopy(defaults)
  if vim.fn.filereadable(settings_file) ~= 1 then return end

  local ok_read, raw = pcall(vim.fn.readfile, settings_file)
  if not ok_read then return end

  local ok_json, decoded = pcall(vim.json.decode, table.concat(raw, "\n"))
  if ok_json and type(decoded) == "table" then
    config = vim.tbl_deep_extend("force", config, decoded)
  end
end

function M.get(key)
  if key then return config[key] end
  return config
end

function M.defaults()
  return vim.deepcopy(defaults)
end

local function apply_runtime()
  vim.g.psychovim_mask = config.mask
  vim.g.disable_autoformat = not config.autoformat

  vim.o.number = config.number
  vim.o.relativenumber = config.relativenumber
  vim.o.tabstop = config.tab_width
  vim.o.shiftwidth = config.tab_width
  vim.o.softtabstop = config.tab_width
  vim.o.expandtab = config.expandtab
  vim.o.wrap = config.wrap
  vim.o.mouse = config.mouse and "a" or ""
  vim.o.undofile = config.undofile
  vim.o.ignorecase = config.smart_search
  vim.o.smartcase = config.smart_search
  vim.o.scrolloff = config.scrolloff
  vim.o.cursorline = config.cursorline
  vim.o.list = config.listchars
  vim.o.confirm = config.confirm
  vim.o.laststatus = config.statusline and 3 or 0

  if vim.fn.exists("+winborder") == 1 then vim.o.winborder = config.popup_border end
  if vim.fn.exists("+pumborder") == 1 then vim.o.pumborder = config.popup_border end

  if config.clipboard and vim.fn.has("clipboard") == 1 then
    vim.opt.clipboard = "unnamedplus"
  else
    vim.opt.clipboard = ""
  end

  vim.diagnostic.enable(config.diagnostics)
  vim.diagnostic.config({
    virtual_text = config.diagnostic_virtual_text and { spacing = 2, source = "if_many" } or false,
    float = { border = config.popup_border, source = "if_many" },
  })
end

function M.set(key, value)
  if defaults[key] == nil then return false end
  config[key] = value
  apply_runtime()

  if key == "mask" then
    local ok, theme = pcall(require, "psychovim.theme")
    if ok then theme.apply(config.mask) end
  end

  save()
  return true
end

function M.toggle_mask()
  local next_mode = config.mask == "after_hours" and "sanity" or "after_hours"
  M.set("mask", next_mode)
  vim.notify(next_mode == "sanity" and "Mask on." or "After hours.")
end

local function onoff(value)
  return value and "ON" or "OFF"
end

local function cycle(values)
  return function(value)
    for i, item in ipairs(values) do
      if item == value then return values[(i % #values) + 1] end
    end
    return values[1]
  end
end

local rows = {
  { section = "EDITOR" },
  { key = "number", name = "Line numbers" },
  { key = "relativenumber", name = "Relative numbers" },
  { key = "tab_width", name = "Tab / indent width", next = cycle({ 2, 4, 8 }) },
  { key = "expandtab", name = "Spaces instead of tabs" },
  { key = "wrap", name = "Line wrap" },
  { key = "mouse", name = "Mouse" },
  { key = "clipboard", name = "System clipboard" },
  { key = "undofile", name = "Persistent undo" },
  { key = "smart_search", name = "Smart-case search" },
  { key = "scrolloff", name = "Scroll margin", next = cycle({ 4, 8, 12 }) },

  { section = "UI" },
  { key = "mask", name = "Mask", next = cycle({ "sanity", "after_hours" }), display = function(v) return v == "after_hours" and "AFTER HOURS" or "SANITY" end },
  { key = "cursorline", name = "Cursor line" },
  { key = "listchars", name = "Invisible characters" },
  { key = "popup_border", name = "Popup border", next = cycle({ "rounded", "single", "double", "bold" }), display = string.upper },
  { key = "notifications", name = "Notification UI" },
  { key = "diagnostics", name = "Diagnostics" },
  { key = "diagnostic_virtual_text", name = "Diagnostic virtual text" },
  { key = "statusline", name = "Statusline" },
  { key = "bufferline", name = "Buffer tabs" },

  { section = "TOOLING" },
  { key = "completion", name = "Completion / blink.cmp" },
  { key = "lsp", name = "LSP / Mason" },
  { key = "formatting", name = "Formatter engine" },
  { key = "autoformat", name = "Format on save" },
  { key = "treesitter", name = "Treesitter" },
  { key = "telescope", name = "Telescope" },
  { key = "file_tree", name = "File tree" },
  { key = "gitsigns", name = "Git signs" },
  { key = "indent_guides", name = "Indent guides" },
  { key = "todo_comments", name = "TODO comments" },
  { key = "autopairs", name = "Autopairs" },
  { key = "surround", name = "Surround" },
  { key = "which_key", name = "Which-key" },

  { section = "AUTOMATION" },
  { key = "highlight_yank", name = "Highlight yank" },
  { key = "trim_whitespace", name = "Trim whitespace on save" },
  { key = "restore_cursor", name = "Restore last cursor" },
  { key = "startup_quip", name = "Startup deadpan" },

  { section = "PYCHO PATCHES" },
  { key = "pycho_close", name = "Ctrl+C/D -> PychoClose" },
  { key = "pycho_save", name = "Ctrl+S -> PychoSave" },
  { key = "ctrl_z_undo", name = "Ctrl+Z -> undo" },
  { key = "familiar_shortcuts", name = "Ctrl+F/P/A familiar keys" },
  { key = "safe_visual_paste", name = "Visual paste keeps yank" },
  { key = "confirm", name = "Prompt on dirty exit" },
  { key = "terminal_escape", name = "Terminal Esc exits insert" },

  { section = "UPDATES" },
  { key = "auto_update_config", name = "Config update on launch" },
  { key = "auto_update_plugins", name = "Plugin update on launch" },
  { key = "auto_update_parsers", name = "Parser update on launch" },
  { key = "plugin_update_check", name = "Lazy checker every launch" },
}

local selectable = {}
for row_index, item in ipairs(rows) do
  if item.key then selectable[#selectable + 1] = row_index end
end

local function display_value(item)
  local value = config[item.key]
  if item.display then return tostring(item.display(value)) end
  if type(value) == "boolean" then return onoff(value) end
  return tostring(value)
end

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end

  local lines = {
    "  PIERCE & PIERCE / SYSTEMS",
    "  workstation policy // changes are filed immediately",
    "",
  }

  for _, item in ipairs(rows) do
    if item.section then
      lines[#lines + 1] = "  " .. item.section
    else
      local suffix = restart_keys[item.key] and "  *" or ""
      lines[#lines + 1] = string.format("    %-33s %-13s%s", item.name, display_value(item), suffix)
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "  enter/space change   r reset   q leave"
  lines[#lines + 1] = "  * restart required   settings survive pycho update"

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

local function change_current()
  local item = rows[selectable[state.row]]
  if not item then return end

  if item.next then
    config[item.key] = item.next(config[item.key])
  elseif type(config[item.key]) == "boolean" then
    config[item.key] = not config[item.key]
  end

  apply_runtime()
  if item.key == "mask" then
    local ok, theme = pcall(require, "psychovim.theme")
    if ok then theme.apply(config.mask) end
  end
  save()
  render()

  if restart_keys[item.key] then
    vim.notify("Pycho · filed. takes effect after restart")
  end
end

local function reset_all()
  config = vim.deepcopy(defaults)
  apply_runtime()
  local ok, theme = pcall(require, "psychovim.theme")
  if ok then theme.apply(config.mask) end
  save()
  render()
  vim.notify("Pycho · defaults restored")
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf = nil, nil
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  state.row = 1
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false

  local width = math.max(40, math.min(82, vim.o.columns - 4))
  local content_height = #rows + 7
  local height = math.max(10, math.min(content_height, vim.o.lines - 4))

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = config.popup_border,
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
  vim.keymap.set("n", "<CR>", change_current, opts)
  vim.keymap.set("n", "<Space>", change_current, opts)
  vim.keymap.set("n", "r", reset_all, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  render()
end

function M.setup()
  read()
  apply_runtime()
  if vim.fn.exists(":PychoSettings") == 0 then
    vim.api.nvim_create_user_command("PychoSettings", M.open, { desc = "Open Pycho settings" })
  end
end

return M
