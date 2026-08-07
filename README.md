# PSYCHOVIM 🔪

A dark, opinionated Neovim distribution inspired by the obsessive visual style of *American Psycho* — rebuilt as a practical daily development environment instead of a theme-only config.

> "I have to return some videotapes."

## What changed in v1

PSYCHOVIM now targets modern Neovim and includes:

- `lazy.nvim` plugin management
- Neovim 0.12 native LSP configuration
- Mason-managed language servers
- Blink completion
- format-on-save with Conform
- Telescope fuzzy finding
- nvim-tree file navigation
- current nvim-treesitter API
- Git signs and diagnostics
- which-key discovery
- Catppuccin Mocha with the PSYCHOVIM black/red palette
- a custom Snacks dashboard
- **SmartClose**, a built-in save/quit popup on `Ctrl+C` and `Ctrl+D`
- one-command installer with automatic config backup
- the `pycho` launcher command
- modular options, keymaps, autocmds, and plugin configuration

## Requirements

- Neovim **0.12+**
- Git
- a C compiler (required by Treesitter parsers)
- `curl` and `tar`
- a Nerd Font is recommended for icons
- `ripgrep` is recommended for Telescope live grep

## Installation

### One command

Install PSYCHOVIM with:

```bash
curl -fsSL https://raw.githubusercontent.com/OnurByte/PSYCHOVIM/main/install.sh | bash
```

The installer:

- checks that Git is available
- warns if Neovim is missing or older than 0.12
- backs up an existing config to `~/.config/nvim.backup-YYYYMMDD-HHMMSS`
- clones PSYCHOVIM to `${XDG_CONFIG_HOME:-~/.config}/nvim`
- installs a `pycho` launcher under `~/.local/bin`
- adds `~/.local/bin` to Bash/Zsh PATH when needed
- restores the previous Neovim config automatically if cloning fails
- leaves system packages alone instead of silently changing your machine

After installation, launch PSYCHOVIM with:

```bash
pycho
```

You can also open files and directories directly:

```bash
pycho app.lua
pycho .
```

If the installer had to add `~/.local/bin` to PATH, open a new terminal or source your shell config before running `pycho`.

### Manual install

Back up an existing Neovim config first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

Clone PSYCHOVIM:

```bash
git clone https://github.com/OnurByte/PSYCHOVIM.git ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

`lazy.nvim` bootstraps itself on first launch. Treesitter parsers and configured LSP servers are then installed through their respective managers.

## SmartClose

Leaving Vim should not require remembering `:wqa`, but it also should not throw away work by accident.

Press `Ctrl+C` or `Ctrl+D` from normal, insert, visual, or terminal mode to open **SmartClose** in a centered popup.

SmartClose shows the number of modified buffers and offers:

1. **Save all & quit** — writes all writable buffers, then exits.
2. **Quit without saving** — exits immediately with `qa!`.
3. **Cancel** — returns to the editor.

Use `1/2/3`, `j/k`, arrow keys and `Enter`; `Esc` or `q` cancels.

## Default language servers

Mason is configured to install:

- `lua_ls`
- `pyright`
- `ts_ls`
- `gopls`
- `rust_analyzer`

Open `:Mason` to install or remove additional tooling.

## Completion and formatting

Completion is provided by `blink.cmp` using LSP, path, snippets, and buffer sources.

Formatting is handled by Conform. The default formatter map includes:

- Lua → `stylua`
- Python → `ruff_format`
- JavaScript / TypeScript / JSON / Markdown → `prettierd`, falling back to `prettier`

Use `<leader>cf` to format manually.

If a formatter executable is not installed, install it with your system package manager or Mason where supported.

## Keybindings

Leader is `Space`.

| Key | Action |
| --- | --- |
| `<C-c>` / `<C-d>` | Open SmartClose |
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
| `gr` | Find references |
| `K` | Hover documentation |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>dd` | Diagnostic popup |
| `<leader>bd` | Delete buffer |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<C-h/j/k/l>` | Navigate windows |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>tt` | Terminal |
| `jk` / `kj` | Leave insert mode |

Run `:Lazy` to inspect plugins and `:checkhealth` to diagnose your local setup.

## Structure

```text
.
├── init.lua
├── install.sh
└── lua
    ├── plugins.lua
    └── psychovim
        ├── autocmds.lua
        ├── keymaps.lua
        ├── lazy.lua
        ├── options.lua
        └── smart_close.lua
```

The project intentionally keeps the distribution small enough to understand. Core behavior lives under `lua/psychovim/`; plugin specifications live in `lua/plugins.lua`.

## Philosophy

PSYCHOVIM should feel distinctive in actual use, not only in screenshots. Opinionated shortcuts are part of the distribution when they remove friction, but irreversible actions should still make their intent obvious. SmartClose is the model: `Ctrl+C` / `Ctrl+D` are deliberately unconventional exit keys, wrapped in an explicit confirmation UI.

The old configuration used Packer and committed generated `packer_compiled.lua` output. v1 removes that artifact and moves dependency management to `lazy.nvim`.

## Troubleshooting

### `pycho` command not found

The installer places the launcher at `~/.local/bin/pycho`. Open a new terminal after installation. If your shell does not load that directory automatically, add this to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Plugins fail to install

Check that `git` is available, then run:

```vim
:Lazy sync
```

### LSP is not running

Run:

```vim
:Mason
:checkhealth vim.lsp
```

### Treesitter parser errors

Run:

```vim
:TSUpdate
:checkhealth vim.treesitter
```

### Icons look broken

Use a Nerd Font in your terminal emulator.

## Roadmap

Next useful additions:

- first-class DAP/debugging profiles
- integrated test runner
- project-local formatter/LSP overrides
- startup performance budget and benchmark command
- install smoke test in GitHub Actions
- optional minimal / full profiles

## License

MIT.

PSYCHOVIM is an unofficial fan-made configuration and is not affiliated with the creators or rights holders of *American Psycho*.
