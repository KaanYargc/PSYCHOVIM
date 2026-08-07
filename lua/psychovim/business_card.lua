local M = {}

local state = { win = nil, buf = nil }

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

local function git_branch()
  if vim.fn.executable("git") ~= 1 then return "NO ACCOUNT" end
  local cwd = vim.fn.getcwd()
  local output = vim.fn.systemlist({ "git", "-C", cwd, "branch", "--show-current" })
  if vim.v.shell_error ~= 0 or not output[1] or output[1] == "" then
    return "PRIVATE ACCOUNT"
  end
  return output[1]
end

local function plugin_count()
  local ok, lazy = pcall(require, "lazy")
  if not ok then return 0 end
  local stats = lazy.stats()
  return stats.loaded or 0
end

local function lsp_count()
  return #vim.lsp.get_clients({ bufnr = 0 })
end

local function pad(text, width)
  text = tostring(text)
  local missing = math.max(0, width - vim.fn.strdisplaywidth(text))
  return text .. string.rep(" ", missing)
end

function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  local width = math.min(68, math.max(54, vim.o.columns - 8))
  local inner = width - 4
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
  if vim.fn.strdisplaywidth(cwd) > inner - 9 then
    cwd = vim.fn.pathshorten(cwd)
  end

  local lines = {
    "",
    "  " .. pad("PIERCE & PIERCE", inner),
    "  " .. pad("MERGERS AND ACQUISITIONS", inner),
    "",
    "  " .. pad("PSYCHOVIM", inner),
    "  " .. pad("VICE PRESIDENT", inner),
    "",
    "  " .. pad("ACCOUNT      " .. git_branch(), inner),
    "  " .. pad("OFFICE       " .. cwd, inner),
    "  " .. pad(string.format("PERSONNEL    %d PLUGINS · %d LSP", plugin_count(), lsp_count()), inner),
    "",
    "  " .. pad("Impressive. Very nice.", inner),
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
    border = "single",
    title = " PIERCE & PIERCE ",
    title_pos = "center",
    noautocmd = true,
  })

  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:PsychovimCardTitle"
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimCardTitle", 1, 2, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimMuted", 2, 2, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimCardAccent", 4, 2, -1)
  vim.api.nvim_buf_add_highlight(state.buf, -1, "PsychovimMuted", 11, 2, -1)

  local opts = { buffer = state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
  vim.keymap.set("n", "<CR>", close, opts)
end

function M.setup()
  vim.api.nvim_create_user_command("BusinessCard", M.open, { desc = "Show the PSYCHOVIM Pierce & Pierce card" })
end

return M
