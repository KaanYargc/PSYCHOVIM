#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/OnurByte/PSYCHOVIM.git"
BRANCH="${PSYCHOVIM_BRANCH:-main}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="${PSYCHOVIM_DIR:-$CONFIG_HOME/nvim}"
BIN_DIR="${PSYCHOVIM_BIN_DIR:-$HOME/.local/bin}"
NVIM_HOME="${PSYCHOVIM_NVIM_DIR:-$HOME/.local/share/psychovim/neovim}"
NVIM_LINK="$BIN_DIR/nvim"
PYCHO_BIN="$BIN_DIR/pycho"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=""
NVIM_EXEC=""
TMP_DIR=""

bold='\033[1m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
reset='\033[0m'

say() { printf '%b\n' "$*"; }
die() { say "${red}error:${reset} $*" >&2; exit 1; }

cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

restore_backup() {
  if [[ -n "$BACKUP" && -e "$BACKUP" ]]; then
    rm -rf "$TARGET"
    mv "$BACKUP" "$TARGET"
    say "${yellow}restored:${reset} $TARGET"
  fi
}

nvim_is_supported() {
  local executable="$1"
  local version_line major minor

  version_line="$($executable --version 2>/dev/null | head -n 1 || true)"
  if [[ "$version_line" =~ v([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    (( major > 0 || (major == 0 && minor >= 12) ))
    return
  fi
  return 1
}

detect_neovim_asset() {
  local os arch platform asset_arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux) platform="linux" ;;
    Darwin) platform="macos" ;;
    *) die "automatic Neovim install supports Linux/macOS only; got: $os" ;;
  esac

  case "$arch" in
    x86_64|amd64) asset_arch="x86_64" ;;
    arm64|aarch64) asset_arch="arm64" ;;
    *) die "no official Neovim binary mapping for architecture: $arch" ;;
  esac

  printf 'nvim-%s-%s' "$platform" "$asset_arch"
}

install_neovim() {
  local asset url archive
  asset="$(detect_neovim_asset)"
  url="https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz"

  TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t psychovim)"
  archive="$TMP_DIR/neovim.tar.gz"

  say "nvim 0.12+ not found; pulling stable"
  say "target: ${bold}${NVIM_HOME}${reset}"

  curl -fL --retry 3 --connect-timeout 15 "$url" -o "$archive" \
    || die "could not download Neovim"

  rm -rf "$NVIM_HOME"
  mkdir -p "$NVIM_HOME"
  tar -xzf "$archive" --strip-components=1 -C "$NVIM_HOME" \
    || die "could not extract Neovim"

  NVIM_EXEC="$NVIM_HOME/bin/nvim"
  [[ -x "$NVIM_EXEC" ]] || die "archive extracted without bin/nvim"
  nvim_is_supported "$NVIM_EXEC" || die "downloaded Neovim is older than 0.12"

  mkdir -p "$BIN_DIR"
  if [[ ! -e "$NVIM_LINK" || -L "$NVIM_LINK" ]]; then
    ln -sfn "$NVIM_EXEC" "$NVIM_LINK"
    say "link: ${bold}${NVIM_LINK}${reset}"
  else
    say "${yellow}warning:${reset} $NVIM_LINK exists and is not a symlink; leaving it alone"
  fi

  say "nvim: $($NVIM_EXEC --version | head -n 1)"
}

resolve_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    local existing
    existing="$(command -v nvim)"
    if nvim_is_supported "$existing"; then
      NVIM_EXEC="$existing"
      say "nvim: $($NVIM_EXEC --version | head -n 1) (${NVIM_EXEC})"
      return
    fi

    say "${yellow}old nvim:${reset} $($existing --version | head -n 1)"
  fi

  install_neovim
}

ensure_launcher_path() {
  case ":$PATH:" in
    *":$BIN_DIR:"*) return 0 ;;
  esac

  local shell_name profile export_line
  shell_name="$(basename "${SHELL:-}")"
  profile=""

  if [[ "$BIN_DIR" == "$HOME/.local/bin" ]]; then
    export_line='export PATH="$HOME/.local/bin:$PATH"'
  else
    export_line="export PATH=\"$BIN_DIR:\$PATH\""
  fi

  case "$shell_name" in
    zsh) profile="$HOME/.zshrc" ;;
    bash) profile="$HOME/.bashrc" ;;
  esac

  if [[ -n "$profile" ]]; then
    touch "$profile"
    if ! grep -Fq '# PSYCHOVIM launcher' "$profile"; then
      {
        printf '\n# PSYCHOVIM launcher\n'
        printf '%s\n' "$export_line"
      } >> "$profile"
      say "path: added ${bold}${BIN_DIR}${reset} to ${bold}${profile}${reset}"
      say "open a new shell before running ${bold}pycho${reset}"
    fi
  else
    say "${yellow}warning:${reset} $BIN_DIR is not in PATH"
  fi
}

install_launcher() {
  mkdir -p "$BIN_DIR"

  {
    printf '#!/usr/bin/env bash\n'
    printf 'PREFERRED_NVIM=%q\n' "$NVIM_EXEC"
    cat <<'EOF'

if [[ -x "$PREFERRED_NVIM" ]]; then
  exec "$PREFERRED_NVIM" "$@"
fi

if command -v nvim >/dev/null 2>&1; then
  exec nvim "$@"
fi

printf '%s\n' 'pycho: nvim not found' >&2
exit 127
EOF
  } > "$PYCHO_BIN"

  chmod 755 "$PYCHO_BIN"
  say "launcher: ${bold}${PYCHO_BIN}${reset}"
  ensure_launcher_path
}

say "${red}${bold}PSYCHOVIM${reset} // SETUP"
say ""

command -v git >/dev/null 2>&1 || die "git is required"
command -v curl >/dev/null 2>&1 || die "curl is required"
command -v tar >/dev/null 2>&1 || die "tar is required"

resolve_neovim

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  BACKUP="${TARGET}.backup-${STAMP}"
  say "config: $TARGET"
  say "backup: ${bold}${BACKUP}${reset}"
  mv "$TARGET" "$BACKUP"
fi

mkdir -p "$(dirname "$TARGET")"

say "clone: ${bold}${REPO_URL}${reset} -> ${bold}${TARGET}${reset} (${BRANCH})"
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET"; then
  restore_backup
  die "clone failed"
fi

install_launcher

say ""
say "${green}${bold}done.${reset} run: ${bold}pycho${reset}"
say "first launch: lazy.nvim will sync plugins"
if [[ -n "$BACKUP" ]]; then
  say "old config: ${bold}${BACKUP}${reset}"
fi
