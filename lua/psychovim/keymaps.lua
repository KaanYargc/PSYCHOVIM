local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- SmartClose is PSYCHOVIM's signature escape hatch.
-- Ctrl+C / Ctrl+D are intentionally easy to remember, but now ask before leaving.
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

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all without saving" })
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
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "p", '"_dP', { desc = "Paste without replacing register" })
map("n", "<A-j>", "<cmd>move .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<cr>gv=gv", { desc = "Move selection up" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Terminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })
