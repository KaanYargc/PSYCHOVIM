return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.input = { enabled = true }
      opts.picker = vim.tbl_deep_extend("force", opts.picker or {}, {
        enabled = true,
        ui_select = true,
      })

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = [[
PIERCE & PIERCE
MERGERS AND ACQUISITIONS

P S Y C H O V I M
VICE PRESIDENT

Appearance is everything. Precision is policy.
]]
      opts.dashboard.preset.keys = {
        { icon = "  ", key = "f", desc = "Find File", action = ":Telescope find_files" },
        { icon = "  ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
        { icon = "  ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = "  ", key = "b", desc = "Business Card", action = ":BusinessCard" },
        { icon = "  ", key = "d", desc = "Dorsia", action = ":Dorsia" },
        { icon = "  ", key = "m", desc = "Morning Routine", action = ":MorningRoutine" },
        { icon = "  ", key = "l", desc = "Plugin Inventory", action = ":Lazy" },
        { icon = "  ", key = "q", desc = "SmartClose", action = ":lua require('psychovim.smart_close').open()" },
      }
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(value)
            return "P&P " .. value
          end,
        },
      }
    end,
  },
}
