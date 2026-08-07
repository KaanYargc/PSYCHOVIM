local group = vim.api.nvim_create_augroup("Psychovim", { clear = true })
local settings = require("psychovim.settings")

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    if settings.get("highlight_yank") then
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 180 })
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(args)
    if not settings.get("trim_whitespace") or vim.bo[args.buf].buftype ~= "" then
      return
    end

    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    if not settings.get("restore_cursor") then return end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 1 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.wo.number = settings.get("terminal_numbers") == true
    vim.wo.relativenumber = false
    vim.wo.signcolumn = settings.get("terminal_signcolumn") == true and "yes" or "no"
    if settings.get("terminal_start_insert") then
      vim.schedule(function()
        if vim.bo.buftype == "terminal" then vim.cmd("startinsert") end
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

local messages = {
  "Market opens. Tabs close.",
  "No visible defects.",
  "Reservations remain unlikely.",
  "Typography is a competitive sport.",
}

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    if not settings.get("startup_quip") then return end
    math.randomseed(vim.uv.hrtime())
    vim.schedule(function()
      vim.notify("Pycho · " .. messages[math.random(#messages)], vim.log.levels.INFO)
    end)
  end,
})
