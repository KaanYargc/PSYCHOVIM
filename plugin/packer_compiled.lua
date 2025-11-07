-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/onur/.cache/nvim/packer_hererocks/2.1.1761727121/share/lua/5.1/?.lua;/home/onur/.cache/nvim/packer_hererocks/2.1.1761727121/share/lua/5.1/?/init.lua;/home/onur/.cache/nvim/packer_hererocks/2.1.1761727121/lib/luarocks/rocks-5.1/?.lua;/home/onur/.cache/nvim/packer_hererocks/2.1.1761727121/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/onur/.cache/nvim/packer_hererocks/2.1.1761727121/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    config = { "\27LJ\2\n5\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\fComment\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  ["alpha-nvim"] = {
    config = { "\27LJ\2\n�\1\0\0\4\4\v\1\30-\0\0\0009\0\0\0009\0\1\0009\0\2\0-\1\1\0-\2\2\0008\1\2\1=\1\3\0-\0\2\0-\1\1\0\21\1\1\0$\0\1\0\22\0\0\0.\2\0\0006\0\4\0009\0\5\0009\0\6\0\a\0\a\0X\0\n�6\0\b\0'\2\a\0B\0\2\0029\0\t\0B\0\1\0016\0\4\0009\0\n\0-\2\3\0)\3,\1B\0\3\1K\0\1\0\1�\2�\3�\4�\rdefer_fn\vredraw\frequire\nalpha\rfiletype\abo\bvim\ahl\topts\vheader\fsection\2.\0\0\4\1\2\0\0066\0\0\0009\0\1\0-\2\0\0)\3,\1B\0\3\1K\0\1\0\4�\rdefer_fn\bvim�\20\1\0\f\0006\1o6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0025\2\3\0006\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\a\0005\a\b\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\t\0005\a\n\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\v\0005\a\f\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\r\0005\a\14\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\15\0005\a\16\0B\3\4\0019\3\17\0019\3\18\0035\4\20\0=\4\19\3)\3\1\0003\4\21\0006\5\4\0009\5\5\0059\5\22\5'\a\23\0005\b\24\0003\t\25\0=\t\26\bB\5\3\0019\5\17\0019\5\27\0054\6\b\0009\a\28\1'\t\29\0'\n\30\0'\v\31\0B\a\4\2>\a\1\0069\a\28\1'\t \0'\n!\0'\v\"\0B\a\4\2>\a\2\0069\a\28\1'\t#\0'\n$\0'\v%\0B\a\4\2>\a\3\0069\a\28\1'\t&\0'\n'\0'\v(\0B\a\4\2>\a\4\0069\a\28\1'\t)\0'\n*\0'\v+\0B\a\4\2>\a\5\0069\a\28\1'\t,\0'\n-\0'\v.\0B\a\4\2>\a\6\0069\a\28\1'\t/\0'\n0\0'\v1\0B\a\4\0?\a\0\0=\6\19\0059\5\17\0019\0052\0055\0063\0=\6\19\0059\0054\0009\a5\1B\5\2\0012\0\0�K\0\1\0\vconfig\nsetup\1\3\0\0\5;Welcome to PychoVim - Let's see Paul Allen's config...\vfooter\f:qa<CR>\15🚪  Quit\6q#:e ~/.config/nvim/init.lua<CR>\20⚙️   Config\6c-:!xdg-open https://discord.gg/nvim &<CR>\18💬  Discord\6dq:lua vim.ui.input({prompt='Git URL: '}, function(url) if url then vim.cmd('!git clone ' .. url) end end)<CR>\27📦  Clone Repository\6g\28:Telescope oldfiles<CR>\23🕐  Recent Files\6r\14:enew<CR>\19📄  New File\6n\30:Telescope find_files<CR>\20🔍  Find File\6f\vbutton\fbuttons\rcallback\0\1\0\2\fpattern\nalpha\rcallback\0\rFileType\24nvim_create_autocmd\0\1\v\0\0K                                                                      �\1  ██████╗ ██╗   ██╗ ██████╗██╗  ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗�\1  ██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔═══██╗██║   ██║██║████╗ ████║�\1  ██████╔╝ ╚████╔╝ ██║     ███████║██║   ██║██║   ██║██║██╔████╔██║�\1  ██╔═══╝   ╚██╔╝  ██║     ██╔══██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║�\1  ██║        ██║   ╚██████╗██║  ██║╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║�\1  ╚═╝        ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝K                                                                      O                🔪 I have to return some videotapes 🔪                K                                                                      \bval\vheader\fsection\1\0\2\afg\f#330000\tbold\2\14PychoRed5\1\0\2\afg\f#660000\tbold\2\14PychoRed4\1\0\2\afg\f#990000\tbold\2\14PychoRed3\1\0\2\afg\f#cc0000\tbold\2\14PychoRed2\1\0\2\afg\f#ff0000\tbold\2\14PychoRed1\16nvim_set_hl\bapi\bvim\1\6\0\0\14PychoRed1\14PychoRed2\14PychoRed3\14PychoRed4\14PychoRed5\27alpha.themes.dashboard\nalpha\frequire\15����\4\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/alpha-nvim",
    url = "https://github.com/goolord/alpha-nvim"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\nY\0\2\6\0\5\0\14\18\4\1\0009\2\0\1'\5\1\0B\2\3\2\15\0\2\0X\3\2�'\2\2\0X\3\1�'\2\3\0'\3\4\0\18\4\2\0\18\5\0\0&\3\5\3L\3\2\0\6 \v⚠️\t💥\nerror\nmatch�\2\1\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0003\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\1\foptions\0\26diagnostics_indicator\0\1\0\b\26diagnostics_indicator\0\20separator_style\nslant\16color_icons\2\tmode\fbuffers\28show_buffer_close_icons\2\16diagnostics\rnvim_lsp\20show_close_icon\1\27always_show_bufferline\2\nsetup\15bufferline\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  catppuccin = {
    config = { "\27LJ\2\n�\1\0\1\4\0\t\0\n5\1\1\0005\2\0\0=\2\2\0015\2\3\0=\2\4\0015\2\5\0005\3\6\0=\3\a\2=\2\b\1L\1\2\0\17CursorLineNr\nstyle\1\2\0\0\tbold\1\0\2\afg\f#8b0000\nstyle\0\vLineNr\1\0\1\afg\f#4a4a4a\15CursorLine\1\0\3\17CursorLineNr\0\15CursorLine\0\vLineNr\0\1\0\1\abg\f#1a1a1a�\5\1\0\5\0!\0*6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0034\4\0\0=\4\15\0034\4\0\0=\4\16\0034\4\0\0=\4\17\0035\4\18\0=\4\19\0034\4\0\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\25\0005\4\24\0=\4\26\3=\3\27\0023\3\28\0=\3\29\2B\0\2\0016\0\30\0009\0\31\0009\0 \0'\2\1\0B\0\2\1K\0\1\0\16colorscheme\bcmd\bvim\22custom_highlights\0\20color_overrides\nmocha\1\0\1\nmocha\0\1\0\6\tbase\f#0d0d0d\vmaroon\f#800000\bred\f#8b0000\ttext\f#e0e0e0\ncrust\f#000000\vmantle\f#000000\vstyles\ntypes\1\2\0\0\tbold\15properties\rbooleans\1\2\0\0\tbold\fnumbers\14variables\fstrings\rkeywords\1\2\0\0\vitalic\14functions\1\2\0\0\tbold\nloops\1\2\0\0\tbold\17conditionals\1\2\0\0\tbold\rcomments\1\0\v\ntypes\0\15properties\0\rbooleans\0\fnumbers\0\14variables\0\fstrings\0\rkeywords\0\14functions\0\nloops\0\17conditionals\0\rcomments\0\1\2\0\0\vitalic\1\0\6\20color_overrides\0\fflavour\nmocha\16term_colors\2\22custom_highlights\0\vstyles\0\27transparent_background\1\nsetup\15catppuccin\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n�\2\0\0\5\0\16\0\0196\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\2B\0\2\1K\0\1\0\nsigns\1\0\1\nsigns\0\17changedelete\1\0\1\ttext\6~\14topdelete\1\0\1\ttext\b‾\vdelete\1\0\1\ttext\6_\vchange\1\0\1\ttext\b│\badd\1\0\5\14topdelete\0\vdelete\0\vchange\0\badd\0\17changedelete\0\1\0\1\ttext\b│\nsetup\rgitsigns\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\n�\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\nscope\1\0\3\15show_start\2\fenabled\2\rshow_end\2\vindent\1\0\2\vindent\0\nscope\0\1\0\2\rtab_char\b│\tchar\b│\nsetup\bibl\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n\29\0\1\3\0\1\0\4'\1\0\0\18\2\0\0&\1\2\1L\1\2\0\n🔪 �\6\1\0\a\0 \0)6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\r\0004\4\3\0005\5\n\0003\6\v\0=\6\f\5>\5\1\4=\4\14\0035\4\15\0=\4\16\0034\4\3\0005\5\17\0005\6\18\0=\6\19\5>\5\1\4=\4\20\0035\4\25\0005\5\21\0005\6\22\0=\6\23\0055\6\24\0=\6\19\5>\5\1\4=\4\26\0035\4\27\0=\4\28\0035\4\29\0=\4\30\3=\3\31\2B\0\2\1K\0\1\0\rsections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\5\0\0\0\rencoding\15fileformat\rfiletype\1\0\4\thint\n💡 \twarn\r⚠️  \nerror\n💥 \tinfo\rℹ️  \fsources\1\2\0\0\20nvim_diagnostic\1\2\2\0\16diagnostics\fsources\0\fsymbols\0\14lualine_c\fsymbols\1\0\3\rmodified\n 💀\funnamed\n 👤\rreadonly\n 🔒\1\2\2\0\rfilename\tpath\3\1\fsymbols\0\14lualine_b\1\3\0\0\vbranch\tdiff\14lualine_a\1\0\6\14lualine_z\0\14lualine_b\0\14lualine_y\0\14lualine_a\0\14lualine_x\0\14lualine_c\0\bfmt\0\1\2\1\0\tmode\bfmt\0\foptions\1\0\2\foptions\0\rsections\0\23section_separators\1\0\2\tleft\5\nright\5\25component_separators\1\0\2\tleft\b│\nright\b│\1\0\4\23section_separators\0\ntheme\tauto\17globalstatus\2\25component_separators\0\nsetup\flualine\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["neoscroll.nvim"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14neoscroll\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/neoscroll.nvim",
    url = "https://github.com/karb94/neoscroll.nvim"
  },
  ["nightfox.nvim"] = {
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nightfox.nvim",
    url = "https://github.com/EdenEast/nightfox.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n@\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14colorizer\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-notify"] = {
    config = { "\27LJ\2\n�\2\0\0\5\0\a\0\v6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\3\0005\4\4\0=\4\5\3B\1\2\0016\1\6\0=\0\1\1K\0\1\0\bvim\nicons\1\0\5\tWARN\v⚠️\nTRACE\b✎\nDEBUG\t🐛\tINFO\vℹ️\nERROR\t💥\1\0\t\rtop_down\2\ftimeout\3�\23\vstages\22fade_in_slide_out\nlevel\3\2\vrender\fcompact\18minimum_width\0032\nicons\0\bfps\3<\22background_colour\f#000000\nsetup\vnotify\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-surround"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\18nvim-surround\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-surround",
    url = "https://github.com/kylechui/nvim-surround"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n�\3\0\0\a\0\16\0\0196\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\r\0005\4\v\0005\5\6\0005\6\a\0=\6\b\0055\6\t\0=\6\n\5=\5\f\4=\4\14\3=\3\15\2B\0\2\1K\0\1\0\rrenderer\nicons\1\0\1\nicons\0\vglyphs\1\0\1\vglyphs\0\bgit\1\0\a\14untracked\b★\frenamed\b➜\fdeleted\t💀\runmerged\b⚠\fignored\b◌\vstaged\b✓\runstaged\b✗\vfolder\1\0\5\topen\t📂\15empty_open\t📂\nempty\t📁\fdefault\t📁\fsymlink\t🔗\1\0\4\bgit\0\fdefault\t📄\vfolder\0\fsymlink\t🔗\tview\1\0\2\tview\0\rrenderer\0\1\0\2\nwidth\3#\tside\tleft\nsetup\14nvim-tree\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n�\2\0\0\4\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\vindent\1\0\1\venable\2\14highlight\1\0\2\venable\2&additional_vim_regex_highlighting\1\21ensure_installed\1\0\3\vindent\0\14highlight\0\21ensure_installed\0\1\f\0\0\blua\bvim\vvimdoc\vpython\15javascript\15typescript\trust\ago\6c\bcpp\tbash\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["rose-pine"] = {
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/rose-pine",
    url = "https://github.com/rose-pine/neovim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\n�\2\0\0\6\0\f\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\3\0005\4\4\0=\4\5\0035\4\a\0005\5\6\0=\5\b\4=\4\t\3=\3\v\2B\0\2\1K\0\1\0\rdefaults\1\0\1\rdefaults\0\18layout_config\15horizontal\1\0\1\15horizontal\0\1\0\1\18preview_width\4����\t����\3\17path_display\1\2\0\0\rtruncate\1\0\4\17path_display\0\20selection_caret\t▶ \18layout_config\0\18prompt_prefix\n🔍 \nsetup\14telescope\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["todo-comments.nvim"] = {
    config = { "\27LJ\2\n�\1\0\0\5\0\f\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\3=\3\v\2B\0\2\1K\0\1\0\rkeywords\1\0\1\rkeywords\0\tHIDE\1\0\2\ncolor\thint\ticon\f🕵️\vVICTIM\1\0\2\ncolor\fwarning\ticon\t💀\tKILL\1\0\3\tHIDE\0\tKILL\0\vVICTIM\0\1\0\2\ncolor\nerror\ticon\t🔪\nsetup\18todo-comments\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/todo-comments.nvim",
    url = "https://github.com/folke/todo-comments.nvim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/tokyonight.nvim",
    url = "https://github.com/folke/tokyonight.nvim"
  },
  ["which-key.nvim"] = {
    config = { "\27LJ\2\nf\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\vwindow\1\0\1\vwindow\0\1\0\1\vborder\vdouble\nsetup\14which-key\frequire\0" },
    loaded = true,
    path = "/home/onur/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14colorizer\frequire\0", "config", "nvim-colorizer.lua")
time([[Config for nvim-colorizer.lua]], false)
-- Config for: todo-comments.nvim
time([[Config for todo-comments.nvim]], true)
try_loadstring("\27LJ\2\n�\1\0\0\5\0\f\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\3=\3\v\2B\0\2\1K\0\1\0\rkeywords\1\0\1\rkeywords\0\tHIDE\1\0\2\ncolor\thint\ticon\f🕵️\vVICTIM\1\0\2\ncolor\fwarning\ticon\t💀\tKILL\1\0\3\tHIDE\0\tKILL\0\vVICTIM\0\1\0\2\ncolor\nerror\ticon\t🔪\nsetup\18todo-comments\frequire\0", "config", "todo-comments.nvim")
time([[Config for todo-comments.nvim]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\nY\0\2\6\0\5\0\14\18\4\1\0009\2\0\1'\5\1\0B\2\3\2\15\0\2\0X\3\2�'\2\2\0X\3\1�'\2\3\0'\3\4\0\18\4\2\0\18\5\0\0&\3\5\3L\3\2\0\6 \v⚠️\t💥\nerror\nmatch�\2\1\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0003\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\1\foptions\0\26diagnostics_indicator\0\1\0\b\26diagnostics_indicator\0\20separator_style\nslant\16color_icons\2\tmode\fbuffers\28show_buffer_close_icons\2\16diagnostics\rnvim_lsp\20show_close_icon\1\27always_show_bufferline\2\nsetup\15bufferline\frequire\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: nvim-autopairs
time([[Config for nvim-autopairs]], true)
try_loadstring("\27LJ\2\n@\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\19nvim-autopairs\frequire\0", "config", "nvim-autopairs")
time([[Config for nvim-autopairs]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
try_loadstring("\27LJ\2\nf\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\vwindow\1\0\1\vwindow\0\1\0\1\vborder\vdouble\nsetup\14which-key\frequire\0", "config", "which-key.nvim")
time([[Config for which-key.nvim]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\n�\2\0\0\5\0\16\0\0196\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\2B\0\2\1K\0\1\0\nsigns\1\0\1\nsigns\0\17changedelete\1\0\1\ttext\6~\14topdelete\1\0\1\ttext\b‾\vdelete\1\0\1\ttext\6_\vchange\1\0\1\ttext\b│\badd\1\0\5\14topdelete\0\vdelete\0\vchange\0\badd\0\17changedelete\0\1\0\1\ttext\b│\nsetup\rgitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n�\3\0\0\a\0\16\0\0196\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\r\0005\4\v\0005\5\6\0005\6\a\0=\6\b\0055\6\t\0=\6\n\5=\5\f\4=\4\14\3=\3\15\2B\0\2\1K\0\1\0\rrenderer\nicons\1\0\1\nicons\0\vglyphs\1\0\1\vglyphs\0\bgit\1\0\a\14untracked\b★\frenamed\b➜\fdeleted\t💀\runmerged\b⚠\fignored\b◌\vstaged\b✓\runstaged\b✗\vfolder\1\0\5\topen\t📂\15empty_open\t📂\nempty\t📁\fdefault\t📁\fsymlink\t🔗\1\0\4\bgit\0\fdefault\t📄\vfolder\0\fsymlink\t🔗\tview\1\0\2\tview\0\rrenderer\0\1\0\2\nwidth\3#\tside\tleft\nsetup\14nvim-tree\frequire\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: indent-blankline.nvim
time([[Config for indent-blankline.nvim]], true)
try_loadstring("\27LJ\2\n�\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\nscope\1\0\3\15show_start\2\fenabled\2\rshow_end\2\vindent\1\0\2\vindent\0\nscope\0\1\0\2\rtab_char\b│\tchar\b│\nsetup\bibl\frequire\0", "config", "indent-blankline.nvim")
time([[Config for indent-blankline.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n�\2\0\0\4\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\vindent\1\0\1\venable\2\14highlight\1\0\2\venable\2&additional_vim_regex_highlighting\1\21ensure_installed\1\0\3\vindent\0\14highlight\0\21ensure_installed\0\1\f\0\0\blua\bvim\vvimdoc\vpython\15javascript\15typescript\trust\ago\6c\bcpp\tbash\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n\29\0\1\3\0\1\0\4'\1\0\0\18\2\0\0&\1\2\1L\1\2\0\n🔪 �\6\1\0\a\0 \0)6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\b\0005\3\3\0005\4\4\0=\4\5\0035\4\6\0=\4\a\3=\3\t\0025\3\r\0004\4\3\0005\5\n\0003\6\v\0=\6\f\5>\5\1\4=\4\14\0035\4\15\0=\4\16\0034\4\3\0005\5\17\0005\6\18\0=\6\19\5>\5\1\4=\4\20\0035\4\25\0005\5\21\0005\6\22\0=\6\23\0055\6\24\0=\6\19\5>\5\1\4=\4\26\0035\4\27\0=\4\28\0035\4\29\0=\4\30\3=\3\31\2B\0\2\1K\0\1\0\rsections\14lualine_z\1\2\0\0\rlocation\14lualine_y\1\2\0\0\rprogress\14lualine_x\1\5\0\0\0\rencoding\15fileformat\rfiletype\1\0\4\thint\n💡 \twarn\r⚠️  \nerror\n💥 \tinfo\rℹ️  \fsources\1\2\0\0\20nvim_diagnostic\1\2\2\0\16diagnostics\fsources\0\fsymbols\0\14lualine_c\fsymbols\1\0\3\rmodified\n 💀\funnamed\n 👤\rreadonly\n 🔒\1\2\2\0\rfilename\tpath\3\1\fsymbols\0\14lualine_b\1\3\0\0\vbranch\tdiff\14lualine_a\1\0\6\14lualine_z\0\14lualine_b\0\14lualine_y\0\14lualine_a\0\14lualine_x\0\14lualine_c\0\bfmt\0\1\2\1\0\tmode\bfmt\0\foptions\1\0\2\foptions\0\rsections\0\23section_separators\1\0\2\tleft\5\nright\5\25component_separators\1\0\2\tleft\b│\nright\b│\1\0\4\23section_separators\0\ntheme\tauto\17globalstatus\2\25component_separators\0\nsetup\flualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: neoscroll.nvim
time([[Config for neoscroll.nvim]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14neoscroll\frequire\0", "config", "neoscroll.nvim")
time([[Config for neoscroll.nvim]], false)
-- Config for: nvim-notify
time([[Config for nvim-notify]], true)
try_loadstring("\27LJ\2\n�\2\0\0\5\0\a\0\v6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\3\0005\4\4\0=\4\5\3B\1\2\0016\1\6\0=\0\1\1K\0\1\0\bvim\nicons\1\0\5\tWARN\v⚠️\nTRACE\b✎\nDEBUG\t🐛\tINFO\vℹ️\nERROR\t💥\1\0\t\rtop_down\2\ftimeout\3�\23\vstages\22fade_in_slide_out\nlevel\3\2\vrender\fcompact\18minimum_width\0032\nicons\0\bfps\3<\22background_colour\f#000000\nsetup\vnotify\frequire\0", "config", "nvim-notify")
time([[Config for nvim-notify]], false)
-- Config for: Comment.nvim
time([[Config for Comment.nvim]], true)
try_loadstring("\27LJ\2\n5\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\fComment\frequire\0", "config", "Comment.nvim")
time([[Config for Comment.nvim]], false)
-- Config for: catppuccin
time([[Config for catppuccin]], true)
try_loadstring("\27LJ\2\n�\1\0\1\4\0\t\0\n5\1\1\0005\2\0\0=\2\2\0015\2\3\0=\2\4\0015\2\5\0005\3\6\0=\3\a\2=\2\b\1L\1\2\0\17CursorLineNr\nstyle\1\2\0\0\tbold\1\0\2\afg\f#8b0000\nstyle\0\vLineNr\1\0\1\afg\f#4a4a4a\15CursorLine\1\0\3\17CursorLineNr\0\15CursorLine\0\vLineNr\0\1\0\1\abg\f#1a1a1a�\5\1\0\5\0!\0*6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0034\4\0\0=\4\15\0034\4\0\0=\4\16\0034\4\0\0=\4\17\0035\4\18\0=\4\19\0034\4\0\0=\4\20\0035\4\21\0=\4\22\3=\3\23\0025\3\25\0005\4\24\0=\4\26\3=\3\27\0023\3\28\0=\3\29\2B\0\2\0016\0\30\0009\0\31\0009\0 \0'\2\1\0B\0\2\1K\0\1\0\16colorscheme\bcmd\bvim\22custom_highlights\0\20color_overrides\nmocha\1\0\1\nmocha\0\1\0\6\tbase\f#0d0d0d\vmaroon\f#800000\bred\f#8b0000\ttext\f#e0e0e0\ncrust\f#000000\vmantle\f#000000\vstyles\ntypes\1\2\0\0\tbold\15properties\rbooleans\1\2\0\0\tbold\fnumbers\14variables\fstrings\rkeywords\1\2\0\0\vitalic\14functions\1\2\0\0\tbold\nloops\1\2\0\0\tbold\17conditionals\1\2\0\0\tbold\rcomments\1\0\v\ntypes\0\15properties\0\rbooleans\0\fnumbers\0\14variables\0\fstrings\0\rkeywords\0\14functions\0\nloops\0\17conditionals\0\rcomments\0\1\2\0\0\vitalic\1\0\6\20color_overrides\0\fflavour\nmocha\16term_colors\2\22custom_highlights\0\vstyles\0\27transparent_background\1\nsetup\15catppuccin\frequire\0", "config", "catppuccin")
time([[Config for catppuccin]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n�\2\0\0\6\0\f\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\n\0005\3\3\0005\4\4\0=\4\5\0035\4\a\0005\5\6\0=\5\b\4=\4\t\3=\3\v\2B\0\2\1K\0\1\0\rdefaults\1\0\1\rdefaults\0\18layout_config\15horizontal\1\0\1\15horizontal\0\1\0\1\18preview_width\4����\t����\3\17path_display\1\2\0\0\rtruncate\1\0\4\17path_display\0\20selection_caret\t▶ \18layout_config\0\18prompt_prefix\n🔍 \nsetup\14telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: nvim-surround
time([[Config for nvim-surround]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\18nvim-surround\frequire\0", "config", "nvim-surround")
time([[Config for nvim-surround]], false)
-- Config for: alpha-nvim
time([[Config for alpha-nvim]], true)
try_loadstring("\27LJ\2\n�\1\0\0\4\4\v\1\30-\0\0\0009\0\0\0009\0\1\0009\0\2\0-\1\1\0-\2\2\0008\1\2\1=\1\3\0-\0\2\0-\1\1\0\21\1\1\0$\0\1\0\22\0\0\0.\2\0\0006\0\4\0009\0\5\0009\0\6\0\a\0\a\0X\0\n�6\0\b\0'\2\a\0B\0\2\0029\0\t\0B\0\1\0016\0\4\0009\0\n\0-\2\3\0)\3,\1B\0\3\1K\0\1\0\1�\2�\3�\4�\rdefer_fn\vredraw\frequire\nalpha\rfiletype\abo\bvim\ahl\topts\vheader\fsection\2.\0\0\4\1\2\0\0066\0\0\0009\0\1\0-\2\0\0)\3,\1B\0\3\1K\0\1\0\4�\rdefer_fn\bvim�\20\1\0\f\0006\1o6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0025\2\3\0006\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\a\0005\a\b\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\t\0005\a\n\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\v\0005\a\f\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\r\0005\a\14\0B\3\4\0016\3\4\0009\3\5\0039\3\6\3)\5\0\0'\6\15\0005\a\16\0B\3\4\0019\3\17\0019\3\18\0035\4\20\0=\4\19\3)\3\1\0003\4\21\0006\5\4\0009\5\5\0059\5\22\5'\a\23\0005\b\24\0003\t\25\0=\t\26\bB\5\3\0019\5\17\0019\5\27\0054\6\b\0009\a\28\1'\t\29\0'\n\30\0'\v\31\0B\a\4\2>\a\1\0069\a\28\1'\t \0'\n!\0'\v\"\0B\a\4\2>\a\2\0069\a\28\1'\t#\0'\n$\0'\v%\0B\a\4\2>\a\3\0069\a\28\1'\t&\0'\n'\0'\v(\0B\a\4\2>\a\4\0069\a\28\1'\t)\0'\n*\0'\v+\0B\a\4\2>\a\5\0069\a\28\1'\t,\0'\n-\0'\v.\0B\a\4\2>\a\6\0069\a\28\1'\t/\0'\n0\0'\v1\0B\a\4\0?\a\0\0=\6\19\0059\5\17\0019\0052\0055\0063\0=\6\19\0059\0054\0009\a5\1B\5\2\0012\0\0�K\0\1\0\vconfig\nsetup\1\3\0\0\5;Welcome to PychoVim - Let's see Paul Allen's config...\vfooter\f:qa<CR>\15🚪  Quit\6q#:e ~/.config/nvim/init.lua<CR>\20⚙️   Config\6c-:!xdg-open https://discord.gg/nvim &<CR>\18💬  Discord\6dq:lua vim.ui.input({prompt='Git URL: '}, function(url) if url then vim.cmd('!git clone ' .. url) end end)<CR>\27📦  Clone Repository\6g\28:Telescope oldfiles<CR>\23🕐  Recent Files\6r\14:enew<CR>\19📄  New File\6n\30:Telescope find_files<CR>\20🔍  Find File\6f\vbutton\fbuttons\rcallback\0\1\0\2\fpattern\nalpha\rcallback\0\rFileType\24nvim_create_autocmd\0\1\v\0\0K                                                                      �\1  ██████╗ ██╗   ██╗ ██████╗██╗  ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗�\1  ██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔═══██╗██║   ██║██║████╗ ████║�\1  ██████╔╝ ╚████╔╝ ██║     ███████║██║   ██║██║   ██║██║██╔████╔██║�\1  ██╔═══╝   ╚██╔╝  ██║     ██╔══██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║�\1  ██║        ██║   ╚██████╗██║  ██║╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║�\1  ╚═╝        ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝K                                                                      O                🔪 I have to return some videotapes 🔪                K                                                                      \bval\vheader\fsection\1\0\2\afg\f#330000\tbold\2\14PychoRed5\1\0\2\afg\f#660000\tbold\2\14PychoRed4\1\0\2\afg\f#990000\tbold\2\14PychoRed3\1\0\2\afg\f#cc0000\tbold\2\14PychoRed2\1\0\2\afg\f#ff0000\tbold\2\14PychoRed1\16nvim_set_hl\bapi\bvim\1\6\0\0\14PychoRed1\14PychoRed2\14PychoRed3\14PychoRed4\14PychoRed5\27alpha.themes.dashboard\nalpha\frequire\15����\4\0", "config", "alpha-nvim")
time([[Config for alpha-nvim]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
