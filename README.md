# PSYCHOVIM

Neovim with a Pierce & Pierce dress code and fewer stupid defaults.

The theme is *American Psycho*. The editor still has to work. No blood-drip ASCII art. No lore dump. No broken keymap excused as atmosphere.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/OnurByte/PSYCHOVIM/main/install.sh | bash
```

The installer handles the boring part:

- installs missing system dependencies on `apt`, `dnf`, `pacman`, `zypper`, `apk`, or Homebrew
- installs Neovim 0.12+ if the machine does not already have a supported build
- installs the tree-sitter CLI
- installs plugins
- installs Mason-managed LSP / formatter / linter tools
- registers PSYCHOVIM as the default text editor where the platform allows it
- makes `nvim` and `pycho` use the same PSYCHOVIM frontend
- opens PSYCHOVIM when setup finishes

System packages can require `sudo`. PSYCHOVIM, its managed Neovim, tree-sitter and Mason tools live under the user account.

Existing `~/.config/nvim` is timestamped before PSYCHOVIM takes the seat.

## `pycho` and `nvim`

After installation these mean the same editor:

```bash
pycho
nvim

pycho .
nvim .

pycho main.go
nvim main.go
```

Both go through `pychoUpdater` before Neovim starts.

```text
pychoUpdater // CHECK
config       current
plugins      ok
tools        ok
parsers      ok
```

The result is also shown inside Neovim as a `pychoUpdater` notification.

Manual update commands:

```bash
pycho update
pychoUpdate
pychoUpdater
```

Inside Neovim:

```vim
:PychoUpdate
:PychoUpdater
```

Config updates are fast-forward only. Real edits inside the managed checkout are not overwritten. Runtime state such as `lazy-lock.json` lives outside the repo; an old stray `lazy-lock.json` is migrated automatically instead of making the updater scream `config dirty` forever.

Emergency offline boot:

```bash
PSYCHOVIM_NO_AUTOUPDATE=1 pycho
```

## The two buttons that matter

The statusline keeps these on the right:

```text
⚙   󰏗
```

`⚙` opens **Pycho Settings**. `󰏗` opens **Pycho Marketplace**. If mouse support is enabled, both are clickable.

Dashboard shortcuts:

```text
s   ⚙ Settings
p   󰏗 Marketplace
```

Keys:

```text
Space p s   Settings
Space p p   Marketplace
Space p u   pychoUpdater
```

## ⚙ Pycho Settings

```bash
pycho settings
```

or:

```vim
:PychoSettings
```

`j/k` or arrows move. `Enter` / `Space` changes the selected setting. `m` jumps to Marketplace. `r` restores defaults. `q` leaves.

Settings are stored in Neovim state, not in the Git checkout, so `pychoUpdate` does not eat them.

### SYSTEM

PSYCHOVIM installs itself as the shell editor (`EDITOR` / `VISUAL`), Git editor, and on Linux the `text/plain` desktop handler through `xdg-mime`.

If another program changes that later, Settings stops being subtle:

```text
⚠ MAKE PYCHO DEFAULT TEXT EDITOR
```

Press Enter on it to restore the association.

You can also do it from the shell:

```bash
pycho default-editor
```

### EDITOR

- line numbers
- relative numbers
- tab / indent width: 2 / 4 / 8
- spaces vs tabs
- wrap
- mouse
- system clipboard
- persistent undo
- smart-case search
- scroll margin

### UI

- **SANITY / AFTER HOURS** palette
- cursor line
- invisible characters
- popup borders
- notifications
- diagnostics
- diagnostic virtual text
- statusline
- buffer tabs

### TOOLING

- `blink.cmp` completion
- native LSP + Mason
- Lua LSP
- Python LSP
- TypeScript / JavaScript LSP
- Go LSP
- Rust LSP
- Conform formatting
- format on save
- `nvim-lint`
- lint on save
- Treesitter
- Telescope
- file tree
- GitSigns
- indent guides
- TODO comments
- autopairs
- surround
- which-key

Python linting uses Ruff. JavaScript / TypeScript uses `eslint_d` only when an ESLint config actually exists in the project. Manual lint: `<leader>cl`.

Mason installs Stylua, Ruff, Prettierd, Prettier, ESLint_d, Lua Language Server, Pyright and TypeScript Language Server. Go and Rust servers are included when those runtimes exist.

### AUTOMATION

- yank highlight
- trim trailing whitespace on save
- restore last cursor position
- optional startup deadpan

### TERMINAL

- terminal line numbers
- terminal sign column
- start terminal in insert mode

### PYCHO PATCHES

These are features, not accidents.

| Patch | Default |
| --- | --- |
| `Ctrl+C` / `Ctrl+D` -> **PychoClose** | ON |
| `Ctrl+S` -> **PychoSave** | ON |
| `Ctrl+Z` -> undo | ON |
| `Ctrl+F/P/A` -> familiar shortcuts | ON |
| Visual `p` keeps the yank register | ON |
| dirty-exit confirmation | ON |
| terminal `Esc` leaves terminal insert mode | ON |

Turn one off and native Neovim gets the key back.

### UPDATES

- config update on launch
- plugin / Mason tool update on launch
- parser update on launch
- Lazy background checker

Every normal `pycho` **and** `nvim` launch runs the explicit updater first. Lazy's checker remains a separate background inventory check while the interactive editor is open.

## 󰏗 Pycho Marketplace

```bash
pycho marketplace
```

or:

```vim
:PychoMarketplace
```

The built-in catalog currently includes Oil, ToggleTerm, Trouble, Zen Mode, Neogit and Undotree.

Select one and press Enter to install/remove it. Downloads happen immediately; activation happens on the next launch. Removed plugins disappear from the spec and Lazy cleans them normally.

Press `a` to add any GitHub plugin using `owner/repo` form. Marketplace state also lives outside the managed config checkout.

This is not trying to clone VS Code's entire extension website into a terminal. It is trying to remove the part where installing one Neovim plugin requires remembering which Lua file owns reality.

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

`<leader>bd` is **PychoBufferClose**. `<leader>Q` always opens PychoClose.

## Dorsia

Project sessions, because getting a table is apparently easier than rebuilding six splits every morning.

```vim
:DorsiaSave
:Dorsia
:DorsiaForget
```

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

Checks Neovim, Git, curl, archive tools, ripgrep, compiler, Node/npm, tree-sitter, plugins, update state and the current mask.

## Useful keys

Leader is `Space`.

| Key | Action |
| --- | --- |
| `<leader>ps` | ⚙ Settings |
| `<leader>pp` | 󰏗 Marketplace |
| `<leader>pu` | pychoUpdater |
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
| `<leader>cl` | Lint current file |
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
pychoUpdate
PSYCHOVIM_NO_AUTOUPDATE=1 pycho
```

Inside Neovim:

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
:PychoParsers
:PychoSettings
:PychoMarketplace
```

Logs live under `~/.cache/psychovim/`.

## Stack

- `lazy.nvim`
- native `vim.lsp`
- `mason-org/mason.nvim`
- `mason-tool-installer.nvim`
- `blink.cmp`
- `conform.nvim`
- `nvim-lint`
- Telescope
- nvim-tree
- nvim-treesitter
- gitsigns
- Snacks
- Catppuccin underneath the PSYCHOVIM highlight layer

Plugin network work is deliberately low-concurrency. The previous "clone half of GitHub at once and hope TLS enjoys it" policy has been retired.

MIT. Unofficial fan project. Not affiliated with Bret Easton Ellis, Lionsgate, or the film's rights holders.
