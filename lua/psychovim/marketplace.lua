local M = {}

local state = { win = nil, buf = nil, row = 1 }
local state_dir = vim.fn.stdpath("state") .. "/psychovim"
local manifest_file = state_dir .. "/marketplace.json"

local catalog = {
  {
    id = "oil",
    name = "Oil",
    repo = "stevearc/oil.nvim",
    desc = "Edit the filesystem like a normal buffer",
    spec = {
      lazy = false,
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {},
      keys = { { "-", "<cmd>Oil<cr>", desc = "Oil parent directory" } },
    },
  },
  {
    id = "toggleterm",
    name = "ToggleTerm",
    repo = "akinsho/toggleterm.nvim",
    desc = "Persistent floating and split terminals",
    spec = {
      version = "*",
      cmd = { "ToggleTerm", "TermExec" },
      opts = { direction = "float" },
      keys = { { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating terminal" } },
    },
  },
  {
    id = "trouble",
    name = "Trouble",
    repo = "folke/trouble.nvim",
    desc = "Diagnostics and references in a focused list",
    spec = {
      cmd = "Trouble",
      opts = {},
      keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble diagnostics" } },
    },
  },
  {
    id = "zen-mode",
    name = "Zen Mode",
    repo = "folke/zen-mode.nvim",
    desc = "Distraction-free writing and coding",
    spec = { cmd = "ZenMode", opts = {} },
  },
  {
    id = "neogit",
    name = "Neogit",
    repo = "NeogitOrg/neogit",
    desc = "Git interface inside Neovim",
    spec = {
      cmd = "Neogit",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
      keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" } },
    },
  },
  {
    id = "undotree",
    name = "Undotree",
    repo = "mbbill/undotree",
    desc = "Visualize and navigate Vim undo history",
    spec = {
      cmd = "UndotreeToggle",
      keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree" } },
    },
  },
}

local by_id = {}
for _, item in ipairs(catalog) do by_id[item.id] = item end

local function load_manifest()
  local data = { installed = {}, custom = {} }
  if vim.fn.filereadable(manifest_file) ~= 1 then return data end
  local ok_read, raw = pcall(vim.fn.readfile, manifest_file)
  if not ok_read then return data end
  local ok_json, decoded = pcall(vim.json.decode, table.concat(raw, "\n"))
  if ok_json and type(decoded) == "table" then
    data = vim.tbl_deep_extend("force", data, decoded)
  end
  return data
end

local function save_manifest(data)
  vim.fn.mkdir(state_dir, "p")
  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then return false end
  return pcall(vim.fn.writefile, { encoded }, manifest_file)
end

local function installed_map(data)
  local result = {}
  for _, id in ipairs(data.installed or {}) do result[id] = true end
  return result
end

local function repo_dir(repo)
  return vim.fn.stdpath("data") .. "/lazy/" .. repo:match("/([^/]+)$")
end

local function clone_repo(repo, done)
  local dir = repo_dir(repo)
  if vim.uv.fs_stat(dir) then
    if done then done(true) end
    return
  end

  vim.fn.mkdir(vim.fn.stdpath("data") .. "/lazy", "p")
  vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/" .. repo .. ".git", dir }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify((result.stderr or "Plugin download failed."), vim.log.levels.ERROR, { title = "Pycho Marketplace" })
      end
      if done then done(result.code == 0) end
    end)
  end)
end

function M.specs()
  local data = load_manifest()
  local specs = {}
  for _, id in ipairs(data.installed or {}) do
    local item = by_id[id]
    if item then
      local spec = vim.deepcopy(item.spec or {})
      spec[1] = item.repo
      specs[#specs + 1] = spec
    end
  end
  for _, repo in ipairs(data.custom or {}) do
    specs[#specs + 1] = { repo }
  end
  return specs
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf = nil, nil
end

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  local data = load_manifest()
  local installed = installed_map(data)
  local lines = {
    "  󰏗 PYCHO MARKETPLACE",
    "  curated plugins // enter installs or removes",
    "",
  }

  for _, item in ipairs(catalog) do
    local mark = installed[item.id] and "INSTALLED" or "GET"
    lines[#lines + 1] = string.format("    %-18s %-10s %s", item.name, mark, item.desc)
  end

  if #(data.custom or {}) > 0 then
    lines[#lines + 1] = ""
    lines[#lines + 1] = "  CUSTOM"
    for _, repo in ipairs(data.custom) do
      lines[#lines + 1] = "    " .. repo
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "  enter install/remove   a add GitHub repo   q leave"
  lines[#lines + 1] = "  changes load on next pycho; pychoUpdater handles cleanup"

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(state.buf, -1, 0, -1)

  for index, item in ipairs(catalog) do
    if installed[item.id] then
      vim.api.nvim_buf_add_highlight(state.buf, -1, "DiagnosticOk", 2 + index, 22, 31)
    end
  end

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_set_cursor(state.win, { 3 + state.row, 4 })
  end
end

local function move(delta)
  state.row = ((state.row - 1 + delta) % #catalog) + 1
  render()
end

local function toggle_current()
  local item = catalog[state.row]
  if not item then return end

  local data = load_manifest()
  local installed = installed_map(data)
  if installed[item.id] then
    local next_installed = {}
    for _, id in ipairs(data.installed or {}) do
      if id ~= item.id then next_installed[#next_installed + 1] = id end
    end
    data.installed = next_installed
    save_manifest(data)
    vim.notify(item.name .. " removed from the next launch.", vim.log.levels.INFO, { title = "Pycho Marketplace" })
    render()
    return
  end

  data.installed[#data.installed + 1] = item.id
  save_manifest(data)
  vim.notify("Downloading " .. item.name .. "...", vim.log.levels.INFO, { title = "Pycho Marketplace" })
  clone_repo(item.repo, function(ok)
    if not ok then
      local fresh = load_manifest()
      local keep = {}
      for _, id in ipairs(fresh.installed or {}) do
        if id ~= item.id then keep[#keep + 1] = id end
      end
      fresh.installed = keep
      save_manifest(fresh)
    else
      vim.notify(item.name .. " downloaded. Restart pycho to activate it.", vim.log.levels.INFO, { title = "Pycho Marketplace" })
    end
    render()
  end)
end

local function add_custom()
  vim.ui.input({ prompt = "GitHub plugin (owner/repo): " }, function(repo)
    repo = (repo or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if repo == "" then return end
    if not repo:match("^[%w_.-]+/[%w_.-]+$") then
      vim.notify("Use owner/repo format.", vim.log.levels.ERROR, { title = "Pycho Marketplace" })
      return
    end

    local data = load_manifest()
    for _, existing in ipairs(data.custom or {}) do
      if existing == repo then
        vim.notify(repo .. " is already in Marketplace.", vim.log.levels.INFO, { title = "Pycho Marketplace" })
        return
      end
    end
    data.custom[#data.custom + 1] = repo
    save_manifest(data)
    vim.notify("Downloading " .. repo .. "...", vim.log.levels.INFO, { title = "Pycho Marketplace" })
    clone_repo(repo, function(ok)
      if not ok then
        local fresh = load_manifest()
        local keep = {}
        for _, existing in ipairs(fresh.custom or {}) do
          if existing ~= repo then keep[#keep + 1] = existing end
        end
        fresh.custom = keep
        save_manifest(fresh)
      else
        vim.notify(repo .. " downloaded. Restart pycho to activate it.", vim.log.levels.INFO, { title = "Pycho Marketplace" })
      end
      render()
    end)
  end)
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

  local width = math.max(56, math.min(92, vim.o.columns - 4))
  local height = math.max(12, math.min(#catalog + 8, vim.o.lines - 4))
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = require("psychovim.settings").get("popup_border") or "rounded",
    title = " 󰏗 MARKETPLACE ",
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
  vim.keymap.set("n", "a", add_custom, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
  render()
end

function M.setup()
  if vim.fn.exists(":PychoMarketplace") == 0 then
    vim.api.nvim_create_user_command("PychoMarketplace", M.open, { desc = "Open Pycho Marketplace" })
  end
end

return M
