# PSYCHOVIM

Neovim with a Pierce & Pierce dress code and fewer stupid exits.

It is *American Psycho* themed, but it is still an editor. No blood-drip ASCII art. No ten-paragraph lore dump. The surface stays clean; the weirdness lives in the names, the UI, and a few deliberately opinionated defaults.

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

You need Git, `curl`, `tar`, and a C compiler. `ripgrep` and a Nerd Font are worth having.

Neovim itself is optional. If there is no usable Neovim 0.12+ on the machine, the installer pulls the official stable build into `~/.local/share/psychovim/neovim`. No `sudo`, no package-manager surgery.

Existing `~/.config/nvim` gets timestamped and backed up before PSYCHOVIM moves in. A failed clone restores it.

The installer also syncs the plugin set before it returns. Network hiccups get three attempts. If GitHub still flakes out, the log is at `~/.cache/psychovim/lazy-sync.log` and the retry is:

```bash
pycho --headless '+Lazy! sync' '+qa'
```

Linux and macOS x86_64/arm64 are handled by the automatic Neovim bootstrap.

## The annoying Vim stuff

This is the part that matters.

| Key | What it does here |
| --- | --- |
| `Ctrl+C` / `Ctrl+D` | **SmartClose** — save & quit / quit dirty / cancel |
| `Ctrl+S` | Save. Revolutionary technology. |
| `Ctrl+Z` | Undo instead of suspending Neovim into your shell |
| `Ctrl+Shift+Z` | Redo, if your terminal reports the key separately |
| `Ctrl+F` | Fuzzy search in the current file |
| `Ctrl+P` | Find files |
| `Ctrl+A` | Select all |
| Visual `p` | Paste without murdering the yank register |
| `<leader>bd` | **SmartBufferClose** — asks before throwing work away |
| Terminal `Esc` | Get out of terminal insert mode |

Yes, `Ctrl+D` normally scrolls half a page in Vim. Here it opens SmartClose. This is not a neutral config.

`:q`, `:edit`, `:bdelete` and friends also use Neovim's `confirm` behavior, so unsaved work gets a prompt instead of an `E37` lecture.

Native suspend still exists as `:suspend` / `:stop`.

## SmartClose

`Ctrl+C` and `Ctrl+D` work from normal, insert, visual, and terminal mode.

```text
 SmartClose

 Unsaved buffers: 2

  1  Save all & quit
  2  Quit without saving
  3  Cancel
```

`1/2/3`, arrows or `j/k`, `Enter`, `Esc`.

## Dorsia

Project sessions, because apparently getting a table is easier than rebuilding six splits every morning.

```vim
:DorsiaSave
:Dorsia
:DorsiaForget
```

- `:DorsiaSave` saves the current project session.
- `:Dorsia` picks and restores a saved session.
- `:DorsiaForget` deletes the current project's session.
- Real project sessions refresh on exit.
- Empty `pycho` launches do not leave junk sessions behind.
- Dorsia will not load another session over dirty buffers.

Keys: `<leader>pd`, `<leader>ps`, `<leader>px`.

## Business Card

```vim
:BusinessCard
```

A Pierce & Pierce card with the current Git branch, cwd, loaded plugin count and active LSP count.

`<leader>pb`.

No watermark. Bone coloring depends on your terminal.

## Morning Routine

```vim
:MorningRoutine
```

Checks the things this config actually cares about: Neovim, Git, ripgrep, a compiler, plugin state and the current mask.

`<leader>pr`.

## Mask / After Hours

```vim
:Mask
:AfterHours
```

`Mask` is the default: black, warm off-white, muted borders, very little red.

`AfterHours` lets the red out.

Toggle with `<leader>pm`.

## Stack

Nothing exotic just for the sake of being exotic:

- `lazy.nvim` — plugins
- native `vim.lsp` + Mason — language servers
- `blink.cmp` — completion
- `conform.nvim` — formatting
- Telescope — finding things
- nvim-tree — files
- nvim-treesitter — parsing/highlighting
- gitsigns — Git gutter
- Snacks — dashboard, picker, input UI
- Catppuccin — syntax palette underneath PSYCHOVIM's overrides

Default LSPs: `lua_ls`, `pyright`, `ts_ls`, `gopls`, `rust_analyzer`.

Default formatter map:

- Lua → `stylua`
- Python → `ruff_format`
- JS / TS / JSON / Markdown → `prettierd`, then `prettier`

Manual format: `<leader>cf`.

## Useful keys

Leader is `Space`.

| Key | Action |
| --- | --- |
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

## If something looks expensive but doesn't work

```vim
:checkhealth
:Lazy
:Mason
:ConformInfo
```

Broken icons: install a Nerd Font.

No live grep: install `ripgrep`.

Language server missing: open `:Mason`.

Interrupted plugin clone: rerun `pycho --headless '+Lazy! sync' '+qa'`. If one plugin was left half-cloned, delete that plugin's directory under `~/.local/share/nvim/lazy/` and retry.

## Repo

```text
init.lua
install.sh
lua/psychovim/        core behavior
lua/plugins.lua       plugin specs
.github/workflows/    smoke test
```

Every push to `main` runs a headless smoke test: installer syntax, Lua parse, plugin sync, Neovim startup and the PSYCHOVIM modules.

MIT. Unofficial fan project. Not affiliated with Bret Easton Ellis, Lionsgate, or the film's rights holders.
