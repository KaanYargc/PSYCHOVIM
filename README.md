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
- modular options, keymaps, autocmds, and plugin configuration

## Requirements

- Neovim **0.12+**
- Git
- a C compiler (required by Treesitter parsers)
- `curl` and `tar`
- a Nerd Font is recommended for icons
- `ripgrep` is recommended for Telescope live grep

## Installation

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
└── lua
    ├── plugins.lua
    └── psychovim
        ├── autocmds.lua
        ├── keymaps.lua
        ├── lazy.lua
        └── options.lua
```

The project intentionally keeps the distribution small enough to understand. Core behavior lives under `lua/psychovim/`; plugin specifications live in `lua/plugins.lua`.

## Philosophy

PSYCHOVIM should feel distinctive without sabotaging normal editor behavior. Theme jokes stay in presentation; destructive or surprising keybindings do not.

The old configuration used Packer and committed generated `packer_compiled.lua` output. v1 removes that artifact and moves dependency management to `lazy.nvim`.

## Troubleshooting

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
