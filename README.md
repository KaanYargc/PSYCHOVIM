# 🔪 PychoVim

> *"Look at that subtle off-white coloring. The tasteful thickness of it. Oh my God, it even has a watermark."*

An American Psycho themed Neovim configuration filled with psychopathic details. Bringing Patrick Bateman's obsessive perfectionism and dark aesthetic to your coding environment.

## 🩸 Features

### Aesthetic Perfection
- **Dark Theme**: Catppuccin Mocha (with blood red highlights)
- **Obsessive Details**: Every pixel in its place
- **Psychopath Icons**: 🔪 💀 🩸 ⚠️ 💥
- **Perfect Symmetry**: Auto-pairs and indent guides

### Stalking Tools
- **Telescope**: Find and track victims
- **NvimTree**: Map the territory
- **Gitsigns**: Track the evidence
- **Todo Comments**: KILL, VICTIM, HIDE tags

### Psychological Features
- **Random Messages**: A different Patrick Bateman quote on each startup
- **Smooth Scrolling**: Elegant and calculated movements
- **Undo Persistence**: Never forget anything
- **Auto-cleanup**: Obsessive cleaning (trailing whitespace)

## 📦 Installation

### 1. Clone the repository

```bash
git clone https://github.com/KaanYargc/PSYCHOVIM.git ~/.config/nvim
```

### 2. Remove the .git folder (so you can add it to your own repo later)

```bash
rm -rf ~/.config/nvim/.git
```

### 3. Install Packer

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

### 4. Install Plugins

Open Neovim and run:

```vim
:PackerSync
```

### 5. Update Treesitter

```vim
:TSUpdate
```

## 🎯 Keybindings

### Basic Operations
| Keybinding | Description |
|---------|----------|
| `Space` | Leader key |
| `jk` / `kj` | Exit insert mode |
| `<leader>w` | Save (hide the body) |
| `<leader>q` | Quit (leave no trace) |
| `<leader>Q` | Close all (burn everything) |

### Buffer Management (Victim Selection)
| Keybinding | Description |
|---------|----------|
| `<leader>bd` | Delete buffer (eliminate) |
| `Tab` | Next buffer (next victim) |
| `Shift+Tab` | Previous buffer (previous victim) |

### Window Management (Kill Room)
| Keybinding | Description |
|---------|----------|
| `Ctrl+h/j/k/l` | Navigate between windows |
| `<leader>sv` | Split vertically (vertical dissection) |
| `<leader>sh` | Split horizontally (horizontal dissection) |
| `<leader>sx` | Close window |

### Telescope (Stalking Tools)
| Keybinding | Description |
|---------|----------|
| `<leader>ff` | Find files (hunt) |
| `<leader>fg` | Search text (search for clues) |
| `<leader>fb` | Buffer list (victim list) |
| `<leader>fr` | Recent files (past crimes) |

### File Tree
| Keybinding | Description |
|---------|----------|
| `<leader>e` | Toggle file tree |
| `<leader>o` | Focus on file tree |

## 🎨 Changing Theme

Default theme is Catppuccin Mocha, but there are other options:

```vim
:colorscheme tokyonight
:colorscheme nightfox
:colorscheme rose-pine
```

## 🔧 Customization

### Add Your Own Messages

Edit the `messages` table in `init.lua`:

```lua
local messages = {
    "Your own psychopathic message...",
    "Another dark quote...",
}
```

### Change Colors

Edit Catppuccin settings in `lua/plugins.lua`:

```lua
color_overrides = {
    mocha = {
        base = "#0d0d0d",      -- Background
        red = "#8b0000",       -- Blood red
        -- Other colors...
    },
},
```

## 📚 Plugin List

- **catppuccin/nvim** - Main theme (dark and sophisticated)
- **nvim-lualine/lualine.nvim** - Status line (business card quality)
- **akinsho/bufferline.nvim** - Buffer tabs (victim tabs)
- **goolord/alpha-nvim** - Dashboard (welcome to hell)
- **nvim-telescope/telescope.nvim** - Fuzzy finder (surveillance)
- **nvim-tree/nvim-tree.lua** - File explorer (territory map)
- **nvim-treesitter/nvim-treesitter** - Syntax highlighting (forensics)
- **lewis6991/gitsigns.nvim** - Git integration (track evidence)
- **folke/which-key.nvim** - Keybinding helper (memory aid)
- **folke/todo-comments.nvim** - Todo highlighting (obsessive notes)
- **rcarriga/nvim-notify** - Notifications (intrusive thoughts)
- **windwp/nvim-autopairs** - Auto pairs (perfect symmetry)
- **numToStr/Comment.nvim** - Comments (inner monologue)
- **kylechui/nvim-surround** - Surround text (wrap victims)
- **karb94/neoscroll.nvim** - Smooth scrolling (elegant movements)
- **norcalli/nvim-colorizer.lua** - Color highlighter (blood detection)
- **lukas-reineke/indent-blankline.nvim** - Indent guides (OCD lines)

## 🎬 Screenshots

The dashboard greets you with:

```
  ██████╗ ██╗   ██╗ ██████╗██╗  ██╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ██╔══██╗╚██╗ ██╔╝██╔════╝██║  ██║██╔═══██╗██║   ██║██║████╗ ████║
  ██████╔╝ ╚████╔╝ ██║     ███████║██║   ██║██║   ██║██║██╔████╔██║
  ██╔═══╝   ╚██╔╝  ██║     ██╔══██║██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║        ██║   ╚██████╗██║  ██║╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝        ╚═╝    ╚═════╝╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

           🔪 I have to return some videotapes 🔪

Let's see Paul Allen's config...
```

## 💀 Todo Tags

You can use special tags in your code:

```lua
-- KILL: Destroy this function
-- VICTIM: This variable is a target
-- HIDE: Hide this code
-- TODO: Normal todo
-- HACK: Dirty work
-- WARN: Warning
-- PERF: Performance
-- NOTE: Note
```

## 🩺 Troubleshooting

### Plugins not loading
```vim
:PackerSync
:PackerCompile
```

### Treesitter errors
```vim
:TSUpdate
:TSInstall lua vim python javascript
```

### Theme not loading
```vim
:PackerSync
:colorscheme catppuccin
```

## 🎭 Quotes

You'll see a random Patrick Bateman quote on each Neovim startup:

- "Let's see Paul Allen's config..."
- "I have to return some videotapes"
- "Try getting a reservation at Dorsia now!"
- "I'm into murders and executions mostly"
- "Do you like Huey Lewis and the News?"
- And more...

## 📝 License

MIT - But Patrick Bateman didn't approve.

## 🔪 Warning

This configuration is purely for entertainment purposes. It contains no real violence, just a dark aesthetic inspired by the American Psycho movie. Have fun coding!

---

*"I think my mask of sanity is about to slip."*
