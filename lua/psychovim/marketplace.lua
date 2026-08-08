local M = {}

local state = {
  win = nil,
  buf = nil,
  row = 1,
  mode = "installed",
  query = "",
  loading = false,
  results = {},
  items = {},
}

local state_dir = vim.fn.stdpath("state") .. "/psychovim"
local manifest_file = state_dir .. "/marketplace.json"

local profiles = {
  ["stevearc/oil.nvim"] = {
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil parent directory" } },
  },
  ["akinsho/toggleterm.nvim"] = {
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    opts = { direction = "float" },
    keys = { { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating terminal" } },
  },
  ["folke/trouble.nvim"] = {
    cmd = "Trouble",
    opts = {},
    keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble diagnostics" } },
  },
  ["folke/zen-mode.nvim"] = { cmd = "ZenMode", opts = {} },
  ["NeogitOrg/neogit"] = {
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" } },
  },
  ["mbbill/undotree"] = {
    cmd = "UndotreeToggle",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undotree" } },
  },
}

local legacy_ids = {
  oil = "stevearc/oil.nvim",
  toggleterm = "akinsho/toggleterm.nvim",
  trouble = "folke/trouble.nvim",
  ["zen-mode"] = "folke/zen-mode.nvim",
  neogit = "NeogitOrg/neogit",
  undotree = "mbbill/undotree",
}

local theme_names = {
  ["catppuccin/nvim"] = "catppuccin",
  ["folke/tokyonight.nvim"] = "tokyonight",
  ["rose-pine/neovim"] = "rose-pine",
  ["rebelot/kanagawa.nvim"] = "kanagawa",
  ["EdenEast/nightfox.nvim"] = "nightfox",
  ["navarasu/onedark.nvim"] = "onedark",
  ["Mofiqul/dracula.nvim"] = "dracula",
  ["projekt0n/github-nvim-theme"] = "github_dark",
  ["sainnhe/everforest"] = "everforest",
  ["marko-cerovac/material.nvim"] = "material",
}

local core_settings = {
  ["nvim-telescope/telescope.nvim"] = "telescope",
  ["nvim-tree/nvim-tree.lua"] = "file_tree",
  ["lewis6991/gitsigns.nvim"] = "gitsigns",
  ["saghen/blink.cmp"] = "completion",
  ["nvim-treesitter/nvim-treesitter"] = "treesitter",
  ["mfussenegger/nvim-lint"] = "linting",
  ["stevearc/conform.nvim"] = "formatting",
  ["windwp/nvim-autopairs"] = "autopairs",
  ["kylechui/nvim-surround"] = "surround",
  ["folke/which-key.nvim"] = "which_key",
  ["lukas-reineke/indent-blankline.nvim"] = "indent_guides",
  ["folke/todo-comments.nvim"] = "todo_comments",
  ["nvim-lualine/lualine.nvim"] = "statusline",
  ["akinsho/bufferline.nvim"] = "bufferline",
}

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function copy(value)
  return vim.deepcopy(value)
end

local function save_manifest(data)
  vim.fn.mkdir(state_dir, "p")
  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then return false end
  return pcall(vim.fn.writefile, { encoded }, manifest_file)
end

local function normalize_entry(entry, kind)
  if type(entry) == "string" then
    local repo = legacy_ids[entry] or entry
    return {
      repo = repo,
      kind = kind or "plugin",
      enabled = true,
      startup = false,
      opts = {},
      colorscheme = theme_names[repo],
    }
  end
  if type(entry) ~= "table" or type(entry.repo) ~= "string" then return nil end
  entry = copy(entry)
  entry.kind = entry.kind == "theme" and "theme" or "plugin"
  entry.enabled = entry.enabled ~= false
  entry.startup = entry.startup == true
  entry.opts = type(entry.opts) == "table" and entry.opts or {}
  if entry.kind == "theme" and (not entry.colorscheme or entry.colorscheme == "") then
    entry.colorscheme = theme_names[entry.repo]
  end
  return entry
end

local function normalize_manifest(decoded)
  local result = { version = 2, installed = {}, active_theme = nil }
  if type(decoded) ~= "table" then return result, true end

  if decoded.version == 2 then
    for _, entry in ipairs(decoded.installed or {}) do
      local normalized = normalize_entry(entry)
      if normalized then result.installed[#result.installed + 1] = normalized end
    end
    result.active_theme = decoded.active_theme
    return result, false
  end

  for _, entry in ipairs(decoded.installed or {}) do
    local normalized = normalize_entry(entry, "plugin")
    if normalized then result.installed[#result.installed + 1] = normalized end
  end
  for _, repo in ipairs(decoded.custom or {}) do
    local normalized = normalize_entry(repo, "plugin")
    if normalized then result.installed[#result.installed + 1] = normalized end
  end
  return result, true
end

local function load_manifest()
  if vim.fn.filereadable(manifest_file) ~= 1 then
    return { version = 2, installed = {}, active_theme = nil }
  end
  local ok_read, raw = pcall(vim.fn.readfile, manifest_file)
  if not ok_read then return { version = 2, installed = {}, active_theme = nil } end
  local ok_json, decoded = pcall(vim.json.decode, table.concat(raw, "\n"))
  if not ok_json then return { version = 2, installed = {}, active_theme = nil } end
  local data, migrated = normalize_manifest(decoded)
  if migrated then save_manifest(data) end
  return data
end

local function entry_map(data)
  local result = {}
  for _, entry in ipairs(data.installed or {}) do result[entry.repo:lower()] = entry end
  return result
end

local function repo_from_url(url)
  if type(url) ~= "string" then return nil end
  return url:match("github%.com[:/]([^/]+/[^/]+)%.git$")
    or url:match("github%.com[:/]([^/]+/[^/]+)$")
end

local function repo_dir(repo)
  return vim.fn.stdpath("data") .. "/lazy/" .. repo:match("/([^/]+)$")
end

local function core_inventory()
  local result = {}
  local seen = {}
  local ok, lazy_config = pcall(require, "lazy.core.config")
  if not ok then return result, seen end

  for name, plugin in pairs(lazy_config.plugins or {}) do
    local repo = repo_from_url(plugin.url) or repo_from_url(plugin._ and plugin._.url) or name
    seen[repo:lower()] = true
    result[#result + 1] = {
      name = name,
      repo = repo,
      kind = "plugin",
      origin = "CORE",
      installed = true,
      enabled = true,
      setting_key = core_settings[repo],
      desc = plugin.url or "PychoVIM core extension",
    }
  end

  table.sort(result, function(a, b) return a.name:lower() < b.name:lower() end)
  return result, seen
end

local function installed_inventory()
  local data = load_manifest()
  local result = {}
  local market = entry_map(data)
  local core, core_seen = core_inventory()

  for _, entry in ipairs(data.installed or {}) do
    result[#result + 1] = {
      name = entry.repo:match("/([^/]+)$") or entry.repo,
      repo = entry.repo,
      kind = entry.kind,
      origin = "MARKET",
      installed = true,
      enabled = entry.enabled,
      active = data.active_theme == entry.repo,
      desc = entry.kind == "theme" and (entry.colorscheme or "theme") or "Marketplace extension",
    }
  end
  for _, item in ipairs(core) do
    if not market[item.repo:lower()] then result[#result + 1] = item end
  end

  table.sort(result, function(a, b)
    if a.origin ~= b.origin then return a.origin == "MARKET" end
    return a.repo:lower() < b.repo:lower()
  end)
  return result, core_seen
end

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function github_search(query, kind, done)
  if vim.fn.executable("curl") ~= 1 then
    done(nil, "curl is required for GitHub search")
    return
  end

  local qualifier = kind == "theme" and "topic:neovim-colorscheme" or "topic:neovim-plugin"
  local q = trim(query)
  if q ~= "" then q = q .. " in:name,description " .. qualifier else q = qualifier end
  local url = "https://api.github.com/search/repositories?q=" .. url_encode(q) .. "&sort=stars&order=desc&per_page=30"
  local argv = {
    "curl", "-fsSL", "--connect-timeout", "8", "--max-time", "20",
    "-H", "Accept: application/vnd.github+json",
    "-H", "X-GitHub-Api-Version: 2022-11-28",
  }
  local token = vim.env.GITHUB_TOKEN or vim.env.GH_TOKEN
  if token and token ~= "" then
    vim.list_extend(argv, { "-H", "Authorization: Bearer " .. token })
  end
  argv[#argv + 1] = url

  vim.system(argv, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        done(nil, trim(result.stderr) ~= "" and trim(result.stderr) or "GitHub search failed")
        return
      end
      local ok, decoded = pcall(vim.json.decode, result.stdout or "")
      if not ok or type(decoded) ~= "table" then
        done(nil, "GitHub returned unreadable search data")
        return
      end
      local rows = {}
      for _, repo in ipairs(decoded.items or {}) do
        if not repo.archived and type(repo.full_name) == "string" then
          rows[#rows + 1] = {
            name = repo.name or repo.full_name,
            repo = repo.full_name,
            kind = kind,
            stars = repo.stargazers_count or 0,
            desc = repo.description or "",
            installed = false,
            origin = "GITHUB",
          }
        end
      end
      done(rows, nil)
    end)
  end)
end

local function merge_opts(base, extra)
  if type(extra) ~= "table" or next(extra) == nil then return base end
  base.opts = vim.tbl_deep_extend("force", base.opts or {}, extra)
  return base
end

function M.specs()
  local data = load_manifest()
  local specs = {}
  for _, entry in ipairs(data.installed or {}) do
    if entry.enabled ~= false then
      local spec = copy(profiles[entry.repo] or {})
      spec[1] = entry.repo
      if entry.kind == "theme" then
        spec.lazy = false
        spec.priority = math.max(spec.priority or 0, 950)
      elseif spec.lazy == nil and spec.event == nil and spec.cmd == nil and spec.keys == nil then
        if entry.startup then spec.lazy = false else spec.event = "VeryLazy" end
      end
      merge_opts(spec, entry.opts)
      specs[#specs + 1] = spec
    end
  end
  return specs
end

function M.apply_active_theme()
  local data = load_manifest()
  if not data.active_theme then return false end
  local entry = entry_map(data)[data.active_theme:lower()]
  if not entry or entry.enabled == false or entry.kind ~= "theme" then return false end
  local name = entry.colorscheme or theme_names[entry.repo]
  if not name or name == "" then return false end
  return pcall(vim.cmd.colorscheme, name)
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf = nil, nil
end

local function trunc(text, width)
  text = (text or ""):gsub("[%r%n]", " ")
  if vim.fn.strdisplaywidth(text) <= width then return text end
  return vim.fn.strcharpart(text, 0, math.max(1, width - 1)) .. "…"
end

local function refresh_items()
  if state.mode == "installed" then
    state.items = installed_inventory()
  else
    local data = load_manifest()
    local market = entry_map(data)
    local _, core = core_inventory()
    state.items = copy(state.results)
    for _, item in ipairs(state.items) do
      local entry = market[item.repo:lower()]
      item.installed = entry ~= nil or core[item.repo:lower()] == true
      item.origin = entry and "MARKET" or (core[item.repo:lower()] and "CORE" or "GITHUB")
      item.enabled = entry and entry.enabled or true
      item.active = entry and data.active_theme == entry.repo or false
    end
  end
  if state.row > #state.items then state.row = math.max(1, #state.items) end
end

local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  refresh_items()

  local mode = state.mode == "installed" and "INSTALLED" or (state.mode == "themes" and "THEMES" or "SEARCH")
  local lines = {
    "  󰏗 PYCHOVIM EXTENSIONS",
    string.format("  %-11s  i inventory   / plugins   t themes   s settings", mode),
    "",
  }

  if state.loading then
    lines[#lines + 1] = "    Searching GitHub..."
  elseif #state.items == 0 then
    lines[#lines + 1] = state.mode == "installed" and "    No extensions found." or "    No GitHub results."
  else
    for _, item in ipairs(state.items) do
      local icon = item.kind == "theme" and "󰏘" or "󰏗"
      local status
      if item.active then
        status = "ACTIVE"
      elseif item.origin == "CORE" then
        status = "CORE"
      elseif item.installed then
        status = item.enabled == false and "OFF" or "ON"
      else
        status = "GET"
      end
      local stars = item.stars and item.stars > 0 and ("★" .. tostring(item.stars)) or ""
      lines[#lines + 1] = string.format(
        "    %s %-28s %-7s %-8s %s",
        icon,
        trunc(item.repo, 28),
        status,
        stars,
        trunc(item.desc, 36)
      )
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "  enter install/remove   c configure   r refresh   u update"
  lines[#lines + 1] = "  GitHub search is live. Marketplace state survives PychoVIM updates."

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(state.buf, -1, 0, -1)

  for index, item in ipairs(state.items) do
    local hl = item.active and "DiagnosticOk"
      or (item.origin == "CORE" and "Comment")
      or (item.installed and "DiagnosticInfo")
      or nil
    if hl then vim.api.nvim_buf_add_highlight(state.buf, -1, hl, 2 + index, 4, -1) end
  end

  if state.win and vim.api.nvim_win_is_valid(state.win) and #state.items > 0 then
    vim.api.nvim_win_set_cursor(state.win, { 3 + state.row, 4 })
  end
end

local function move(delta)
  if #state.items == 0 then return end
  state.row = ((state.row - 1 + delta) % #state.items) + 1
  render()
end

local function find_entry(repo)
  local data = load_manifest()
  for index, entry in ipairs(data.installed or {}) do
    if entry.repo:lower() == repo:lower() then return data, entry, index end
  end
  return data, nil, nil
end

local function clone_repo(repo, done)
  local dir = repo_dir(repo)
  if vim.uv.fs_stat(dir) then done(true); return end
  vim.fn.mkdir(vim.fn.stdpath("data") .. "/lazy", "p")
  vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/" .. repo .. ".git", dir }, { text = true }, function(result)
    vim.schedule(function() done(result.code == 0, trim(result.stderr)) end)
  end)
end

local function remove_market_entry(repo)
  local data, _, index = find_entry(repo)
  if not index then return end
  table.remove(data.installed, index)
  if data.active_theme == repo then data.active_theme = nil end
  save_manifest(data)
  local dir = repo_dir(repo)
  if vim.uv.fs_stat(dir) then pcall(vim.fn.delete, dir, "rf") end
  vim.notify(repo .. " removed. Restart PychoVIM to finish unloading it.", vim.log.levels.INFO, { title = "PychoVIM Extensions" })
  render()
end

local function set_active_theme(entry)
  local data = load_manifest()
  data.active_theme = entry.repo
  save_manifest(data)
  local ok = M.apply_active_theme()
  if ok then
    require("psychovim.theme").apply(vim.g.psychovim_mask or "sanity")
    vim.notify((entry.colorscheme or entry.repo) .. " applied.", vim.log.levels.INFO, { title = "PychoVIM Themes" })
  else
    vim.notify("Theme installed; colorscheme name needs configuration.", vim.log.levels.WARN, { title = "PychoVIM Themes" })
  end
  render()
end

local function configure_entry(item)
  if item.origin == "CORE" then
    vim.notify("Core extension policy lives in ⚙ PychoVIM Settings.", vim.log.levels.INFO, { title = "PychoVIM Extensions" })
    require("psychovim.settings").open()
    return
  end

  local data, entry = find_entry(item.repo)
  if not entry then return end
  local choices = { entry.enabled == false and "Enable" or "Disable", "Edit Lazy opts JSON", entry.startup and "Load on VeryLazy" or "Load at startup" }
  if entry.kind == "theme" then
    table.insert(choices, 1, "Activate theme")
    table.insert(choices, 2, "Set colorscheme name")
  end
  choices[#choices + 1] = "Remove extension"

  vim.ui.select(choices, { prompt = "Configure " .. entry.repo }, function(choice)
    if not choice then return end
    if choice == "Enable" or choice == "Disable" then
      entry.enabled = choice == "Enable"
      save_manifest(data)
      render()
    elseif choice == "Load at startup" or choice == "Load on VeryLazy" then
      entry.startup = choice == "Load at startup"
      save_manifest(data)
      render()
    elseif choice == "Edit Lazy opts JSON" then
      local encoded = vim.json.encode(entry.opts or {})
      vim.ui.input({ prompt = "Lazy opts JSON: ", default = encoded }, function(value)
        if not value then return end
        local ok, decoded = pcall(vim.json.decode, value)
        if not ok or type(decoded) ~= "table" then
          vim.notify("Options must be a JSON object.", vim.log.levels.ERROR, { title = "PychoVIM Extensions" })
          return
        end
        entry.opts = decoded
        save_manifest(data)
        vim.notify("Options filed. Restart PychoVIM to reload the extension.", vim.log.levels.INFO, { title = "PychoVIM Extensions" })
      end)
    elseif choice == "Set colorscheme name" then
      vim.ui.input({ prompt = "colorscheme: ", default = entry.colorscheme or "" }, function(value)
        value = trim(value)
        if value == "" then return end
        entry.colorscheme = value
        save_manifest(data)
        render()
      end)
    elseif choice == "Activate theme" then
      set_active_theme(entry)
    elseif choice == "Remove extension" then
      remove_market_entry(entry.repo)
    end
  end)
end

local function install_result(item)
  local _, core = core_inventory()
  if core[item.repo:lower()] then
    if item.kind == "theme" and theme_names[item.repo] then
      vim.cmd.colorscheme(theme_names[item.repo])
      require("psychovim.theme").apply(vim.g.psychovim_mask or "sanity")
    else
      vim.notify(item.repo .. " is already part of PychoVIM.", vim.log.levels.INFO, { title = "PychoVIM Extensions" })
    end
    return
  end

  local data, existing = find_entry(item.repo)
  if existing then
    remove_market_entry(item.repo)
    return
  end

  local function commit_entry(colorscheme)
    local fresh = load_manifest()
    fresh.installed[#fresh.installed + 1] = {
      repo = item.repo,
      kind = item.kind,
      enabled = true,
      startup = item.kind == "theme",
      opts = {},
      colorscheme = colorscheme,
    }
    if item.kind == "theme" then fresh.active_theme = item.repo end
    save_manifest(fresh)

    vim.notify("Downloading " .. item.repo .. "...", vim.log.levels.INFO, { title = "PychoVIM Extensions" })
    clone_repo(item.repo, function(ok, err)
      if not ok then
        remove_market_entry(item.repo)
        vim.notify(err ~= "" and err or "Download failed.", vim.log.levels.ERROR, { title = "PychoVIM Extensions" })
        return
      end
      vim.notify("Installed. Restart PychoVIM to load " .. item.repo .. ".", vim.log.levels.INFO, { title = "PychoVIM Extensions" })
      render()
    end)
  end

  if item.kind == "theme" then
    local guessed = theme_names[item.repo]
    if guessed then commit_entry(guessed); return end
    vim.ui.input({ prompt = "colorscheme command for " .. item.repo .. ": ", default = item.name or "" }, function(value)
      value = trim(value)
      if value ~= "" then commit_entry(value) end
    end)
  else
    commit_entry(nil)
  end
end

local function activate_current()
  local item = state.items[state.row]
  if not item then return end
  if state.mode == "installed" then
    if item.origin == "MARKET" then configure_entry(item) else configure_entry(item) end
  elseif item.installed then
    configure_entry(item)
  else
    install_result(item)
  end
end

local function search(kind, reuse)
  local function run(query)
    state.mode = kind == "theme" and "themes" or "search"
    state.query = query or ""
    state.loading = true
    state.results = {}
    state.row = 1
    render()
    github_search(state.query, kind, function(rows, err)
      state.loading = false
      if not rows then
        vim.notify(err or "GitHub search failed.", vim.log.levels.ERROR, { title = "PychoVIM Extensions" })
        state.results = {}
      else
        state.results = rows
      end
      render()
    end)
  end

  if reuse and state.mode ~= "installed" then run(state.query); return end
  vim.ui.input({ prompt = kind == "theme" and "Search themes: " or "Search extensions: " }, function(query)
    if query == nil then return end
    run(trim(query))
  end)
end

function M.open(opts)
  opts = opts or {}
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    if opts.installed then state.mode = "installed"; state.row = 1; render() end
    return
  end

  state.mode = opts.installed and "installed" or state.mode
  state.row = 1
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].swapfile = false

  local width = math.max(68, math.min(118, vim.o.columns - 4))
  local height = math.max(14, math.min(36, vim.o.lines - 4))
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = require("psychovim.settings").get("popup_border") or "rounded",
    title = " 󰏗 PYCHOVIM EXTENSIONS ",
    title_pos = "center",
    noautocmd = true,
  })
  vim.wo[state.win].cursorline = true
  vim.wo[state.win].winhl = "Normal:NormalFloat,FloatBorder:PsychovimCardTitle,CursorLine:Visual"

  local map_opts = { buffer = state.buf, silent = true, nowait = true }
  vim.keymap.set("n", "j", function() move(1) end, map_opts)
  vim.keymap.set("n", "k", function() move(-1) end, map_opts)
  vim.keymap.set("n", "<Down>", function() move(1) end, map_opts)
  vim.keymap.set("n", "<Up>", function() move(-1) end, map_opts)
  vim.keymap.set("n", "<CR>", activate_current, map_opts)
  vim.keymap.set("n", "<Space>", activate_current, map_opts)
  vim.keymap.set("n", "c", function()
    local item = state.items[state.row]
    if item then configure_entry(item) end
  end, map_opts)
  vim.keymap.set("n", "i", function() state.mode = "installed"; state.row = 1; render() end, map_opts)
  vim.keymap.set("n", "/", function() search("plugin", false) end, map_opts)
  vim.keymap.set("n", "t", function() search("theme", false) end, map_opts)
  vim.keymap.set("n", "r", function()
    if state.mode == "installed" then render() else search(state.mode == "themes" and "theme" or "plugin", true) end
  end, map_opts)
  vim.keymap.set("n", "s", function() require("psychovim.settings").open() end, map_opts)
  vim.keymap.set("n", "u", function() require("psychovim.updater").run() end, map_opts)
  vim.keymap.set("n", "q", close, map_opts)
  vim.keymap.set("n", "<Esc>", close, map_opts)
  render()
end

function M.setup()
  if vim.fn.exists(":PychoMarketplace") == 0 then
    vim.api.nvim_create_user_command("PychoMarketplace", M.open, { desc = "Open PychoVIM Extensions" })
  end
  if vim.fn.exists(":PychoExtensions") == 0 then
    vim.api.nvim_create_user_command("PychoExtensions", M.open, { desc = "Open PychoVIM Extensions" })
  end
  if vim.fn.exists(":PychoInventory") == 0 then
    vim.api.nvim_create_user_command("PychoInventory", function() M.open({ installed = true }) end, { desc = "Open installed PychoVIM extensions" })
  end
end

return M
