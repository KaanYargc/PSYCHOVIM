# 🔪 PychoVim

> *"Look at that subtle off-white coloring. The tasteful thickness of it. Oh my God, it even has a watermark."*

American Psycho temalı, psikopat detaylarla dolu bir Neovim konfigürasyonu. Patrick Bateman'ın obsesif mükemmeliyetçiliği ve karanlık estetiğini kodlama ortamınıza taşıyor.

## 🩸 Özellikler

### Estetik Mükemmellik
- **Karanlık Tema**: Catppuccin Mocha (kan kırmızısı vurgularla)
- **Obsesif Detaylar**: Her piksel yerli yerinde
- **Psikopat İkonlar**: 🔪 💀 🩸 ⚠️ 💥
- **Mükemmel Simetri**: Auto-pairs ve indent guides

### Stalking Araçları
- **Telescope**: Kurbanları bul ve takip et
- **NvimTree**: Bölgeyi haritalandır
- **Gitsigns**: Kanıtları takip et
- **Todo Comments**: KILL, VICTIM, HIDE etiketleri

### Psikolojik Özellikler
- **Random Mesajlar**: Her açılışta farklı bir Patrick Bateman alıntısı
- **Smooth Scrolling**: Zarif ve hesaplı hareketler
- **Undo Persistence**: Hiçbir şeyi unutma
- **Auto-cleanup**: Obsesif temizlik (trailing whitespace)

## 📦 Kurulum

### 1. Packer'ı Yükle

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

### 2. Konfigürasyonu Kopyala

```bash
# Mevcut config'i yedekle (eğer varsa)
mv ~/.config/nvim ~/.config/nvim.backup

# PychoVim'i kopyala
cp -r . ~/.config/nvim
```

### 3. Pluginleri Yükle

Neovim'i aç ve şunu çalıştır:

```vim
:PackerSync
```

### 4. Treesitter'ı Güncelle

```vim
:TSUpdate
```

## 🎯 Kısayollar

### Temel İşlemler
| Kısayol | Açıklama |
|---------|----------|
| `Space` | Leader tuşu |
| `jk` / `kj` | Insert mode'dan çık |
| `<leader>w` | Kaydet (hide the body) |
| `<leader>q` | Çık (leave no trace) |
| `<leader>Q` | Hepsini kapat (burn everything) |

### Buffer Yönetimi (Victim Selection)
| Kısayol | Açıklama |
|---------|----------|
| `<leader>bd` | Buffer'ı sil (eliminate) |
| `Tab` | Sonraki buffer (next victim) |
| `Shift+Tab` | Önceki buffer (previous victim) |

### Pencere Yönetimi (Kill Room)
| Kısayol | Açıklama |
|---------|----------|
| `Ctrl+h/j/k/l` | Pencereler arası gezin |
| `<leader>sv` | Dikey böl (vertical dissection) |
| `<leader>sh` | Yatay böl (horizontal dissection) |
| `<leader>sx` | Pencereyi kapat |

### Telescope (Stalking Tools)
| Kısayol | Açıklama |
|---------|----------|
| `<leader>ff` | Dosya bul (hunt) |
| `<leader>fg` | Metin ara (search for clues) |
| `<leader>fb` | Buffer listesi (victim list) |
| `<leader>fr` | Son dosyalar (past crimes) |

### Dosya Ağacı
| Kısayol | Açıklama |
|---------|----------|
| `<leader>e` | Dosya ağacını aç/kapat |
| `<leader>o` | Dosya ağacına odaklan |

## 🎨 Tema Değiştirme

Varsayılan tema Catppuccin Mocha, ama başka seçenekler de var:

```vim
:colorscheme tokyonight
:colorscheme nightfox
:colorscheme rose-pine
```

## 🔧 Özelleştirme

### Kendi Mesajlarını Ekle

`init.lua` dosyasındaki `messages` tablosunu düzenle:

```lua
local messages = {
    "Kendi psikopat mesajın...",
    "Başka bir karanlık alıntı...",
}
```

### Renkleri Değiştir

`lua/plugins.lua` içinde Catppuccin ayarlarını düzenle:

```lua
color_overrides = {
    mocha = {
        base = "#0d0d0d",      -- Arka plan
        red = "#8b0000",       -- Kan kırmızısı
        -- Diğer renkler...
    },
},
```

## 📚 Plugin Listesi

- **catppuccin/nvim** - Ana tema (karanlık ve sofistike)
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

## 🎬 Ekran Görüntüleri

Dashboard'da seni şu karşılıyor:

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

## 💀 Todo Etiketleri

Kodunda özel etiketler kullanabilirsin:

```lua
-- KILL: Bu fonksiyonu yok et
-- VICTIM: Bu değişken hedef
-- HIDE: Bu kodu gizle
-- TODO: Normal todo
-- HACK: Kirli iş
-- WARN: Dikkat
-- PERF: Performans
-- NOTE: Not
```

## 🩺 Sorun Giderme

### Pluginler yüklenmiyor
```vim
:PackerSync
:PackerCompile
```

### Treesitter hataları
```vim
:TSUpdate
:TSInstall lua vim python javascript
```

### Tema yüklenmiyor
```vim
:PackerSync
:colorscheme catppuccin
```

## 🎭 Alıntılar

Her Neovim açılışında rastgele bir Patrick Bateman alıntısı görürsün:

- "Let's see Paul Allen's config..."
- "I have to return some videotapes"
- "Try getting a reservation at Dorsia now!"
- "I'm into murders and executions mostly"
- "Do you like Huey Lewis and the News?"
- Ve daha fazlası...

## 📝 Lisans

MIT - Ama Patrick Bateman onaylamadı.

## 🔪 Uyarı

Bu konfigürasyon tamamen eğlence amaçlıdır. Gerçek şiddet içermez, sadece American Psycho filminden esinlenmiş karanlık bir estetik sunar. Kodlarken eğlenin!

---

*"I think my mask of sanity is about to slip."*
