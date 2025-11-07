-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                         PychoVim                              ║
-- ║              "I have to return some videotapes"               ║
-- ║                                                               ║
-- ║  Inspired by Patrick Bateman's obsessive perfectionism        ║
-- ║  and psychopathic attention to detail                         ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- "Do you like Huey Lewis and the News?"
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("plugins")

-- ═══════════════════════════════════════════════════════════════
--  PSYCHOPATHIC VISUAL SETTINGS
--  "I'm into murders and executions mostly"
-- ═══════════════════════════════════════════════════════════════

vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Obsessive line numbering (Patrick would approve)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes:2"

-- Perfect indentation (like a business card)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Smooth scrolling (like a perfectly executed kill)
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.smoothscroll = true

-- Cursor settings (sharp as an axe)
vim.opt.cursorline = true
vim.opt.cursorcolumn = false

-- Split behavior (divide and conquer)
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Search settings (hunting for victims)
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Performance (efficient like a serial killer)
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.lazyredraw = false

-- Clipboard (collect trophies)
vim.opt.clipboard = "unnamedplus"

-- Mouse support (precision tools)
vim.opt.mouse = "a"

-- Undo persistence (never forget)
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.swapfile = false
vim.opt.backup = false

-- Completion menu (options, always options)
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10

-- Visual cues (blood on white sheets)
vim.opt.list = true
vim.opt.listchars = {
    tab = "→ ",
    trail = "·",
    extends = "»",
    precedes = "«",
    nbsp = "␣"
}

vim.opt.fillchars = {
    fold = "─",
    foldopen = "▼",
    foldclose = "▶",
    foldsep = "│",
    diff = "╱",
    eob = " ",
    vert = "│",
    horiz = "─"
}

-- ═══════════════════════════════════════════════════════════════
--  PSYCHOTIC KEYBINDINGS
--  "I think my mask of sanity is about to slip"
-- ═══════════════════════════════════════════════════════════════

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Quick escape (flee the scene)
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Ctrl+C and Ctrl+D to save and quit (emergency exit)
keymap("n", "<C-c>", ":wqa<CR>", { desc = "�E🚨 Save all & exit (Ctrl+C)" })
keymap("i", "<C-c>", "<ESC>:wqa<CR>", { desc = "�E🚨 Save all & exit (Ctrl+C)" })
keymap("v", "<C-c>", "<ESC>:wqa<CR>", { desc = "�E🚨 Save all & exit (Ctrl+C)" })
keymap("n", "<C-d>", ":wqa<CR>", { desc = "��🚨 Save all & exit (Ctrl+D)" })
keymap("i", "<C-d>", "<ESC>:wqa<CR>", { desc = "��🚨 Save all & exit (Ctrl+D)" })
keymap("v", "<C-d>", "<ESC>:wqa<CR>", { desc = "��🚨 Save all & exit (Ctrl+D)" })

-- Save & Quit (clean up the evidence)
keymap("n", "<leader>w", ":w<CR>", { desc = "💾 Save (hide the body)" })
keymap("n", "<leader>W", ":wa<CR>", { desc = "💾 Save all (mass cleanup)" })
keymap("n", "<leader>q", ":q<CR>", { desc = "🚪 Quit (leave no trace)" })
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "🚪 Quit all (burn everything)" })
keymap("n", "<leader>x", ":x<CR>", { desc = "💀 Save & Quit (perfect crime)" })

-- Buffer management (victim selection)
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "🔪 Delete buffer (eliminate)" })
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "➡️  Next victim" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "⬅️  Previous victim" })
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)

-- Window navigation (surveying the kill room)
keymap("n", "<C-h>", "<C-w>h", { desc = "⬅️  Window left" })
keymap("n", "<C-j>", "<C-w>j", { desc = "⬇️  Window down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "⬆️  Window up" })
keymap("n", "<C-l>", "<C-w>l", { desc = "➡️  Window right" })

-- Window splits (dissection)
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "✂️  Vertical split" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "✂️  Horizontal split" })
keymap("n", "<leader>sx", ":close<CR>", { desc = "❌ Close split" })

-- Resize windows (reshape the scene)
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move lines (rearrange the bodies)
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Indentation (OCD perfection)
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Clear search highlight (clean the crime scene)
keymap("n", "<leader>h", ":nohlsearch<CR>", { desc = "🧹 Clear highlights" })

-- Better paste (no evidence left behind)
keymap("v", "p", '"_dP', opts)

-- Select all (total control)
keymap("n", "<C-a>", "ggVG", { desc = "📋 Select all" })

-- Telescope (stalking tools)
keymap("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "🔍 Find files (hunt)" })
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "🔍 Live grep (search for clues)" })
keymap("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "🔍 Buffers (victim list)" })
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "🔍 Help (alibis)" })
keymap("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "🔍 Recent files (past crimes)" })

-- File tree (territory mapping)
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "🌲 Toggle file tree" })
keymap("n", "<leader>o", ":NvimTreeFocus<CR>", { desc = "🌲 Focus file tree" })

-- Terminal (command center)
keymap("n", "<leader>tt", ":terminal<CR>", { desc = "💻 Open terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", opts)

-- Diagnostic (forensics)
keymap("n", "<leader>dd", vim.diagnostic.open_float, { desc = "🩺 Show diagnostics" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "⬆️  Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "⬇️  Next diagnostic" })

-- ═══════════════════════════════════════════════════════════════
--  AUTOCOMMANDS (Obsessive Compulsions)
--  "I'm on the verge of tears by the time we arrive"
-- ═══════════════════════════════════════════════════════════════

local augroup = vim.api.nvim_create_augroup("PychoVim", { clear = true })

-- Highlight on yank (mark the target)
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Remove trailing whitespace (obsessive cleaning)
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Auto-close certain windows (dispose of evidence)
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "qf", "help", "man", "lspinfo" },
    callback = function()
        vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
    end,
})

-- Remember cursor position (never forget)
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})

-- Blood effect on cursor move (psychotic trail)
vim.api.nvim_set_hl(0, "BloodTrail", { bg = "#8b0000", fg = "#ffffff" })

local last_line = vim.fn.line(".")
vim.api.nvim_create_autocmd("CursorMoved", {
    group = augroup,
    callback = function()
        local current_line = vim.fn.line(".")
        if current_line ~= last_line then
            -- Flash blood effect on the line we just left
            vim.fn.matchaddpos("BloodTrail", { last_line }, 10, -1)
            vim.defer_fn(function()
                vim.fn.clearmatches()
            end, 150)
            last_line = current_line
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════
--  PSYCHOPATHIC MESSAGES
--  "I have all the characteristics of a human being"
-- ═══════════════════════════════════════════════════════════════

local messages = {
    "Let's see Paul Allen's config...",
    "I have to return some videotapes",
    "Is that a raincoat?",
    "Try getting a reservation at Dorsia now!",
    "I'm into murders and executions mostly",
    "Don't just stare at it, eat it",
    "Their early work was a little too new wave",
    "I think my mask of sanity is about to slip",
    "Do you like Huey Lewis and the News?",
    "Feed me a stray cat",
}

math.randomseed(os.time())
local random_message = messages[math.random(#messages)]

vim.defer_fn(function()
    vim.notify("PychoVim: " .. random_message, vim.log.levels.INFO)
end, 100)

