local map = vim.keymap.set
local actions = require("psychovim.smart_actions")

local function feed_native(keys)
  local term = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(term, "n", false)
end

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "kj", "<Esc>", { desc = "Exit insert mode" })

local function pycho_close_or_native(key)
  if vim.g.pycho_close == false then
    feed_native(key)
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 1) == "i" then
    vim.cmd("stopinsert")
  elseif mode:sub(1, 1) == "t" then
    feed_native("<C-\\><C-n>")
  end
  require("psychovim.smart_close").open()
end

for _, mode in ipairs({ "n", "i", "x", "t" }) do
  map(mode, "<C-c>", function() pycho_close_or_native("<C-c>") end, { desc = "PychoClose" })
  map(mode, "<C-d>", function() pycho_close_or_native("<C-d>") end, { desc = "PychoClose" })
end

local function pycho_save_or_native()
  if vim.g.pycho_save == false then feed_native("<C-s>"); return end
  actions.save()
end
map("n", "<C-s>", pycho_save_or_native, { desc = "PychoSave" })
map("x", "<C-s>", function()
  if vim.g.pycho_save == false then feed_native("<C-s>") else feed_native("<Esc>"); vim.schedule(actions.save) end
end, { desc = "PychoSave" })
map("i", "<C-s>", function()
  if vim.g.pycho_save == false then feed_native("<C-s>") else vim.cmd("stopinsert"); actions.save(); vim.cmd("startinsert") end
end, { desc = "PychoSave" })
map("t", "<C-s>", function()
  if vim.g.pycho_save == false then feed_native("<C-s>") else actions.terminal_ctrl_s() end
end, { desc = "PychoSave terminal guard" })

local function ctrl_z(mode)
  if vim.g.pycho_ctrl_z_undo == false then feed_native("<C-z>"); return end
  if mode == "i" then vim.cmd("undo"); vim.cmd("startinsert") else vim.cmd("undo") end
end
map("n", "<C-z>", function() ctrl_z("n") end, { desc = "PychoUndo" })
map("x", "<C-z>", function() feed_native("<Esc>"); vim.schedule(function() ctrl_z("n") end) end, { desc = "PychoUndo" })
map("i", "<C-z>", function() vim.cmd("stopinsert"); ctrl_z("i") end, { desc = "PychoUndo" })
map("n", "<C-S-z>", "<C-r>", { desc = "Redo" })
map("i", "<C-S-z>", "<C-o><C-r>", { desc = "Redo" })

map("n", "<C-p>", function()
  if vim.g.pycho_familiar_shortcuts == false then feed_native("<C-p>") else vim.cmd("Telescope find_files") end
end, { desc = "PychoFind files" })
map("n", "<C-f>", function()
  if vim.g.pycho_familiar_shortcuts == false then feed_native("<C-f>") else vim.cmd("Telescope current_buffer_fuzzy_find") end
end, { desc = "PychoFind in file" })
map("n", "<C-a>", function()
  if vim.g.pycho_familiar_shortcuts == false then feed_native("<C-a>") else vim.cmd("normal! ggVG") end
end, { desc = "PychoSelect all" })

map("n", "<leader>w", actions.save, { desc = "PychoSave" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>Q", function() require("psychovim.smart_close").open() end, { desc = "PychoClose" })
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
map("n", "<leader>bd", actions.close_buffer, { desc = "PychoBufferClose" })

map("v", "p", function()
  if vim.g.pycho_safe_visual_paste == false then feed_native("p") else feed_native('"_dP') end
end, { desc = "PychoPaste" })
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
