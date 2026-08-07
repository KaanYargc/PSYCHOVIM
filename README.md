# PSYCHOVIM

Neovim with a Pierce & Pierce dress code and fewer stupid exits.

It is *American Psycho* themed, but it is still an editor. No blood-drip ASCII art. No lore dump. The surface stays clean; the bad decisions are configurable.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/OnurByte/PSYCHOVIM/main/install.sh | bash
```

Then:

```bash
pycho
pycho .
pycho main.go
```

Git, `curl`, `tar`, and a C compiler are required. `ripgrep` and a Nerd Font are worth having.

Neovim itself is optional. If there is no usable Neovim 0.12+, the installer puts the official stable build under `~/.local/share/psychovim/neovim`. No `sudo` and no package-manager surgery.

Existing `~/.config/nvim` is timestamped before PSYCHOVIM moves in. Plugin sync happens during setup with low concurrency because some Wi-Fi connections apparently consider TLS a suggestion.

## `pycho`

`pycho` is the launcher and the maintenance command.

```bash
pycho                 # open Neovim
pycho .               # open a project
pycho update          # config + plugins + Treesitter parsers
pycho settings        # boot directly into the settings panel
pycho status          # branch / commit / Neovim version
pycho doctor          # Morning Routine
pycho parsers         # parser sync only
pycho help
```

`pycho update` only fast-forwards the PSYCHOVIM checkout. If you edited the config itself, it stops instead of eating your changes. Dirty managed plugin checkouts are moved into `~/.cache/psychovim/dirty-plugins/` before reinstalling.

Settings live outside the Git checkout in Neovim's state directory, so an update does not reset them.

### Old install?

If your `pycho` predates the command router, do this once:

```bash
git -C ~/.config/nvim pull --ff-only
bash ~/.config/nvim/install.sh --launcher-only
```

After that, `pycho update` handles it.

## Pycho patches

These are defaults, not commandments. Open them with `pycho settings`, `:PychoSettings`, or `<leader>ps`.

| Patch | Default |
| --- | --- |
| `Ctrl+C` / `Ctrl+D` -> **PychoClose** | ON |
| `Ctrl+S` -> **PychoSave** | ON |
| `Ctrl+Z` -> undo instead of shell suspend | ON |
| `Ctrl+F/P/A` -> find / files / select all | ON |
| Visual `p` keeps the yank register | ON |
| dirty-exit confirmation | ON |
| terminal `Esc` leaves terminal insert mode | ON |

Turn one off and the corresponding native Vim behavior is allowed through again.

`<leader>bd` is **PychoBufferClose**: clean buffers close immediately; dirty buffers get save / discard / cancel.

`<leader>Q` always opens PychoClose even if the `Ctrl+C/D` patch is disabled.

## Pycho Settings

The settings panel is deliberately closer to an old workstation utility than a plugin menu.

```vim
:PychoSettings
```

It contains two groups:

- **WORKSTATION** — Mask, format-on-save, relative numbers, diagnostics, cursor line, plugin update checker.
- **PYCHO PATCHES** — the opinionated Vim fixes listed above.

Use `j/k` or arrows, `Enter`/`Space` to change a value, `r` to restore defaults, `q`/`Esc` to leave. Changes are written immediately.

The normal palette is **SANITY**. **AFTER HOURS** is the same office after everybody useful has gone home.

## PychoClose

`Ctrl+C` and `Ctrl+D` open this from normal, insert, visual, or terminal mode:

```text
 PychoClose

 Dirty buffers: 2

  1  Save all & exit
  2  Exit dirty
  3  Cancel
```

`1/2/3`, arrows or `j/k`, `Enter`, `Esc`.

Yes, `Ctrl+D` normally scrolls half a page. This is not a neutral config.

## Dorsia

Project sessions, because apparently getting a table is easier than rebuilding six splits every morning.

```vim
:DorsiaSave
:Dorsia
:DorsiaForget
```

Real project sessions refresh on exit. Empty `pycho` launches do not leave junk reservations, and Dorsia refuses to seat another project over dirty buffers.

Keys: `<leader>pd`, `<leader>pS`, `<leader>px`.

## Business Card

```vim
:BusinessCard
```

Current Git branch, cwd, loaded plugin count and active LSP count presented with an unreasonable amount of corporate dignity.

`<leader>pb`.

No watermark. Bone coloring depends on your terminal.

## Morning Routine

```vim
:MorningRoutine
```

Checks Neovim, Git, ripgrep, compiler availability, plugin state and the current mask.

`<leader>pr` or `pycho doctor`.

## Stack

- `lazy.nvim` — plugins, limited to two concurrent network jobs
- native `vim.lsp` + Mason — language servers
- `blink.cmp` — completion
- `conform.nvim` — formatting
- Telescope — finding things
- nvim-tree — files
- nvim-treesitter — parsing/highlighting
- gitsigns — Git gutter
- Snacks — dashboard, picker and input UI
- Catppuccin — syntax palette underneath PSYCHOVIM overrides

Default LSPs: `lua_ls`, `pyright`, `ts_ls`, `gopls`, `rust_analyzer`.

Default formatters: Lua -> `stylua`; Python -> `ruff_format`; JS/TS/JSON/Markdown -> `prettierd`, then `prettier`.

Manual format: `<leader>cf`.

## Useful keys

Leader is `Space`.

| Key | Action |
| --- | --- |
| `<leader>ps` | Pycho Settings |
| `<leader>pb` | Business Card |
| `<leader>pm` | Mask / After Hours |
| `<leader>pr` | Morning Routine |
| `<leader>pd` | Dorsia |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>e` | File tree |
| `<leader>cf` | Format |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `gd` | Definition |
| `gr` | References |
| `K` | Hover docs |
| `[d` / `]d` | Diagnostics |
| `<Tab>` / `<S-Tab>` | Buffers |
| `<C-h/j/k/l>` | Windows |
| `<leader>tt` | Terminal |
| `jk` / `kj` | Escape insert mode |

## Something broke

```bash
pycho status
pycho update
```

Inside Neovim:

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
:PychoParsers
```

Plugin logs live under `~/.cache/psychovim/`. Broken icons usually mean no Nerd Font. No live grep usually means no `ripgrep`.

## Repo

```text
bin/pycho             launcher / updater
init.lua
install.sh
lua/psychovim/        core behavior
lua/plugins.lua       plugin specs
.github/workflows/    smoke test
```

Every push to `main` checks shell syntax, parses every Lua file, syncs plugins and starts PSYCHOVIM headlessly.

MIT. Unofficial fan project. Not affiliated with Bret Easton Ellis, Lionsgate, or the film's rights holders.
