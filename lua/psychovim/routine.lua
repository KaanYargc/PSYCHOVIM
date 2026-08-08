local M = {}

local state = { win = nil, buf = nil }

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

local function yesno(value)
  return value and "OK" or "FIX IT"
end

local function compiler_available()
  return vim.fn.executable("cc") == 1
    or vim.fn.executable("gcc") == 1
    or vim.fn.executable("clang") == 1
end

local function lazy_stats()
  local ok, lazy = pcall(require, "lazy")
  if not ok then return 0, 0 end
  local stats = lazy.stats()
  return stats.loaded or 0, stats.count or 0
end

local function row(label, value, width)
  local left = "  " .. label
  local dots = math.max(2, width - vim.fn.strdisplaywidth(left) - vim.fn.strdisplaywidth(value) - 2)
  return left .. " " .. string.rep("·", dots) .. " " .. value
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local settings = require("psychovim.settings")
  local loaded, total = lazy_stats()
  local width = math.min(68, math.max(52, vim.o.columns - 10))
  local engine_version = vim.version()
  local mask = vim.g.psychovim_mask == "after_hours" and "AFTER HOURS" or "ON"

  local lines = {
    "",
    "  MORNING ROUTINE",
    "  08:30 // system check",
    "",
    row("PychoVIM core", string.format("%d.%d.%d", engine_version.major, engine_version.minor, engine_version.patch), width - 4),
    row("Git", yesno(vim.fn.executable("git") == 1), width - 4),
    row("curl", yesno(vim.fn.executable("curl") == 1), width - 4),
    row("tar / gzip / unzip", yesno(vim.fn.executable("tar") == 1 and vim.fn.executable("gzip") == 1 and vim.fn.executable("unzip") == 1), width - 4),
    row("Ripgrep", yesno(vim.fn.executable("rg") == 1), width - 4),
    row("C compiler", yesno(compiler_available()), width - 4),
    row("Node / npm", yesno(vim.fn.executable("node") == 1 and vim.fn.executable("npm") == 1), width - 4),
    row("tree-sitter CLI", yesno(vim.fn.executable("tree-sitter") == 1), width - 4),
    row("Extensions", string.format("%d / %d", loaded, total), width - 4),
    row("pychoUpdater", settings.get("auto_update_config") and "ON" or "OFF", width - 4),
    row("Mask", mask, width - 4),
    "",
    "  Good. Get to work.",
    "",
  }

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  local height = #lines
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = settings.get("popup_border") or "rounded",
    title = " Morning Routine ",
    title_pos = "center",
    noautocmd = true,
  })

  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:PsychovimCardTitle"
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimCardTitle", 1, 2, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimMuted", 2, 2, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimMuted", #lines - 3, 2, -1)

  local opts = { buffer = state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
  vim.keymap.set("n", "<CR>", close, opts)
end

function M.setup()
  vim.api.nvim_create_user_command("MorningRoutine", M.open, { desc = "Inspect the PychoVIM environment" })
end

return M
