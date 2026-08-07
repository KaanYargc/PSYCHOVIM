# PSYCHOVIM

A dark, opinionated Neovim distribution inspired by the immaculate corporate surface, status anxiety, ritual, repetition, and slowly slipping reality of *American Psycho*.

PSYCHOVIM is not meant to be a red-and-black horror skin. It should look controlled first, feel strange second, and stay useful the entire time.

## Install

Requirements: Neovim **0.12+**, Git, a C compiler, `curl`, `tar`. A Nerd Font and `ripgrep` are recommended.

```bash
curl -fsSL https://raw.githubusercontent.com/OnurByte/PSYCHOVIM/main/install.sh | bash
```

The installer backs up an existing Neovim config, installs PSYCHOVIM to `${XDG_CONFIG_HOME:-~/.config}/nvim`, and creates the launcher:

```bash
pycho
pycho path/to/file.lua
pycho path/to/project
```

If cloning fails, the previous config is restored automatically.

## The PSYCHOVIM layer

### SmartClose

`Ctrl+C` or `Ctrl+D` opens a centered exit dialog from normal, insert, visual, or terminal mode:

1. Save all & quit
2. Quit without saving
3. Cancel

The popup shows how many modified buffers are still open.

### SmartSave

`Ctrl+S` saves the current file from normal, insert, or visual mode. An unnamed buffer gets a Save As prompt instead of an error.

Inside terminal mode, `Ctrl+S` is intercepted with an explanation instead of being allowed to trigger Unix terminal flow control and making the screen appear frozen.

### SmartBufferClose

`<leader>bd` closes a clean buffer immediately. If it contains unsaved changes, PSYCHOVIM asks:

1. Save & close
2. Close without saving
3. Cancel

The global Neovim `confirm` option is also enabled, so plain commands such as `:q`, `:edit`, and `:bdelete` ask what to do with unsaved work instead of failing with an opaque error.

### Familiar shortcuts

PSYCHOVIM deliberately smooths a few Vim defaults that are surprising to people coming from other editors:

| Key | PSYCHOVIM behavior |
| --- | --- |
| `Ctrl+C` / `Ctrl+D` | SmartClose |
| `Ctrl+S` | SmartSave |
| `Ctrl+Z` | Undo instead of suspending the editor |
| `Ctrl+Shift+Z` | Redo where the terminal can distinguish the key |
| `Ctrl+F` | Fuzzy search inside the current file |
| `Ctrl+P` | Find files |
| `Ctrl+A` | Select all |
| Visual `p` | Paste without destroying the yank register |
| Terminal `Esc` | Return to terminal-normal mode |

Native suspension remains available with `:suspend` or `:stop`.

## American Psycho identity

### Mask of Sanity

The default palette is restrained: near-black surfaces, off-white typography, muted corporate borders, and blood red only where it means something.

```vim
:Mask
:AfterHours
```

Or toggle with `<leader>pm`.

`Mask` restores the controlled corporate surface. `AfterHours` lets the red accent spread into the interface without turning the editor into a generic horror theme.

### Pierce & Pierce Business Card

```vim
:BusinessCard
```

The card shows the current Git account/branch, office path, loaded plugin inventory, and active LSP count in an intentionally over-serious Pierce & Pierce presentation.

Shortcut: `<leader>pb`.

### Morning Routine

```vim
:MorningRoutine
```

Runs a compact environment inspection for Neovim, Git, ripgrep, compiler availability, plugin inventory, and the current mask state.

Shortcut: `<leader>pr`.

### Dorsia

Dorsia is PSYCHOVIM's project session manager.

```vim
:DorsiaSave
:Dorsia
:DorsiaForget
```

- `:DorsiaSave` reserves the current project layout.
- `:Dorsia` lists saved reservations and restores one.
- `:DorsiaForget` cancels the reservation for the current project.
- Real file/project sessions are quietly refreshed on exit; an empty `pycho` launch does not create junk reservations.
- Dorsia refuses to load another session while unsaved buffers are present.

Shortcuts:

| Key | Action |
| --- | --- |
| `<leader>pd` | Open Dorsia |
| `<leader>ps` | Save reservation |
| `<leader>px` | Forget reservation |

## Development environment

PSYCHOVIM ships as a practical daily config, not only a themed dashboard.

- `lazy.nvim` plugin management
- Neovim native LSP configuration
- Mason-managed language servers
- Blink completion
- Conform format-on-save
- Telescope fuzzy finding
- nvim-tree navigation
- nvim-treesitter syntax parsing
- gitsigns
- which-key
- Snacks dashboard, picker, and input UI
- Catppuccin as the syntax-color foundation with PSYCHOVIM highlight overrides

Default language servers:

- `lua_ls`
- `pyright`
- `ts_ls`
- `gopls`
- `rust_analyzer`

Default formatters:

- Lua → `stylua`
- Python → `ruff_format`
- JS / TS / JSON / Markdown → `prettierd`, then `prettier`

Manual format: `<leader>cf`.

## Main keybindings

Leader is `Space`.

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Focus file explorer |
| `<leader>cf` | Format file |
| `<leader>ca` | LSP code action |
| `<leader>rn` | LSP rename |
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover documentation |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>dd` | Diagnostic popup |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<C-h/j/k/l>` | Navigate windows |
| `<leader>sv` / `<leader>sh` | Split window |
| `<leader>tt` | Terminal |
| `jk` / `kj` | Leave insert mode |

## Structure

```text
.
├── .github/workflows/smoke.yml
├── init.lua
├── install.sh
└── lua
    ├── plugins.lua
    └── psychovim
        ├── autocmds.lua
        ├── business_card.lua
        ├── dorsia.lua
        ├── features.lua
        ├── keymaps.lua
        ├── lazy.lua
        ├── options.lua
        ├── plugin_overrides.lua
        ├── routine.lua
        ├── smart_actions.lua
        ├── smart_close.lua
        └── theme.lua
```

## Health and troubleshooting

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
```

If icons look wrong, use a Nerd Font. If live grep is unavailable, install `ripgrep`.

## CI

Every push to `main` runs a GitHub Actions smoke test that installs stable Neovim, parses every Lua file, installs the plugin set, starts PSYCHOVIM headlessly, and verifies the custom Smart/Mask/Dorsia modules can load.

## Philosophy

The joke should never be the only feature.

PSYCHOVIM uses the source material's obsession with surfaces, routine, status, cataloguing, and unstable identity as interface rules: the UI is restrained, the named systems perform real work, and irreversible actions are explicit.

MIT. PSYCHOVIM is an unofficial fan-made configuration and is not affiliated with the creators or rights holders of *American Psycho*.
