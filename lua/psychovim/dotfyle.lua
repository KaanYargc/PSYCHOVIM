local M = {
  base_url = "https://dotfyle.com",
  source_url = "https://dotfyle.com/neovim/configurations/plugins",
}

local trpc_url = M.base_url .. "/trpc"

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function url_encode(value)
  return (value:gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function error_message(node)
  if type(node) ~= "table" then return nil end
  if type(node.message) == "string" then return node.message end
  if type(node.json) == "table" and type(node.json.message) == "string" then
    return node.json.message
  end
  return nil
end

local function unwrap(decoded)
  if type(decoded) ~= "table" then
    return nil, "Dotfyle returned unreadable data"
  end

  if vim.islist(decoded) then
    decoded = decoded[1]
  end
  if type(decoded) ~= "table" then
    return nil, "Dotfyle returned an empty response"
  end

  if decoded.error then
    return nil, error_message(decoded.error) or "Dotfyle request failed"
  end

  local result = decoded.result
  local data = type(result) == "table" and result.data or nil
  if type(data) == "table" and data.json ~= nil then data = data.json end
  if data == nil then return nil, "Dotfyle response had no result" end
  return data, nil
end

local function input_envelope(input)
  return { json = input == nil and vim.NIL or input }
end

local function direct_url(procedure, input)
  local url = trpc_url .. "/" .. procedure
  if input ~= nil then
    url = url .. "?input=" .. url_encode(vim.json.encode(input_envelope(input)))
  end
  return url
end

local function batch_url(procedure, input)
  local payload = { ["0"] = input_envelope(input) }
  return trpc_url .. "/" .. procedure
    .. "?batch=1&input=" .. url_encode(vim.json.encode(payload))
end

local function curl(url, done)
  if vim.fn.executable("curl") ~= 1 then
    done(nil, "curl is required for Dotfyle marketplace search")
    return
  end

  vim.system({
    "curl", "-fsSL", "--retry", "2", "--retry-delay", "1",
    "--connect-timeout", "8", "--max-time", "25",
    "-H", "Accept: application/json",
    "-H", "User-Agent: PychoVIM/marketplace",
    url,
  }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        done(nil, trim(result.stderr) ~= "" and trim(result.stderr) or "Dotfyle request failed")
        return
      end

      local ok, decoded = pcall(vim.json.decode, result.stdout or "")
      if not ok then
        done(nil, "Dotfyle returned invalid JSON")
        return
      end

      local payload, err = unwrap(decoded)
      done(payload, err)
    end)
  end)
end

function M.query(procedure, input, done)
  curl(direct_url(procedure, input), function(payload, err)
    if payload ~= nil then
      done(payload, nil)
      return
    end

    -- Dotfyle currently uses tRPC v10. Keep the batch form as a compatibility
    -- fallback because the website itself normally talks through httpBatchLink.
    curl(batch_url(procedure, input), function(batch_payload, batch_err)
      done(batch_payload, batch_err or err)
    end)
  end)
end

function M.search(opts, done)
  opts = opts or {}
  local categories = {}
  if opts.kind == "theme" then
    categories = { "colorscheme" }
  elseif opts.category and opts.category ~= "" then
    categories = { opts.category }
  end

  M.query("searchPlugins", {
    query = trim(opts.query) ~= "" and trim(opts.query) or nil,
    categories = categories,
    sorting = opts.sorting or "trending",
    page = opts.page or 1,
    take = 10,
  }, function(payload, err)
    if type(payload) ~= "table" or type(payload.data) ~= "table" then
      done(nil, err or "Dotfyle search payload was incomplete")
      return
    end

    local rows = {}
    for _, plugin in ipairs(payload.data) do
      if type(plugin.owner) == "string" and type(plugin.name) == "string" then
        local repo = plugin.owner .. "/" .. plugin.name
        rows[#rows + 1] = {
          name = plugin.name,
          repo = repo,
          kind = (opts.kind == "theme" or plugin.category == "colorscheme") and "theme" or "plugin",
          category = plugin.category or "",
          stars = tonumber(plugin.stars) or 0,
          installs = tonumber(plugin.configCount) or 0,
          trend = tonumber(plugin.addedLastWeek) or 0,
          desc = plugin.shortDescription or plugin.description or "",
          installed = false,
          origin = "DOTFYLE",
          clone_url = plugin.link,
          dotfyle_id = plugin.id,
        }
      end
    end

    local meta = type(payload.meta) == "table" and payload.meta or {}
    done(rows, nil, {
      total = tonumber(meta.total) or #rows,
      current = tonumber(meta.currentPage) or opts.page or 1,
      last = math.max(1, tonumber(meta.lastPage) or 1),
      prev = meta.prev,
      next = meta.next,
    })
  end)
end

function M.categories(done)
  M.query("listPluginCategories", nil, function(payload, err)
    if type(payload) ~= "table" then
      done(nil, err or "Dotfyle category list was incomplete")
      return
    end
    table.sort(payload)
    done(payload, nil)
  end)
end

-- Small hooks for CI. They keep the network contract testable without making
-- the smoke job depend on Dotfyle availability.
M._unwrap = unwrap
M._direct_url = direct_url
M._batch_url = batch_url

return M
