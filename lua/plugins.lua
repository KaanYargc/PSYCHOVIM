local settings = require("psychovim.settings")

local enabled = function(key)
  return function()
    return settings.get(key) ~= false
  end
end

local function mason_enabled()
  return settings.get("lsp") ~= false or settings.get("formatting") ~= false
end

local function lsp_servers()
  local servers = { "lua_ls", "pyright", "ts_ls" }
  if vim.fn.executable("go") == 1 then servers[#servers + 1] = "gopls" end
  if vim.fn.executable("cargo") == 1 or vim.fn.executable("rustc") == 1 then
    servers[#servers + 1] = "rust_analyzer"
  end
  return servers
end

local function mason_tools()
  local tools = {}

  if settings.get("formatting") ~= false then
    vim.list_extend(tools, { "stylua", "ruff", "prettierd", "prettier" })
  end

  if settings.get("lsp") ~= false then
    vim.list_extend(tools, { "lua-language-server", "pyright", "typescript-language-server" })
    if vim.fn.executable("go") == 1 then tools[#tools + 1] = "gopls" end
    if vim.fn.executable("cargo") == 1 or vim.fn.executable("rustc") == 1 then
      tools[#tools + 1] = "rust-analyzer"
    end
  end

  return tools
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        background = { light = "latte", dark = "mocha" },
        transparent_background = false,
        term_colors = true,
        styles = {
          comments = { "italic" },
          conditionals = { "bold" },
          functions = { "bold" },
          keywords = { "italic" },
        },
        color_overrides = {
          mocha = {
            base = "#0b0b0d",
            mantle = "#070709",
            crust = "#030304",
            text = "#e6e6e6",
            red = "#b11226",
            maroon = "#7f0d1d",
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvim-lualine/lualine.nvim",
    cond = enabled("statusline"),
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "│", right = "│" },
      },
      sections = {
        lualine_a = { { "mode" } },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    cond = enabled("bufferline"),
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        show_close_icon = false,
        always_show_bufferline = false,
      },
    },
  },

  {
    "folke/which-key.nvim",
    cond = enabled("which_key"),
    event = "VeryLazy",
    opts = { preset = "modern", delay = 300 },
  },

  {
    "nvim-telescope/telescope.nvim",
    cond = enabled("telescope"),
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        prompt_prefix = "> ",
        selection_caret = "> ",
        path_display = { "smart" },
        border = true,
        layout_config = { horizontal = { preview_width = 0.55 } },
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    cond = enabled("file_tree"),
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true },
      view = { width = 34 },
      renderer = {
        group_empty = true,
        highlight_git = "name",
        icons = { show = { git = true, folder = true, file = true, folder_arrow = true } },
      },
      filters = { custom = { "^.git$" } },
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },
      { "<leader>o", "<cmd>NvimTreeFocus<cr>", desc = "Focus explorer" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    cond = enabled("treesitter"),
    lazy = false,
    build = ":TSUpdate",
  },

  {
    "lewis6991/gitsigns.nvim",
    cond = enabled("gitsigns"),
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
  { "kylechui/nvim-surround", cond = enabled("surround"), version = "*", event = "VeryLazy", opts = {} },
  { "windwp/nvim-autopairs", cond = enabled("autopairs"), event = "InsertEnter", opts = {} },
  {
    "lukas-reineke/indent-blankline.nvim",
    cond = enabled("indent_guides"),
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },
  {
    "folke/todo-comments.nvim",
    cond = enabled("todo_comments"),
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "rcarriga/nvim-notify",
    cond = enabled("notifications"),
    lazy = false,
    opts = {
      stages = "fade_in_slide_out",
      render = "compact",
      timeout = 2500,
      background_colour = "#000000",
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  {
    "mason-org/mason.nvim",
    cond = mason_enabled,
    opts = function()
      return {
        max_concurrent_installers = 2,
        ui = { border = settings.get("popup_border") or "rounded" },
      }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cond = mason_enabled,
    dependencies = { "mason-org/mason.nvim" },
    opts = function()
      return {
        ensure_installed = mason_tools(),
        auto_update = false,
        run_on_start = false,
        integrations = {
          ["mason-lspconfig"] = false,
          ["mason-null-ls"] = false,
          ["mason-nvim-dap"] = false,
        },
      }
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    cond = enabled("lsp"),
    dependencies = {
      { "mason-org/mason.nvim" },
      "neovim/nvim-lspconfig",
    },
    opts = function()
      return {
        ensure_installed = lsp_servers(),
        automatic_enable = true,
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    cond = enabled("lsp"),
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = settings.get("popup_border") or "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = true,
        virtual_text = settings.get("diagnostic_virtual_text") and { spacing = 2, source = "if_many" } or false,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("PsychovimLsp", { clear = true }),
        callback = function(event)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },

  {
    "saghen/blink.cmp",
    cond = enabled("completion"),
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  {
    "stevearc/conform.nvim",
    cond = enabled("formatting"),
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        desc = "Format file",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 1200, lsp_format = "fallback" }
      end,
    },
  },

  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      dashboard = {
        preset = {
          header = [[
PIERCE & PIERCE
MERGERS AND ACQUISITIONS

P S Y C H O V I M
VICE PRESIDENT

THIS IS NOT AN EXIT.
]],
          keys = {
            { icon = "  ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = "  ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = "  ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "  ", key = "s", desc = "Settings", action = ":PychoSettings" },
            { icon = "  ", key = "l", desc = "Plugin Inventory", action = ":Lazy" },
            { icon = "  ", key = "q", desc = "PychoClose", action = ":lua require('psychovim.pycho_close').open()" },
          },
        },
      },
    },
  },
}
