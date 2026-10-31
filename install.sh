#!/usr/bin/env bash
# OpenStack PALS bootstrap installer
# Installs prerequisites (uv, yq, fzf) into ~/.local/bin when possible
# and clones the repository if needed.

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

echo "❀ OpenStack PALS installer"
echo "Installing missing tools into $BIN_DIR ..."

# ---------- uv ----------
if ! command -v uv >/dev/null 2>&1; then
  echo "→ Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # common install locations
  export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:$PATH"
fi

# ---------- yq (mikefarah) ----------
if ! command -v yq >/dev/null 2>&1; then
  echo "→ Installing yq..."
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
  esac
  URL="https://github.com/mikefarah/yq/releases/latest/download/yq_${OS}_${ARCH}"
  curl -fsSL "$URL" -o "$BIN_DIR/yq"
  chmod +x "$BIN_DIR/yq"
fi

# ---------- fzf ----------
if ! command -v fzf >/dev/null 2>&1; then
  echo "→ Installing fzf..."
  TMP=$(mktemp -d)
  # Prefer official binary install
  if curl -fsSL https://github.com/junegunn/fzf/releases/latest/download/fzf-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz -o "$TMP/fzf.tgz" 2>/dev/null; then
    tar -xzf "$TMP/fzf.tgz" -C "$TMP"
    install -m 755 "$TMP/fzf" "$BIN_DIR/fzf" 2>/dev/null || cp "$TMP/fzf" "$BIN_DIR/fzf"
  else
    # Fallback: clone + install script
    git clone --depth 1 https://github.com/junegunn/fzf.git "$TMP/fzf-src" >/dev/null 2>&1 || true
    if [[ -x "$TMP/fzf-src/install" ]]; then
      "$TMP/fzf-src/install" --bin
      cp "$TMP/fzf-src/bin/fzf" "$BIN_DIR/fzf" 2>/dev/null || true
    fi
  fi
  rm -rf "$TMP"
  if ! command -v fzf >/dev/null 2>&1; then
    echo "⚠️  Could not auto-install fzf. Install it with:"
    echo "    brew install fzf   # macOS"
    echo "    sudo apt install fzf   # Debian/Ubuntu"
  fi
fi

# ---------- Bash version warning (macOS) ----------
if [[ "$(uname)" == "Darwin" ]] && [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  echo ""
  echo "⚠️  macOS ships Bash 3.x. The script uses 'mapfile' which needs Bash ≥ 4."
  echo "   Install a newer Bash with:  brew install bash"
  echo "   Then run the script with:   /opt/homebrew/bin/bash openstack-pals.sh"
fi

# ---------- Clone repo if not already inside it ----------
if [[ ! -f openstack-pals.sh ]]; then
  echo "→ Cloning repository..."
  git clone https://github.com/groda/openstack-pals.git
  cd openstack-pals
fi

echo ""
echo "✅ Prerequisites ready."
echo ""
echo "Next steps:"
echo "  1. Place your clouds.yaml in this directory"
echo "     (or remember its path — the script will ask)."
echo "     See sample_clouds.yaml for the expected format."
echo "  2. Run:"
echo "       ./openstack-pals.sh"
echo ""
echo "The script will create a virtual environment and install the OpenStack clients."
