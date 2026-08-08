return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local settings = require("psychovim.settings")
      local marketplace = require("psychovim.marketplace")
      local updater = require("psychovim.updater")

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

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = [[
PIERCE & PIERCE
MERGERS AND ACQUISITIONS

P Y C H O V I M
VICE PRESIDENT

THIS IS NOT AN EXIT.
]]
      opts.dashboard.preset.keys = {
        { icon = "󰏗 ", key = "e", desc = "Extensions", action = marketplace.open },
        { icon = "  ", key = "s", desc = "Settings", action = settings.open },
        { icon = "󰚰 ", key = "u", desc = "Update", action = updater.run },
        { icon = "󰈞 ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = "󰈔 ", key = "f", desc = "Find File", action = find_files },
        { icon = "󰋚 ", key = "r", desc = "Recent Files", action = recent_files },
        { icon = "󰌾 ", key = "d", desc = "Dorsia", action = ":Dorsia" },
        { icon = "󰌪 ", key = "b", desc = "Business Card", action = ":BusinessCard" },
        { icon = "󰍃 ", key = "q", desc = "PychoClose", action = ":lua require('psychovim.pycho_close').open()" },
      }
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local settings = require("psychovim.settings")
      local marketplace = require("psychovim.marketplace")

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
          function() return "" end,
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
        vim.notify("Parser sync started.", vim.log.levels.INFO, { title = "PychoVIM" })
        treesitter.install(languages)
      end, { desc = "Install PychoVIM Treesitter parsers" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = languages,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end,
  },
}
