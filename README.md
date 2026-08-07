# PSYCHOVIM

Neovim with a Pierce & Pierce dress code and fewer stupid defaults.

The theme is *American Psycho*. The editor is still supposed to work. No blood-drip ASCII art, no lore dump, no pretending a broken keymap is atmosphere.

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

The installer handles more than the config. On supported Linux package managers (`apt`, `dnf`, `pacman`, `zypper`, `apk`) it installs missing Git/archive tools, ripgrep, a compiler toolchain, Node/npm and related runtime dependencies. Homebrew is used on macOS when available.

Neovim 0.12+ does not need to exist beforehand. If it is missing or too old, PSYCHOVIM pulls the official stable build into `~/.local/share/psychovim/neovim`. The tree-sitter CLI is also installed from its official release binary into the user account.

After the plugins land, Mason installs the editor tools the config actually calls: Stylua, Ruff, Prettierd, Prettier, Lua Language Server, Pyright and TypeScript Language Server. `gopls` and `rust-analyzer` join the list when a Go or Rust toolchain already exists.

System packages may require `sudo`. Neovim, tree-sitter, PSYCHOVIM, Mason tools and the launcher themselves stay under your user directories.

Existing `~/.config/nvim` gets timestamped before PSYCHOVIM moves in. Network work runs with deliberately low concurrency.

## `pycho`

`pycho` is both the launcher and the maintenance command.

```bash
pycho                 # update check, then open Neovim
pycho .               # same, open this project
pycho update          # force config + plugins + tools + parsers now
pycho settings        # update check, then open Pycho Settings
pycho status          # install / Git / auto-update state
pycho doctor          # update check, then Morning Routine
pycho parsers         # parser sync only
pycho help
```

### Updates happen before launch

By default every normal `pycho` launch does the maintenance pass before opening the editor:

```text
PSYCHOVIM // CHECK
config       current
plugins      ok
tools        ok
parsers      ok
```

Config updates are fast-forward only. If you actually edited the PSYCHOVIM checkout, the automatic config update leaves it alone instead of eating your work. Plugin/tool/parser or network trouble does not prevent Neovim from opening; logs go under `~/.cache/psychovim/`.

There are three policy switches in Pycho Settings: config updates, plugin/toolchain updates and parser updates. For an emergency offline boot:

```bash
PSYCHOVIM_NO_AUTOUPDATE=1 pycho
```

Lazy also keeps its own background checker enabled on interactive launches. The explicit pre-launch maintenance pass is the thing that actually syncs updates every time; maintenance/headless runs suppress the background checker so the two do not race. Its lockfile lives in Neovim state rather than the Git checkout, so plugin updates do not make the config repo dirty.

### Old install?

If your `pycho` predates the command router, do this once:

```bash
git -C ~/.config/nvim pull --ff-only
bash ~/.config/nvim/install.sh --launcher-only
```

After that, `pycho update` updates the updater too.

## Pycho Settings

```bash
pycho settings
```

or inside Neovim:

```vim
:PychoSettings
```

`<leader>ps` opens the same panel.

It is a scrollable workstation control panel, not a fake preferences screen. `j/k` or arrows move, `Enter`/`Space` changes a value, `r` resets defaults, `q`/`Esc` leaves. Settings are written immediately to Neovim state and survive `pycho update`.

### EDITOR

- line numbers and relative numbers
- tab/indent width: 2 / 4 / 8
- spaces vs tabs
- line wrap
- mouse
- system clipboard
- persistent undo
- smart-case search
- scroll margin

### UI

- **SANITY / AFTER HOURS** palette
- cursor line
- invisible characters
- global popup border: rounded / single / double / bold
- notification UI
- diagnostics and diagnostic virtual text
- statusline
- buffer tabs

### TOOLING

These switches actually control the plugin specs after restart:

- `blink.cmp` completion
- native LSP + Mason
- Conform formatter engine
- format on save
- Treesitter
- Telescope
- file tree
- GitSigns
- indent guides
- TODO comments
- autopairs
- surround
- which-key

Mason's managed formatter/LSP binaries follow the LSP and formatter switches. Disabling both means the `tools` update lane has nothing to do.

### AUTOMATION

- yank highlight
- trim trailing whitespace on save
- restore last cursor position
- optional startup deadpan

### PYCHO PATCHES

The opinionated fixes are settings too:

| Patch | Default |
| --- | --- |
| `Ctrl+C` / `Ctrl+D` -> **PychoClose** | ON |
| `Ctrl+S` -> **PychoSave** | ON |
| `Ctrl+Z` -> undo instead of shell suspend | ON |
| `Ctrl+F/P/A` -> find / files / select all | ON |
| Visual `p` keeps the yank register | ON |
| dirty-exit confirmation | ON |
| terminal `Esc` leaves terminal insert mode | ON |

Turn one off and the native behavior is allowed through again.

`<leader>bd` is **PychoBufferClose**: clean buffers close immediately; dirty buffers get save / discard / cancel. `<leader>Q` always opens PychoClose.

### UPDATES

- config update on launch
- plugin + Mason toolchain update on launch
- parser update on launch
- Lazy background checker on interactive launches

## PychoClose

`Ctrl+C` and `Ctrl+D` open this from normal, insert, visual or terminal mode:

```text
 PychoClose

 Dirty buffers: 2

  1  Save all & exit
  2  Exit dirty
  3  Cancel
```

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

## Morning Routine

```bash
pycho doctor
```

Checks Neovim, Git, curl, archive tools, ripgrep, compiler, Node/npm, tree-sitter CLI, plugins, auto-update state and the current mask.

## Stack

- `lazy.nvim` — plugins, limited to two concurrent network jobs
- native `vim.lsp` + `mason-org/mason.nvim` — language servers
- `mason-tool-installer.nvim` — managed LSP/formatter binaries
- `blink.cmp` — completion
- `conform.nvim` — formatting
- Telescope — finding things
- nvim-tree — files
- nvim-treesitter — parsing/highlighting
- gitsigns — Git gutter
- Snacks — dashboard, picker and input UI
- Catppuccin — syntax palette underneath PSYCHOVIM overrides

Default LSP targets are Lua, Python and TypeScript. Go and Rust are enabled when their language toolchains exist.

Formatter map: Lua -> `stylua`; Python -> `ruff_format`; JS/TS/JSON/Markdown -> `prettierd`, then `prettier`.

Language runtimes are still language runtimes: a Go project needs Go, Rust work needs a Rust toolchain, etc. PSYCHOVIM installs editor infrastructure; it does not quietly turn your machine into every SDK known to man.

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
PSYCHOVIM_NO_AUTOUPDATE=1 pycho
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

Maintenance logs live under `~/.cache/psychovim/`.

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
