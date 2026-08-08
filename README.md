# PychoVIM

Pierce & Pierce dress code. Fewer stupid editor defaults.

PychoVIM is an opinionated terminal editor built on the Neovim 0.12+ engine. The theme is *American Psycho*; the editor still has to work. No blood-drip ASCII art, no lore dump, no broken behavior excused as atmosphere.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/OnurByte/PSYCHOVIM/main/install.sh | bash
```

That command handles the machine, not just `~/.config/nvim`:

- installs missing Git/archive tools, ripgrep, compiler/make, Node/npm and desktop integration on supported Linux package managers
- uses Homebrew dependencies on macOS when available
- installs the stable PychoVIM engine when Neovim 0.12+ is missing or too old
- installs the official tree-sitter CLI release
- clones PychoVIM and backs up an existing config
- installs extensions, Mason tools and parsers
- makes PychoVIM the default text editor policy
- opens PychoVIM when setup finishes in an interactive terminal

The default-editor policy sets `EDITOR`, `VISUAL`, `GIT_EDITOR`, Git's editor, and Linux text-file MIME associations. If another program changes them later, PychoVIM quietly takes them back on launch/focus. It does not ask for permission every morning.

## One frontend

These are intentionally the same thing:

```bash
pycho
nvim
pycho .
nvim .
pycho main.go
nvim main.go
```

`nvim` is installed as a PychoVIM frontend wrapper. The real engine path is kept separately so there is no wrapper recursion.

Normal launches are quiet. You do **not** get an updater report in the shell before the editor appears.

## pychoUpdater

Every normal launch opens PychoVIM first. Then `pychoUpdater` runs in the background and reports inside the editor:

```text
pychoUpdater
Checking updates...
Downloading plugin updates...
Updating LSP, formatter and linter tools...
Updating Treesitter parsers...
PychoVIM is up to date.
```

Manual update names are equivalent:

```bash
pycho update
pychoUpdate
pychoUpdater
```

Inside PychoVIM:

```vim
:PychoUpdate
:PychoUpdater
```

If a config update replaces the updater itself, the updater reloads its new version before continuing. Update state is locked so two PychoVIM instances do not run the same maintenance pass over each other.

Emergency no-network launch:

```bash
PSYCHOVIM_NO_AUTOUPDATE=1 pycho
```

## 󰏗 Extensions

`Plugin Inventory` and `Marketplace` are one screen now:

```bash
pycho extensions
pycho marketplace
```

or:

```vim
:PychoExtensions
:PychoMarketplace
:PychoInventory
```

`<leader>pp` opens it.

The screen has three jobs:

- **Installed** — PychoVIM core extensions plus Marketplace installs
- **Search** — live GitHub repository search for `topic:neovim-plugin`
- **Themes** — live GitHub search for `topic:neovim-colorscheme`

GitHub results are sorted by stars and include the repository description. Public search works without authentication. `GITHUB_TOKEN` or `GH_TOKEN` is used automatically when present for a friendlier API rate limit.

Keys:

| Key | Action |
| --- | --- |
| `i` | installed inventory |
| `/` | search extensions |
| `t` | search themes |
| `Enter` | install / configure |
| `c` | extension settings |
| `r` | refresh current search |
| `u` | run pychoUpdate |
| `s` | open Settings |
| `q` | close |

Marketplace state lives under editor state rather than the Git checkout, so `pychoUpdate` does not erase it.

### Extension settings

Marketplace extensions can be enabled/disabled, changed between startup and `VeryLazy`, removed, and given a JSON `opts` object that is passed to lazy.nvim. Known extensions such as Oil, ToggleTerm, Trouble and Neogit also get sane PychoVIM defaults.

Arbitrary GitHub code does **not** get an invented Lua `config=function()` from PychoVIM. If a plugin needs custom executable Lua, that remains plugin-specific code rather than fake automatic configuration.

Core extension switches still live in `⚙ PychoVIM Settings`.

### Themes

Themes are first-class Marketplace entries. Search with `t`, install one, then configure/activate it from Installed. Known themes have their `:colorscheme` name filled automatically; unknown themes ask for the command name once.

PychoVIM's Mask / After Hours highlight layer stays on top, so changing the base theme does not turn the editor into a random theme pack.

## ⚙ Settings

```bash
pycho settings
```

or:

```vim
:PychoSettings
```

`<leader>ps` opens the same panel. The statusline keeps `` Settings and `󰏗` Extensions next to each other.

Settings are persistent and survive updates.

### Editor

- line / relative numbers
- indent width 2 / 4 / 8
- spaces vs tabs
- wrap
- mouse
- system clipboard
- persistent undo
- smart-case search
- scroll margin

### UI

- SANITY / AFTER HOURS
- cursor line
- invisible characters
- popup border
- notifications
- diagnostics / virtual text
- statusline
- buffer tabs

### Tooling

- blink.cmp completion
- LSP / Mason
- Lua / Python / TypeScript-JS / Go / Rust LSP toggles
- Conform formatting + format on save
- nvim-lint + lint on save
- Treesitter
- Telescope
- file tree
- GitSigns
- indent guides
- TODO comments
- autopairs
- surround
- which-key
- installed extension settings → opens the Extensions inventory

Python linting uses Ruff. JS/TS uses `eslint_d` only when an ESLint config actually exists above the current file.

### Terminal

- terminal line numbers
- terminal sign column
- start in insert mode

### Pycho patches

| Patch | Default |
| --- | --- |
| `Ctrl+C` / `Ctrl+D` → **PychoClose** | ON |
| `Ctrl+S` → **PychoSave** | ON |
| `Ctrl+Z` → undo | ON |
| `Ctrl+F/P/A` familiar shortcuts | ON |
| visual paste keeps yank register | ON |
| dirty-exit confirmation | ON |
| terminal `Esc` leaves terminal insert | ON |

Yes, `Ctrl+D` normally scrolls half a page. This is not a neutral config.

## Dashboard

The dashboard uses one icon column and one navigation order:

```text
󰏗  Extensions
   Settings
󰚰  Update
󰈞  New File
󰈔  Find File
󰋚  Recent Files
󰌾  Dorsia
󰌪  Business Card
󰍃  PychoClose
```

No separate Marketplace/Inventory entries competing for the same job.

## Dorsia

Project sessions, because apparently getting a table is easier than rebuilding six splits every morning.

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

Current branch, cwd, loaded extension count and active LSP count presented with an unreasonable amount of corporate dignity.

## Morning Routine

```bash
pycho doctor
```

Checks the PychoVIM core, Git, curl, archives, ripgrep, compiler, Node/npm, tree-sitter CLI, extensions, updater policy and Mask.

## Toolchain

Mason manages the tools PychoVIM calls by default:

- Stylua
- Ruff
- Prettierd / Prettier
- ESLint_d
- Lua Language Server
- Pyright
- TypeScript Language Server
- `gopls` when Go exists
- `rust-analyzer` when a Rust toolchain exists

Language runtimes are still language runtimes. PychoVIM does not quietly install every SDK on earth.

## Useful keys

Leader is `Space`.

| Key | Action |
| --- | --- |
| `<leader>ps` | Settings |
| `<leader>pp` | Extensions |
| `<leader>pu` | pychoUpdater |
| `<leader>pb` | Business Card |
| `<leader>pm` | Mask / After Hours |
| `<leader>pr` | Morning Routine |
| `<leader>pd` | Dorsia |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>e` | File tree |
| `<leader>cf` | Format |
| `<leader>cl` | Lint |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename |
| `gd` | Definition |
| `gr` | References |
| `K` | Hover docs |
| `<C-h/j/k/l>` | Windows |
| `<leader>tt` | Terminal |
| `jk` / `kj` | Escape insert mode |

## Something broke

```bash
pycho status
PSYCHOVIM_NO_AUTOUPDATE=1 pycho
pycho update
```

Inside:

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
:PychoExtensions
:PychoParsers
```

Maintenance logs live under `~/.cache/psychovim/`.

Every push to `main` validates shell syntax, parses every Lua file, syncs the extension set and starts PychoVIM headlessly.

MIT. Unofficial fan project. Not affiliated with Bret Easton Ellis, Lionsgate, or the film's rights holders.
