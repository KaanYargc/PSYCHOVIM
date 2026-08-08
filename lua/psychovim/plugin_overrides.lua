return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local settings = require("psychovim.settings")
      local marketplace = require("psychovim.marketplace")
      local default_editor = require("psychovim.default_editor")

      opts.input = { enabled = true }
      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        enabled = true,
        ui_select = true,
      })

      local function find_files()
        if settings.get("telescope") ~= false and vim.fn.exists(":Telescope") == 2 then
          vim.cmd("Telescope find_files")
        else
          Snacks.picker.files()
        end
      end

      local function recent_files()
        if settings.get("telescope") ~= false and vim.fn.exists(":Telescope") == 2 then
          vim.cmd("Telescope oldfiles")
        else
          Snacks.picker.recent()
        end
      end

      local default_ok = default_editor.is_default()
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = [[
PIERCE & PIERCE
MERGERS AND ACQUISITIONS

P S Y C H O V I M
VICE PRESIDENT

THIS IS NOT AN EXIT.
]]
      opts.dashboard.preset.keys = {
        { icon = default_ok and "⚙ " or " ⚙ ", key = "s", desc = default_ok and "Settings" or "Settings · restore default editor", action = settings.open },
        { icon = "󰏗 ", key = "p", desc = "Marketplace", action = marketplace.open },
        { icon = "  ", key = "f", desc = "Find File", action = find_files },
        { icon = "  ", key = "r", desc = "Recent Files", action = recent_files },
        { icon = "  ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = "  ", key = "b", desc = "Business Card", action = ":BusinessCard" },
        { icon = "  ", key = "d", desc = "Dorsia", action = ":Dorsia" },
        { icon = "  ", key = "m", desc = "Morning Routine", action = ":MorningRoutine" },
        { icon = "  ", key = "l", desc = "Plugin Inventory", action = ":Lazy" },
        { icon = "  ", key = "q", desc = "PychoClose", action = ":lua require('psychovim.pycho_close').open()" },
      }
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local settings = require("psychovim.settings")
      local marketplace = require("psychovim.marketplace")
      local default_editor = require("psychovim.default_editor")

      opts.sections = opts.sections or {}
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(value)
            return "P&P " .. value
          end,
        },
      }
      opts.sections.lualine_z = {
        "location",
        {
          function()
            return default_editor.is_default() and "⚙" or " ⚙"
          end,
          on_click = function() settings.open() end,
          separator = { left = "", right = "" },
          padding = { left = 1, right = 1 },
        },
        {
          function() return "󰏗" end,
          on_click = function() marketplace.open() end,
          separator = { left = "", right = "" },
          padding = { left = 1, right = 1 },
        },
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      local treesitter = require("nvim-treesitter")
      local languages = {
        "bash", "c", "cpp", "go", "javascript", "json", "lua", "markdown",
        "python", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      }

      treesitter.setup({})

      vim.api.nvim_create_user_command("PychoParsers", function()
        vim.notify("Pycho · parser sync started")
        treesitter.install(languages)
      end, { desc = "Install PSYCHOVIM Treesitter parsers" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = languages,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end,
  },
}
