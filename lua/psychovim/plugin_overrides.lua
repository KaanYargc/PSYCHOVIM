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

THIS IS NOT AN EXIT.
]]
      opts.dashboard.preset.keys = {
        { icon = "  ", key = "f", desc = "Find File", action = ":Telescope find_files" },
        { icon = "  ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
        { icon = "  ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = "  ", key = "s", desc = "Settings", action = ":PychoSettings" },
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
