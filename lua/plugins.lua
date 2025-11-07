-- ╔═══════════════════════════════════════════════════════════════╗
-- ║                    PychoVim Plugins                           ║
-- ║         "Look at that subtle off-white coloring..."           ║
-- ╚═══════════════════════════════════════════════════════════════╝

return require("packer").startup(function(use)
    -- Plugin manager (the foundation of control)
    use "wbthomason/packer.nvim"

    -- ═══════════════════════════════════════════════════════════
    --  COLOR SCHEMES (Blood & Darkness)
    -- ═══════════════════════════════════════════════════════════

    -- Primary theme: Dark, sophisticated, psychotic
    use {
        "catppuccin/nvim",
        as = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- Dark as Patrick's soul
                transparent_background = false,
                term_colors = true,
                styles = {
                    comments = { "italic" },
                    conditionals = { "bold" },
                    loops = { "bold" },
                    functions = { "bold" },
                    keywords = { "italic" },
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = { "bold" },
                    properties = {},
                    types = { "bold" },
                },
                color_overrides = {
                    mocha = {
                        base = "#0d0d0d",      -- Pitch black
                        mantle = "#000000",    -- Void
                        crust = "#000000",     -- Abyss
                        text = "#e0e0e0",      -- Cold white
                        red = "#8b0000",       -- Blood red
                        maroon = "#800000",    -- Dark blood
                    },
                },
                custom_highlights = function(colors)
                    return {
                        CursorLine = { bg = "#1a1a1a" },
                        LineNr = { fg = "#4a4a4a" },
                        CursorLineNr = { fg = "#8b0000", style = { "bold" } },
                    }
                end,
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    }

    -- Alternative themes (for different moods)
    use "folke/tokyonight.nvim"
    use "EdenEast/nightfox.nvim"
    use { "rose-pine/neovim", as = "rose-pine" }

    -- ═══════════════════════════════════════════════════════════
    --  UI ENHANCEMENTS (Aesthetic Perfection)
    -- ═══════════════════════════════════════════════════════════

    -- Status line (business card quality)
    use {
        "nvim-lualine/lualine.nvim",
        requires = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return "🔪 " .. str
                            end,
                        },
                    },
                    lualine_b = { "branch", "diff" },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = {
                                modified = " 💀",
                                readonly = " 🔒",
                                unnamed = " 👤",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = "💥 ", warn = "⚠️  ", info = "ℹ️  ", hint = "💡 " },
                        },
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    }

    -- Buffer line (victim tabs)
    use {
        "akinsho/bufferline.nvim",
        requires = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    separator_style = "slant",
                    always_show_bufferline = true,
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    color_icons = true,
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(count, level)
                        local icon = level:match("error") and "💥" or "⚠️"
                        return " " .. icon .. count
                    end,
                },
            })
        end,
    }

    -- Indent guides (OCD lines)
    use {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup({
                indent = {
                    char = "│",
                    tab_char = "│",
                },
                scope = {
                    enabled = true,
                    show_start = true,
                    show_end = true,
                },
            })
        end,
    }

    -- Dashboard (welcome to hell)
    use {
        "goolord/alpha-nvim",
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Psychotic color animation (blood colors)
            local blood_colors = {
                "PychoRed1",
                "PychoRed2",
                "PychoRed3",
                "PychoRed4",
                "PychoRed5",
            }

            -- Define blood gradient colors
            vim.api.nvim_set_hl(0, "PychoRed1", { fg = "#ff0000", bold = true })
            vim.api.nvim_set_hl(0, "PychoRed2", { fg = "#cc0000", bold = true })
            vim.api.nvim_set_hl(0, "PychoRed3", { fg = "#990000", bold = true })
            vim.api.nvim_set_hl(0, "PychoRed4", { fg = "#660000", bold = true })
            vim.api.nvim_set_hl(0, "PychoRed5", { fg = "#330000", bold = true })

            dashboard.section.header.val = {
                "                                                                      ",
                "  ██████╗ ██╗   ██╗ ██████╗██╗  ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "  ██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔═══██╗██║   ██║██║████╗ ████║",
                "  ██████╔╝ ╚████╔╝ ██║     ███████║██║   ██║██║   ██║██║██╔████╔██║",
                "  ██╔═══╝   ╚██╔╝  ██║     ██╔══██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "  ██║        ██║   ╚██████╗██║  ██║╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "  ╚═╝        ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "                                                                      ",
                "                🔪 I have to return some videotapes 🔪                ",
                "                                                                      ",
            }

            -- Animate header with blood colors
            local current_color = 1
            local function animate_header()
                dashboard.section.header.opts.hl = blood_colors[current_color]
                current_color = current_color % #blood_colors + 1
                
                -- Refresh alpha if it's visible
                if vim.bo.filetype == "alpha" then
                    require("alpha").redraw()
                    vim.defer_fn(animate_header, 300)
                end
            end

            -- Start animation when alpha opens
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "alpha",
                callback = function()
                    vim.defer_fn(animate_header, 300)
                end,
            })

            dashboard.section.buttons.val = {
                dashboard.button("f", "🔍  Find File", ":Telescope find_files<CR>"),
                dashboard.button("n", "📄  New File", ":enew<CR>"),
                dashboard.button("r", "🕐  Recent Files", ":Telescope oldfiles<CR>"),
                dashboard.button("g", "📦  Clone Repository", ":lua vim.ui.input({prompt='Git URL: '}, function(url) if url then vim.cmd('!git clone ' .. url) end end)<CR>"),
                dashboard.button("d", "💬  Discord", ":!xdg-open https://discord.gg/nvim &<CR>"),
                dashboard.button("c", "⚙️   Config", ":e ~/.config/nvim/init.lua<CR>"),
                dashboard.button("q", "🚪  Quit", ":qa<CR>"),
            }

            dashboard.section.footer.val = {
                "",
                "Welcome to PychoVim - Let's see Paul Allen's config...",
            }

            alpha.setup(dashboard.config)
        end,
    }

    -- Notifications (intrusive thoughts)
    use {
        "rcarriga/nvim-notify",
        config = function()
            local notify = require("notify")
            notify.setup({
                background_colour = "#000000",
                fps = 60,
                icons = {
                    DEBUG = "🐛",
                    ERROR = "💥",
                    INFO = "ℹ️",
                    TRACE = "✎",
                    WARN = "⚠️",
                },
                level = 2,
                minimum_width = 50,
                render = "compact",
                stages = "fade_in_slide_out",
                timeout = 3000,
                top_down = true,
            })
            vim.notify = notify
        end,
    }

    -- ═══════════════════════════════════════════════════════════
    --  NAVIGATION (Stalking Tools)
    -- ═══════════════════════════════════════════════════════════

    use "nvim-lua/plenary.nvim"

    -- Telescope (surveillance system)
    use {
        "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    prompt_prefix = "🔍 ",
                    selection_caret = "▶ ",
                    path_display = { "truncate" },
                    layout_config = {
                        horizontal = {
                            preview_width = 0.55,
                        },
                    },
                },
            })
        end,
    }

    -- File tree (territory map)
    use {
        "nvim-tree/nvim-tree.lua",
        requires = "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 35,
                    side = "left",
                },
                renderer = {
                    icons = {
                        glyphs = {
                            default = "📄",
                            symlink = "🔗",
                            folder = {
                                default = "📁",
                                open = "📂",
                                empty = "📁",
                                empty_open = "📂",
                                symlink = "🔗",
                            },
                            git = {
                                unstaged = "✗",
                                staged = "✓",
                                unmerged = "⚠",
                                renamed = "➜",
                                untracked = "★",
                                deleted = "💀",
                                ignored = "◌",
                            },
                        },
                    },
                },
            })
        end,
    }

    -- ═══════════════════════════════════════════════════════════
    --  SYNTAX & HIGHLIGHTING (Forensic Analysis)
    -- ═══════════════════════════════════════════════════════════

    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "python", "javascript",
                    "typescript", "rust", "go", "c", "cpp", "bash"
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            })
        end,
    }

    -- ═══════════════════════════════════════════════════════════
    --  EDITING ENHANCEMENTS (Precision Tools)
    -- ═══════════════════════════════════════════════════════════

    -- Auto pairs (perfect symmetry)
    use {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    }

    -- Comments (inner monologue)
    use {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    }

    -- Surround (wrap victims)
    use {
        "kylechui/nvim-surround",
        config = function()
            require("nvim-surround").setup()
        end,
    }

    -- ═══════════════════════════════════════════════════════════
    --  GIT INTEGRATION (Track the evidence)
    -- ═══════════════════════════════════════════════════════════

    use {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "│" },
                    change = { text = "│" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
            })
        end,
    }

    -- ═══════════════════════════════════════════════════════════
    --  EXTRAS (Psychopathic Details)
    -- ═══════════════════════════════════════════════════════════

    -- Which-key (memory aid for the unstable)
    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup({
                window = {
                    border = "double",
                },
            })
        end,
    }

    -- Todo comments (obsessive notes)
    use {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup({
                keywords = {
                    KILL = { icon = "🔪", color = "error" },
                    VICTIM = { icon = "💀", color = "warning" },
                    HIDE = { icon = "🕵️", color = "hint" },
                },
            })
        end,
    }

    -- Smooth scrolling (elegant movements)
    use {
        "karb94/neoscroll.nvim",
        config = function()
            require("neoscroll").setup()
        end,
    }

    -- Color highlighter (blood detection)
    use {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    }
end)

