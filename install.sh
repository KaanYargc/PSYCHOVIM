#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/OnurByte/PSYCHOVIM.git"
BRANCH="${PSYCHOVIM_BRANCH:-main}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="${PSYCHOVIM_DIR:-$CONFIG_HOME/nvim}"
BIN_DIR="${PSYCHOVIM_BIN_DIR:-$HOME/.local/bin}"
PYCHO_BIN="$BIN_DIR/pycho"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=""

bold='\033[1m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
reset='\033[0m'

say() { printf '%b\n' "$*"; }
die() { say "${red}error:${reset} $*" >&2; exit 1; }

restore_backup() {
  if [[ -n "$BACKUP" && -e "$BACKUP" ]]; then
    rm -rf "$TARGET"
    mv "$BACKUP" "$TARGET"
    say "${yellow}Previous Neovim config restored.${reset}"
  fi
}

ensure_launcher_path() {
  case ":$PATH:" in
    *":$BIN_DIR:"*) return 0 ;;
  esac

  local shell_name profile export_line
  shell_name="$(basename "${SHELL:-}")"
  export_line='export PATH="$HOME/.local/bin:$PATH"'
  profile=""

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
      say "Added ${bold}${BIN_DIR}${reset} to PATH in ${bold}${profile}${reset}."
      say "Open a new terminal (or source that file) before using ${bold}pycho${reset}."
    fi
  else
    say "${yellow}warning:${reset} ${BIN_DIR} is not currently in PATH."
    say "Add it to your shell PATH to run ${bold}pycho${reset} directly."
  fi
}

install_launcher() {
  mkdir -p "$BIN_DIR"
  cat > "$PYCHO_BIN" <<'EOF'
#!/usr/bin/env sh

if ! command -v nvim >/dev/null 2>&1; then
  printf '%s\n' 'pycho: Neovim is not installed or not available in PATH.' >&2
  exit 127
fi

exec nvim "$@"
EOF
  chmod 755 "$PYCHO_BIN"
  say "Installed launcher: ${bold}${PYCHO_BIN}${reset}"
  ensure_launcher_path
}

say "${red}${bold}PSYCHOVIM${reset} — installation protocol"
say ""

command -v git >/dev/null 2>&1 || die "git is required. Install Git and run the installer again."

if command -v nvim >/dev/null 2>&1; then
  version_line="$(nvim --version | head -n 1)"
  if [[ "$version_line" =~ v([0-9]+)\.([0-9]+) ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    if (( major == 0 && minor < 12 )); then
      say "${yellow}warning:${reset} detected ${version_line}; PSYCHOVIM targets Neovim 0.12+."
    fi
  fi
else
  say "${yellow}warning:${reset} Neovim was not found. The config and pycho launcher will be installed, but Neovim 0.12+ is required to run them."
fi

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  BACKUP="${TARGET}.backup-${STAMP}"
  say "Existing Neovim config found."
  say "Backing it up to: ${bold}${BACKUP}${reset}"
  mv "$TARGET" "$BACKUP"
fi

mkdir -p "$(dirname "$TARGET")"

say "Cloning PSYCHOVIM (${BRANCH}) into ${bold}${TARGET}${reset}..."
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET"; then
  restore_backup
  die "clone failed. No existing configuration was lost."
fi

install_launcher

say ""
say "${green}${bold}Installation complete.${reset}"
say "Launch PSYCHOVIM with: ${bold}pycho${reset}"
say "Open a file directly with: ${bold}pycho path/to/file${reset}"
say "On first launch, lazy.nvim will bootstrap the plugin set."
if [[ -n "$BACKUP" ]]; then
  say "Previous config backup: ${bold}${BACKUP}${reset}"
fi
say ""
say "Ctrl+C / Ctrl+D → SmartClose"
