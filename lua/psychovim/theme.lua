local M = {}

local palettes = {
  sanity = {
    bg = "#0a0a0b",
    float = "#111113",
    fg = "#e8e2d8",
    muted = "#68645f",
    border = "#b9b1a6",
    accent = "#d8d0c4",
    red = "#7e1724",
    visual = "#262321",
    search = "#3a302b",
  },
  after_hours = {
    bg = "#050405",
    float = "#0c0809",
    fg = "#eadfda",
    muted = "#665457",
    border = "#791722",
    accent = "#c9b4b1",
    red = "#c21f32",
    visual = "#310c13",
    search = "#53101b",
  },
}

local function set(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

function M.apply(mode)
  mode = palettes[mode] and mode or "sanity"
  local p = palettes[mode]
  vim.g.psychovim_mask = mode

  set("Normal", { fg = p.fg, bg = p.bg })
  set("NormalNC", { fg = p.fg, bg = p.bg })
  set("NormalFloat", { fg = p.fg, bg = p.float })
  set("FloatBorder", { fg = p.border, bg = p.float })
  set("WinSeparator", { fg = p.muted, bg = p.bg })
  set("CursorLine", { bg = p.visual })
  set("CursorLineNr", { fg = p.red, bold = true })
  set("LineNr", { fg = p.muted })
  set("Visual", { bg = p.visual })
  set("Search", { fg = p.fg, bg = p.search, bold = true })
  set("IncSearch", { fg = p.bg, bg = p.red, bold = true })
  set("MatchParen", { fg = p.red, bold = true, underline = true })
  set("Pmenu", { fg = p.fg, bg = p.float })
  set("PmenuSel", { fg = p.bg, bg = p.accent, bold = true })
  set("StatusLine", { fg = p.fg, bg = p.float })
  set("StatusLineNC", { fg = p.muted, bg = p.bg })
  set("DiagnosticError", { fg = p.red })
  set("DiagnosticWarn", { fg = mode == "sanity" and "#b99766" or "#c4865c" })

  set("PsychovimCardTitle", { fg = p.accent, bold = true })
  set("PsychovimCardAccent", { fg = p.red, bold = true })
  set("PsychovimMuted", { fg = p.muted, italic = true })
end

function M.toggle()
  require("psychovim.settings").toggle_mask()
end

function M.setup()
  vim.g.psychovim_mask = vim.g.psychovim_mask or "sanity"
  vim.api.nvim_create_user_command("Mask", function()
    require("psychovim.settings").set("mask", "sanity")
    vim.notify("Mask on.")
  end, { desc = "Restore the restrained PSYCHOVIM palette" })
  vim.api.nvim_create_user_command("AfterHours", function()
    require("psychovim.settings").set("mask", "after_hours")
    vim.notify("After hours.")
  end, { desc = "Use the red-heavy PSYCHOVIM palette" })

  local group = vim.api.nvim_create_augroup("PsychovimTheme", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      vim.schedule(function() M.apply(vim.g.psychovim_mask) end)
    end,
  })
end

return M
