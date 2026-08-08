# PychoVIM

Pierce & Pierce dress code. Fewer stupid editor defaults.

PychoVIM is an opinionated terminal editor powered by a Neovim 0.12+ engine. The theme is *American Psycho*; the editor still has to work. No blood-drip ASCII art, no lore dump, no broken behavior excused as atmosphere.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/OnurByte/PSYCHOVIM/main/install.sh | bash
```

That command handles the machine, not just `~/.config/nvim`:

- installs missing Git/archive tools, ripgrep, compiler/make, Node/npm and desktop integration on supported Linux package managers
- uses Homebrew dependencies on macOS when available
- installs the stable PychoVIM engine when a compatible engine is missing or too old
- installs the official tree-sitter CLI release
- clones PychoVIM and backs up an existing config
- installs extensions, Mason tools and parsers
- makes PychoVIM the default text editor policy
- opens PychoVIM when setup finishes in an interactive terminal

The default-editor policy sets `EDITOR`, `VISUAL`, `GIT_EDITOR`, Git's editor, and Linux text-file MIME associations. If another program changes them later, PychoVIM quietly takes them back on launch/focus. There is no “restore default editor?” suggestion.

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

`nvim` is installed as a PychoVIM frontend wrapper. The underlying engine path is kept separately so there is no wrapper recursion.

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

Plugin inventory, marketplace, themes and per-plugin settings live in one screen:

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

`<leader>pp` opens it. Settings also links directly into the installed-extension/config view.

### Marketplace source: Dotfyle

The discovery catalog is Dotfyle. PychoVIM talks to Dotfyle's public plugin catalog API rather than doing a generic GitHub repository search.

Reference catalog:

```text
https://dotfyle.com/neovim/configurations/plugins
```

That page itself ranks plugin-heavy configurations; the installable entries in PychoVIM come from the same Dotfyle service's plugin index. Search, categories, trending/top/new ranking and colorschemes use Dotfyle data. GitHub is only used to clone the repository selected from a Dotfyle result.

The Extensions panel exposes:

- **Inventory** — PychoVIM core extensions plus Marketplace installs
- **Discover** — Dotfyle plugin catalog
- **Search** — Dotfyle keyword search
- **Categories** — Dotfyle plugin categories
- **Themes** — Dotfyle `colorscheme` category
- **Trending / Top / New** — Dotfyle ranking modes
- **Plugin config** — enable/disable, load policy and Lazy `opts`

Results show Dotfyle configuration usage, GitHub stars when present, recent install movement and description/category metadata.

Keys:

| Key | Action |
| --- | --- |
| `i` | installed inventory |
| `d` | discover plugins |
| `/` | search current catalog |
| `t` | themes |
| `f` | choose category |
| `1` | trending |
| `2` | top / popular |
| `3` | new |
| `[` / `]` | previous / next page |
| `Enter` | install / configure |
| `c` | extension settings |
| `r` | refresh |
| `u` | run pychoUpdate |
| `s` | open Settings |
| `q` | close |

Marketplace state lives under editor state rather than the Git checkout, so `pychoUpdate` does not erase it.

### Extension settings

Marketplace extensions can be enabled/disabled, changed between startup and `VeryLazy`, removed, and given a JSON `opts` object that is passed to lazy.nvim. Known extensions such as Oil, ToggleTerm, Trouble and Neogit also get PychoVIM defaults.

PychoVIM does not invent arbitrary executable Lua for an unknown third-party plugin. If a plugin needs custom Lua beyond ordinary `opts`, that remains plugin-specific configuration rather than guessed code.

Core extension switches live in `⚙ PychoVIM Settings`; the Settings panel and Extensions inventory are two views over the same extension policy rather than separate plugin managers.

### Themes

Themes are first-class Marketplace entries sourced from Dotfyle's `colorscheme` category. Install one, then configure/activate it from the same Extensions screen. Known themes have their `:colorscheme` name filled automatically; unknown themes ask for the command name once.

PychoVIM's Mask / After Hours highlight layer stays on top, so changing the base theme does not erase the editor's visual identity.

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
- installed extension settings → opens the Extensions/config inventory

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

The dashboard has one fixed-width navigation column. File actions come first, editor management next, then the project-specific features:

```text
  Find File
  Recent Files
  New File
󰏗  Extensions
  Settings
󰚰  Update
󰌾  Dorsia
󰌪  Business Card
  PychoClose
```

No separate Marketplace/Inventory entries compete for the same job.

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

Every push to `main` validates shell syntax, the Marketplace source contract, parses every Lua file, syncs the extension set and starts PychoVIM headlessly.

MIT. Unofficial fan project. Not affiliated with Bret Easton Ellis, Lionsgate, or the film's rights holders.
