#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="https://github.com/OnurByte/PSYCHOVIM.git"
BRANCH="${PSYCHOVIM_BRANCH:-main}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="${PSYCHOVIM_DIR:-$CONFIG_HOME/nvim}"
STAMP="$(date +%Y%m%d-%H%M%S)"

bold='\033[1m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
reset='\033[0m'

say() { printf '%b\n' "$*"; }
die() { say "${red}error:${reset} $*" >&2; exit 1; }

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
  say "${yellow}warning:${reset} Neovim was not found. The config will be installed, but Neovim 0.12+ is required to run it."
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
  die "clone failed. If a backup was created, it has been left untouched."
fi

say ""
say "${green}${bold}Installation complete.${reset}"
say "Run: ${bold}nvim${reset}"
say "On first launch, lazy.nvim will bootstrap the plugin set."
say ""
say "Ctrl+C / Ctrl+D → SmartClose"
