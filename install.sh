#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/OnurByte/PSYCHOVIM.git"
BRANCH="${PSYCHOVIM_BRANCH:-main}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
TARGET="${PSYCHOVIM_DIR:-$CONFIG_HOME/nvim}"
BIN_DIR="${PSYCHOVIM_BIN_DIR:-$HOME/.local/bin}"
PSYCHO_HOME="$DATA_HOME/psychovim"
NVIM_HOME="${PSYCHOVIM_NVIM_DIR:-$PSYCHO_HOME/neovim}"
NVIM_PATH_FILE="$PSYCHO_HOME/nvim-path"
TS_HOME="${PSYCHOVIM_TREE_SITTER_DIR:-$PSYCHO_HOME/tree-sitter}"
NVIM_FRONTEND="$BIN_DIR/nvim"
TS_LINK="$BIN_DIR/tree-sitter"
PYCHO_BIN="$BIN_DIR/pycho"
PYCHO_UPDATE_BIN="$BIN_DIR/pychoUpdate"
PYCHO_UPDATER_BIN="$BIN_DIR/pychoUpdater"
LAZY_ROOT="$DATA_HOME/nvim/lazy"
CACHE_DIR="$CACHE_HOME/psychovim"
SYNC_LOG="$CACHE_DIR/lazy-sync.log"
TOOL_LOG="$CACHE_DIR/mason-tools.log"
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

cleanup() {
  [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR" || true
}
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
  compiler_available || return 1
  if [[ "$(uname -s)" == "Linux" ]]; then
    command -v xdg-mime >/dev/null 2>&1 || return 1
  fi
}

install_system_dependencies() {
  if system_deps_ready; then
    say "deps: ${green}ok${reset}"
    return 0
  fi

  say "deps: installing editor runtime"
  if command -v apt-get >/dev/null 2>&1; then
    run_root apt-get update
    run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git curl tar gzip unzip ripgrep build-essential nodejs npm xdg-utils
  elif command -v dnf >/dev/null 2>&1; then
    run_root dnf install -y git curl tar gzip unzip ripgrep gcc gcc-c++ make nodejs npm xdg-utils
  elif command -v pacman >/dev/null 2>&1; then
    run_root pacman -Syu --needed --noconfirm git curl tar gzip unzip ripgrep base-devel nodejs npm xdg-utils
  elif command -v zypper >/dev/null 2>&1; then
    run_root zypper --non-interactive refresh
    run_root zypper --non-interactive install git curl tar gzip unzip ripgrep gcc gcc-c++ make nodejs npm xdg-utils
  elif command -v apk >/dev/null 2>&1; then
    run_root apk add git curl tar gzip unzip ripgrep build-base nodejs npm xdg-utils
  elif command -v brew >/dev/null 2>&1; then
    local packages=()
    command -v git >/dev/null 2>&1 || packages+=(git)
    command -v curl >/dev/null 2>&1 || packages+=(curl)
    command -v rg >/dev/null 2>&1 || packages+=(ripgrep)
    command -v node >/dev/null 2>&1 || packages+=(node)
    command -v make >/dev/null 2>&1 || packages+=(make)
    command -v unzip >/dev/null 2>&1 || packages+=(unzip)
    if ! compiler_available; then packages+=(llvm); fi
    (( ${#packages[@]} == 0 )) || brew install "${packages[@]}"
    if ! compiler_available && [[ -x "$(brew --prefix llvm)/bin/clang" ]]; then
      mkdir -p "$BIN_DIR"
      ln -sfn "$(brew --prefix llvm)/bin/clang" "$BIN_DIR/clang"
      ln -sfn "$(brew --prefix llvm)/bin/clang" "$BIN_DIR/cc"
      export PATH="$BIN_DIR:$PATH"
    fi
  else
    die "missing dependencies and no supported package manager found (apt/dnf/pacman/zypper/apk/brew)"
  fi

  system_deps_ready || die "dependency installation finished but required commands are still missing"
  say "deps: ${green}ok${reset}"
}

nvim_is_supported() {
  local executable="$1" line="" major="" minor=""
  line="$("$executable" --version 2>/dev/null | head -n 1 || true)"
  if [[ "$line" =~ v([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    (( major > 0 || (major == 0 && minor >= 12) ))
    return
  fi
  return 1
}

is_pycho_frontend() {
  local executable="$1"
  grep -Eq 'PYCHOVIM nvim frontend|PSYCHOVIM nvim frontend' "$executable" 2>/dev/null
}

find_existing_nvim() {
  local candidate=""
  if [[ -f "$NVIM_PATH_FILE" ]]; then
    candidate="$(cat "$NVIM_PATH_FILE" 2>/dev/null || true)"
    if [[ -n "$candidate" && -x "$candidate" ]] && nvim_is_supported "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  if [[ -x "$NVIM_HOME/bin/nvim" ]] && nvim_is_supported "$NVIM_HOME/bin/nvim"; then
    printf '%s\n' "$NVIM_HOME/bin/nvim"
    return 0
  fi

  while IFS= read -r candidate; do
    [[ -n "$candidate" && -x "$candidate" ]] || continue
    is_pycho_frontend "$candidate" && continue
    if nvim_is_supported "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(type -aP nvim 2>/dev/null | awk '!seen[$0]++')
  return 1
}

detect_neovim_asset() {
  local os="$(uname -s)" arch="$(uname -m)" platform="" asset_arch=""
  case "$os" in
    Linux) platform="linux" ;;
    Darwin) platform="macos" ;;
    *) die "automatic PychoVIM engine install supports Linux/macOS only; got: $os" ;;
  esac
  case "$arch" in
    x86_64|amd64) asset_arch="x86_64" ;;
    arm64|aarch64) asset_arch="arm64" ;;
    *) die "no official engine binary mapping for architecture: $arch" ;;
  esac
  printf 'nvim-%s-%s' "$platform" "$asset_arch"
}

install_neovim() {
  local asset="" url="" archive=""
  asset="$(detect_neovim_asset)"
  url="https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz"
  TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t pychovim)"
  archive="$TMP_DIR/nvim.tar.gz"

  say "engine: pulling stable"
  curl -fL --retry 3 --retry-all-errors --connect-timeout 15 "$url" -o "$archive" || die "could not download the PychoVIM engine"
  rm -rf "$NVIM_HOME"
  mkdir -p "$NVIM_HOME"
  tar -xzf "$archive" --strip-components=1 -C "$NVIM_HOME" || die "could not extract the engine"
  NVIM_EXEC="$NVIM_HOME/bin/nvim"
  [[ -x "$NVIM_EXEC" ]] || die "engine archive has no bin/nvim"
  nvim_is_supported "$NVIM_EXEC" || die "downloaded engine is older than 0.12"
}

resolve_neovim() {
  local existing=""
  existing="$(find_existing_nvim 2>/dev/null || true)"
  if [[ -n "$existing" ]]; then
    NVIM_EXEC="$existing"
  else
    install_neovim
  fi
  mkdir -p "$PSYCHO_HOME"
  printf '%s\n' "$NVIM_EXEC" > "$NVIM_PATH_FILE"
  say "engine: $("$NVIM_EXEC" --version | head -n 1)"
}

detect_tree_sitter_asset() {
  local os="$(uname -s)" arch="$(uname -m)" platform="" asset_arch=""
  case "$os" in Linux) platform="linux" ;; Darwin) platform="macos" ;; *) return 1 ;; esac
  case "$arch" in x86_64|amd64) asset_arch="x64" ;; arm64|aarch64) asset_arch="arm64" ;; *) return 1 ;; esac
  printf 'tree-sitter-cli-%s-%s.zip' "$platform" "$asset_arch"
}

install_tree_sitter() {
  if command -v tree-sitter >/dev/null 2>&1; then
    say "tree-sitter: $(tree-sitter --version 2>/dev/null | head -n 1)"
    return 0
  fi

  local asset="" url="" archive=""
  asset="$(detect_tree_sitter_asset)" || { say "${yellow}tree-sitter:${reset} unsupported platform"; return 0; }
  url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}"
  [[ -n "$TMP_DIR" ]] || TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t pychovim)"
  archive="$TMP_DIR/tree-sitter.zip"

  say "tree-sitter: pulling CLI"
  curl -fL --retry 3 --retry-all-errors --connect-timeout 15 "$url" -o "$archive" || { say "${yellow}tree-sitter:${reset} download missed the network"; return 0; }
  rm -rf "$TS_HOME"
  mkdir -p "$TS_HOME/bin"
  unzip -qo "$archive" -d "$TS_HOME/bin" || { say "${yellow}tree-sitter:${reset} extraction failed"; return 0; }
  chmod 755 "$TS_HOME/bin/tree-sitter" 2>/dev/null || true
  [[ -x "$TS_HOME/bin/tree-sitter" ]] || return 0
  mkdir -p "$BIN_DIR"
  ln -sfn "$TS_HOME/bin/tree-sitter" "$TS_LINK"
  export PATH="$BIN_DIR:$PATH"
  say "tree-sitter: $("$TS_HOME/bin/tree-sitter" --version | head -n 1)"
}

ensure_launcher_path() {
  case ":$PATH:" in *":$BIN_DIR:"*) return 0 ;; esac
  local shell_name="$(basename "${SHELL:-}")" profile="" export_line=""
  [[ "$BIN_DIR" == "$HOME/.local/bin" ]] && export_line='export PATH="$HOME/.local/bin:$PATH"' || export_line="export PATH=\"$BIN_DIR:\$PATH\""
  case "$shell_name" in zsh) profile="$HOME/.zshrc" ;; bash) profile="$HOME/.bashrc" ;; esac
  if [[ -n "$profile" ]]; then
    touch "$profile"
    if ! grep -Fq '# PYCHOVIM launcher' "$profile"; then
      printf '\n# PYCHOVIM launcher\n%s\n' "$export_line" >> "$profile"
    fi
  fi
}

install_launcher() {
  [[ -f "$TARGET/bin/pycho" ]] || die "$TARGET/bin/pycho is missing"
  mkdir -p "$BIN_DIR" "$PSYCHO_HOME"
  printf '%s\n' "$NVIM_EXEC" > "$NVIM_PATH_FILE"

  cat > "$PYCHO_BIN" <<EOF
#!/usr/bin/env bash
exec bash $(printf '%q' "$TARGET/bin/pycho") "\$@"
EOF
  cat > "$PYCHO_UPDATE_BIN" <<EOF
#!/usr/bin/env bash
exec $(printf '%q' "$PYCHO_BIN") update "\$@"
EOF
  cat > "$PYCHO_UPDATER_BIN" <<EOF
#!/usr/bin/env bash
exec $(printf '%q' "$PYCHO_BIN") update "\$@"
EOF

  if [[ -e "$NVIM_FRONTEND" || -L "$NVIM_FRONTEND" ]]; then
    if [[ -L "$NVIM_FRONTEND" ]] || is_pycho_frontend "$NVIM_FRONTEND"; then
      rm -f "$NVIM_FRONTEND"
    else
      mv "$NVIM_FRONTEND" "$NVIM_FRONTEND.pre-pychovim-$STAMP"
    fi
  fi
  cat > "$NVIM_FRONTEND" <<EOF
#!/usr/bin/env bash
# PYCHOVIM nvim frontend
exec $(printf '%q' "$PYCHO_BIN") "\$@"
EOF

  chmod 755 "$PYCHO_BIN" "$PYCHO_UPDATE_BIN" "$PYCHO_UPDATER_BIN" "$NVIM_FRONTEND"
  ensure_launcher_path
  export PATH="$BIN_DIR:$PATH"
  say "launcher: pycho"
  say "frontend: nvim = pycho"
}

repair_plugin_checkout() {
  local name="$1"
  local dir="$LAZY_ROOT/$name"
  local dirty="" backup=""
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
  mkdir -p "$CACHE_DIR"
  : > "$SYNC_LOG"
  repair_plugin_checkout "nvim-lspconfig"
  say "extensions: syncing"
  for attempt in 1 2 3; do
    if PSYCHOVIM_MAINTENANCE=1 "$NVIM_EXEC" --headless "+Lazy! sync" "+qa" >>"$SYNC_LOG" 2>&1; then
      say "extensions: ${green}ok${reset}"
      return 0
    fi
    (( attempt == 3 )) || sleep $(( attempt * 2 ))
  done
  say "${yellow}extensions:${reset} incomplete — $SYNC_LOG"
  return 0
}

sync_tools() {
  mkdir -p "$CACHE_DIR"
  : > "$TOOL_LOG"
  say "tools: syncing"
  if PSYCHOVIM_MAINTENANCE=1 "$NVIM_EXEC" --headless "+MasonToolsInstallSync" "+qa" >>"$TOOL_LOG" 2>&1; then
    say "tools: ${green}ok${reset}"
  else
    say "${yellow}tools:${reset} incomplete — $TOOL_LOG"
  fi
}

sync_parsers() {
  mkdir -p "$CACHE_DIR"
  : > "$PARSER_LOG"
  command -v tree-sitter >/dev/null 2>&1 || { say "parsers: skipped"; return 0; }
  say "parsers: syncing"
  if PSYCHOVIM_MAINTENANCE=1 "$NVIM_EXEC" --headless \
    "+lua local ts=require('nvim-treesitter'); local langs={'bash','c','cpp','go','javascript','json','lua','markdown','python','rust','toml','tsx','typescript','vim','vimdoc','yaml'}; for _,lang in ipairs(langs) do ts.install({lang}):wait(300000) end" \
    "+qa" >>"$PARSER_LOG" 2>&1; then
    say "parsers: ${green}ok${reset}"
  else
    say "${yellow}parsers:${reset} incomplete — $PARSER_LOG"
  fi
}

apply_default_editor_policy() {
  export EDITOR="$PYCHO_BIN"
  export VISUAL="$PYCHO_BIN"
  export GIT_EDITOR="$PYCHO_BIN"
  if "$PYCHO_BIN" default-editor --quiet; then
    say "default editor: ${green}PychoVIM${reset}"
  else
    say "default editor: ${yellow}policy queued for first launch${reset}"
  fi
}

say "${red}${bold}PYCHOVIM${reset} // SETUP"

if $LAUNCHER_ONLY; then
  resolve_neovim
  install_launcher
  apply_default_editor_policy
  say "${green}launcher updated.${reset}"
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
say "clone: ${bold}${REPO_URL}${reset} -> ${bold}${TARGET}${reset}"
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET"; then
  restore_backup
  die "clone failed"
fi

install_launcher
apply_default_editor_policy
sync_plugins
sync_tools
sync_parsers

say "${green}${bold}done.${reset} opening PychoVIM..."
[[ -n "$BACKUP" ]] && say "old config: ${bold}${BACKUP}${reset}"

if [[ "${PSYCHOVIM_NO_AUTOLAUNCH:-0}" != "1" && -t 1 && -r /dev/tty && -w /dev/tty ]]; then
  exec "$PYCHO_BIN" </dev/tty >/dev/tty 2>/dev/tty
fi
say "run: ${bold}pycho${reset}"
