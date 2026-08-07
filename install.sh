#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/OnurByte/PSYCHOVIM.git"
BRANCH="${PSYCHOVIM_BRANCH:-main}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TARGET="${PSYCHOVIM_DIR:-$CONFIG_HOME/nvim}"
BIN_DIR="${PSYCHOVIM_BIN_DIR:-$HOME/.local/bin}"
NVIM_HOME="${PSYCHOVIM_NVIM_DIR:-$DATA_HOME/psychovim/neovim}"
TS_HOME="${PSYCHOVIM_TREE_SITTER_DIR:-$DATA_HOME/psychovim/tree-sitter}"
NVIM_LINK="$BIN_DIR/nvim"
TS_LINK="$BIN_DIR/tree-sitter"
PYCHO_BIN="$BIN_DIR/pycho"
LAZY_ROOT="$DATA_HOME/nvim/lazy"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/psychovim"
SYNC_LOG="$CACHE_DIR/lazy-sync.log"
PARSER_LOG="$CACHE_DIR/parser-sync.log"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=""
NVIM_EXEC=""
TMP_DIR=""
LAUNCHER_ONLY=false

[[ "${1:-}" == "--launcher-only" ]] && LAUNCHER_ONLY=true

bold='\033[1m'; red='\033[31m'; green='\033[32m'; yellow='\033[33m'; reset='\033[0m'
say() { printf '%b\n' "$*"; }
die() { say "${red}error:${reset} $*" >&2; exit 1; }

cleanup() { [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR" || true; }
trap cleanup EXIT

restore_backup() {
  if [[ -n "$BACKUP" && -e "$BACKUP" ]]; then
    rm -rf "$TARGET"
    mv "$BACKUP" "$TARGET"
    say "${yellow}restored:${reset} $TARGET"
  fi
}

run_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    die "system packages are missing and sudo is unavailable"
  fi
}

compiler_available() {
  command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1
}

system_deps_ready() {
  local cmd
  for cmd in git curl tar gzip unzip rg make node npm; do
    command -v "$cmd" >/dev/null 2>&1 || return 1
  done
  compiler_available
}

install_system_dependencies() {
  if system_deps_ready; then
    say "deps: ${green}ok${reset}"
    return 0
  fi

  say "deps: installing git/curl/archive tools/ripgrep/compiler/node"

  if command -v apt-get >/dev/null 2>&1; then
    run_root apt-get update
    run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git curl tar gzip unzip ripgrep build-essential nodejs npm
  elif command -v dnf >/dev/null 2>&1; then
    run_root dnf install -y \
      git curl tar gzip unzip ripgrep gcc gcc-c++ make nodejs npm
  elif command -v pacman >/dev/null 2>&1; then
    run_root pacman -Syu --needed --noconfirm \
      git curl tar gzip unzip ripgrep base-devel nodejs npm
  elif command -v zypper >/dev/null 2>&1; then
    run_root zypper --non-interactive refresh
    run_root zypper --non-interactive install \
      git curl tar gzip unzip ripgrep gcc gcc-c++ make nodejs npm
  elif command -v apk >/dev/null 2>&1; then
    run_root apk add \
      git curl tar gzip unzip ripgrep build-base nodejs npm
  elif command -v brew >/dev/null 2>&1; then
    local brew_pkgs=()
    command -v git >/dev/null 2>&1 || brew_pkgs+=(git)
    command -v curl >/dev/null 2>&1 || brew_pkgs+=(curl)
    command -v rg >/dev/null 2>&1 || brew_pkgs+=(ripgrep)
    command -v node >/dev/null 2>&1 || brew_pkgs+=(node)
    if ! compiler_available; then brew_pkgs+=(llvm); fi
    if (( ${#brew_pkgs[@]} > 0 )); then brew install "${brew_pkgs[@]}"; fi
    if ! compiler_available && [[ -x "$(brew --prefix llvm)/bin/clang" ]]; then
      mkdir -p "$BIN_DIR"
      ln -sfn "$(brew --prefix llvm)/bin/clang" "$BIN_DIR/clang"
      ln -sfn "$(brew --prefix llvm)/bin/clang" "$BIN_DIR/cc"
      export PATH="$BIN_DIR:$PATH"
    fi
  else
    die "missing dependencies and no supported package manager found (apt/dnf/pacman/zypper/apk/brew)"
  fi

  system_deps_ready || die "dependency install finished but required commands are still missing"
  say "deps: ${green}ok${reset}"
}

nvim_is_supported() {
  local executable="$1" version_line major minor
  version_line="$("$executable" --version 2>/dev/null | head -n 1 || true)"
  if [[ "$version_line" =~ v([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"; minor="${BASH_REMATCH[2]}"
    (( major > 0 || (major == 0 && minor >= 12) ))
    return
  fi
  return 1
}

detect_neovim_asset() {
  local os arch platform asset_arch
  os="$(uname -s)"; arch="$(uname -m)"
  case "$os" in Linux) platform="linux" ;; Darwin) platform="macos" ;; *) die "automatic Neovim install supports Linux/macOS only; got: $os" ;; esac
  case "$arch" in x86_64|amd64) asset_arch="x86_64" ;; arm64|aarch64) asset_arch="arm64" ;; *) die "no official Neovim binary mapping for architecture: $arch" ;; esac
  printf 'nvim-%s-%s' "$platform" "$asset_arch"
}

install_neovim() {
  local asset url archive
  asset="$(detect_neovim_asset)"
  url="https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz"
  TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t psychovim)"
  archive="$TMP_DIR/neovim.tar.gz"

  say "nvim: pulling official stable"
  curl -fL --retry 3 --connect-timeout 15 "$url" -o "$archive" || die "could not download Neovim"
  rm -rf "$NVIM_HOME"; mkdir -p "$NVIM_HOME"
  tar -xzf "$archive" --strip-components=1 -C "$NVIM_HOME" || die "could not extract Neovim"
  NVIM_EXEC="$NVIM_HOME/bin/nvim"
  [[ -x "$NVIM_EXEC" ]] || die "archive extracted without bin/nvim"
  nvim_is_supported "$NVIM_EXEC" || die "downloaded Neovim is older than 0.12"

  mkdir -p "$BIN_DIR"
  if [[ ! -e "$NVIM_LINK" || -L "$NVIM_LINK" ]]; then ln -sfn "$NVIM_EXEC" "$NVIM_LINK"; fi
  say "nvim: $("$NVIM_EXEC" --version | head -n 1)"
}

resolve_neovim() {
  if [[ -x "$NVIM_HOME/bin/nvim" ]] && nvim_is_supported "$NVIM_HOME/bin/nvim"; then
    NVIM_EXEC="$NVIM_HOME/bin/nvim"
    say "nvim: $("$NVIM_EXEC" --version | head -n 1)"
    return
  fi
  if command -v nvim >/dev/null 2>&1; then
    local existing
    existing="$(command -v nvim)"
    if nvim_is_supported "$existing"; then
      NVIM_EXEC="$existing"
      say "nvim: $("$NVIM_EXEC" --version | head -n 1)"
      return
    fi
  fi
  install_neovim
}

detect_tree_sitter_asset() {
  local os arch platform asset_arch
  os="$(uname -s)"; arch="$(uname -m)"
  case "$os" in Linux) platform="linux" ;; Darwin) platform="macos" ;; *) return 1 ;; esac
  case "$arch" in x86_64|amd64) asset_arch="x64" ;; arm64|aarch64) asset_arch="arm64" ;; *) return 1 ;; esac
  printf 'tree-sitter-cli-%s-%s.zip' "$platform" "$asset_arch"
}

install_tree_sitter() {
  if command -v tree-sitter >/dev/null 2>&1; then
    say "tree-sitter: $(tree-sitter --version 2>/dev/null | head -n 1)"
    return 0
  fi

  local asset url archive
  asset="$(detect_tree_sitter_asset)" || { say "${yellow}tree-sitter:${reset} unsupported platform; parser bootstrap may be limited"; return 0; }
  url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}"
  TMP_DIR="${TMP_DIR:-$(mktemp -d 2>/dev/null || mktemp -d -t psychovim)}"
  archive="$TMP_DIR/tree-sitter.zip"

  say "tree-sitter: pulling official CLI"
  curl -fL --retry 3 --connect-timeout 15 "$url" -o "$archive" || die "could not download tree-sitter CLI"
  rm -rf "$TS_HOME"; mkdir -p "$TS_HOME/bin"
  unzip -qo "$archive" -d "$TS_HOME/bin" || die "could not extract tree-sitter CLI"
  [[ -x "$TS_HOME/bin/tree-sitter" ]] || chmod 755 "$TS_HOME/bin/tree-sitter" 2>/dev/null || true
  [[ -x "$TS_HOME/bin/tree-sitter" ]] || die "tree-sitter archive extracted without executable"

  mkdir -p "$BIN_DIR"
  if [[ ! -e "$TS_LINK" || -L "$TS_LINK" ]]; then ln -sfn "$TS_HOME/bin/tree-sitter" "$TS_LINK"; fi
  export PATH="$BIN_DIR:$PATH"
  say "tree-sitter: $("$TS_HOME/bin/tree-sitter" --version | head -n 1)"
}

ensure_launcher_path() {
  case ":$PATH:" in *":$BIN_DIR:"*) return 0 ;; esac
  local shell_name profile="" export_line
  shell_name="$(basename "${SHELL:-}")"
  [[ "$BIN_DIR" == "$HOME/.local/bin" ]] && export_line='export PATH="$HOME/.local/bin:$PATH"' || export_line="export PATH=\"$BIN_DIR:\$PATH\""
  case "$shell_name" in zsh) profile="$HOME/.zshrc" ;; bash) profile="$HOME/.bashrc" ;; esac
  if [[ -n "$profile" ]]; then
    touch "$profile"
    if ! grep -Fq '# PSYCHOVIM launcher' "$profile"; then printf '\n# PSYCHOVIM launcher\n%s\n' "$export_line" >> "$profile"; fi
  fi
}

install_launcher() {
  [[ -f "$TARGET/bin/pycho" ]] || die "$TARGET/bin/pycho is missing; update/reinstall PSYCHOVIM first"
  mkdir -p "$BIN_DIR"
  cat > "$PYCHO_BIN" <<EOF
#!/usr/bin/env bash
exec bash $(printf '%q' "$TARGET/bin/pycho") "\$@"
EOF
  chmod 755 "$PYCHO_BIN"
  say "launcher: ${bold}${PYCHO_BIN}${reset}"
  ensure_launcher_path
}

repair_plugin_checkout() {
  local name="$1" dir="$LAZY_ROOT/$name" dirty backup
  [[ -d "$dir/.git" ]] || return 0
  dirty="$(git -C "$dir" status --porcelain 2>/dev/null || true)"
  [[ -n "$dirty" ]] || return 0
  mkdir -p "$CACHE_DIR/dirty-plugins"
  backup="$CACHE_DIR/dirty-plugins/${name}-${STAMP}"
  mv "$dir" "$backup"
  say "plugin repair: $name -> $backup"
}

sync_plugins() {
  local attempt
  mkdir -p "$CACHE_DIR"; : > "$SYNC_LOG"
  repair_plugin_checkout "nvim-lspconfig"
  say "plugins: syncing"
  for attempt in 1 2 3; do
    if "$NVIM_EXEC" --headless "+Lazy! sync" "+qa" >>"$SYNC_LOG" 2>&1; then say "plugins: ${green}ok${reset}"; return 0; fi
    say "${yellow}plugins:${reset} retry $attempt/3"; sleep $(( attempt * 2 ))
  done
  say "${yellow}plugins:${reset} incomplete — $SYNC_LOG"
  return 0
}

sync_parsers() {
  mkdir -p "$CACHE_DIR"; : > "$PARSER_LOG"
  command -v tree-sitter >/dev/null 2>&1 || { say "parsers: skipped (tree-sitter CLI missing)"; return 0; }
  say "parsers: syncing"
  if "$NVIM_EXEC" --headless "+lua local ts=require('nvim-treesitter'); local langs={'bash','c','cpp','go','javascript','json','lua','markdown','python','rust','toml','tsx','typescript','vim','vimdoc','yaml'}; for _,lang in ipairs(langs) do ts.install({lang}):wait(300000) end" "+qa" >>"$PARSER_LOG" 2>&1; then
    say "parsers: ${green}ok${reset}"
  else
    say "${yellow}parsers:${reset} incomplete — $PARSER_LOG"
  fi
}

say "${red}${bold}PSYCHOVIM${reset} // SETUP"

if $LAUNCHER_ONLY; then
  resolve_neovim
  install_launcher
  say "${green}launcher updated.${reset} try: pycho help"
  exit 0
fi

install_system_dependencies
resolve_neovim
install_tree_sitter
export PATH="$BIN_DIR:$PATH"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  BACKUP="${TARGET}.backup-${STAMP}"
  say "backup: ${bold}${BACKUP}${reset}"
  mv "$TARGET" "$BACKUP"
fi
mkdir -p "$(dirname "$TARGET")"
say "clone: ${bold}${REPO_URL}${reset} -> ${bold}${TARGET}${reset} (${BRANCH})"
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET"; then restore_backup; die "clone failed"; fi

install_launcher
sync_plugins
sync_parsers
say "${green}${bold}done.${reset} run: ${bold}pycho${reset}"
[[ -n "$BACKUP" ]] && say "old config: ${bold}${BACKUP}${reset}"
