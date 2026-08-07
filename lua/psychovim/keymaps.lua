local map = vim.keymap.set
local smart = require("psychovim.smart_actions")

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- SmartClose is PSYCHOVIM's signature escape hatch.
-- Ctrl+C / Ctrl+D are intentionally easy to remember, but ask before leaving.
local function smart_close()
  local mode = vim.api.nvim_get_mode().mode

  if mode:sub(1, 1) == "i" then
    vim.cmd("stopinsert")
  elseif mode:sub(1, 1) == "t" then
    local escape = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(escape, "n", false)
  end

  require("psychovim.smart_close").open()
end

for _, mode in ipairs({ "n", "i", "x", "t" }) do
  map(mode, "<C-c>", smart_close, { desc = "SmartClose" })
  map(mode, "<C-d>", smart_close, { desc = "SmartClose" })
end

-- Ctrl+S should save, not appear broken or freeze a terminal via flow control.
map("n", "<C-s>", smart.save, { desc = "SmartSave" })
map("x", "<C-s>", function()
  vim.cmd("normal! <Esc>")
  smart.save()
end, { desc = "SmartSave" })
map("i", "<C-s>", function()
  vim.cmd("stopinsert")
  smart.save()
  vim.schedule(function()
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
      vim.cmd("startinsert")
    end
  end)
end, { desc = "SmartSave" })
map("t", "<C-s>", smart.terminal_ctrl_s, { desc = "Prevent terminal flow-control freeze" })

-- Newcomers expect Ctrl+Z to undo. Native Neovim suspends the whole editor instead.
map("n", "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })
map("x", "<C-z>", "<Esc><cmd>undo<cr>", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-S-z>", "<C-r>", { desc = "Redo" })
map("i", "<C-S-z>", "<C-o><C-r>", { desc = "Redo" })

-- Familiar editor shortcuts without stealing insert-mode completion keys.
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in current file" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })

map("n", "<leader>w", smart.save, { desc = "SmartSave" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", smart_close, { desc = "SmartClose" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })

map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", smart.close_buffer, { desc = "SmartBufferClose" })

-- Visual paste keeps the yank register intact, so one copy can replace many selections.
map("v", "p", '"_dP', { desc = "Paste without replacing register" })
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("n", "<A-j>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<cr>gv=gv", { desc = "Move selection up" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })
