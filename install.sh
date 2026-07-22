#!/bin/sh
# TerminaLLM Hive installer.
# Usage: curl -fsSL https://terminallm.app/install.sh | sh
# Installs the Hive CLI + daemon for Swarm into ~/.hive/bin. No root needed.
# Review this script before running it; every download is sha256-pinned below.
set -eu

HIVE_VERSION="v0.1.5"
BASE_URL="https://terminallm.app/bin/hive/$HIVE_VERSION"
BIN_DIR="$HOME/.hive/bin"

os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Darwin) os="darwin" ;;
  Linux)  os="linux" ;;
  *) echo "install.sh: unsupported OS: $os (need macOS or Linux)" >&2; exit 1 ;;
esac
case "$arch" in
  x86_64|amd64)  arch="amd64" ;;
  aarch64|arm64) arch="arm64" ;;
  *) echo "install.sh: unsupported architecture: $arch (need x86_64/arm64)" >&2; exit 1 ;;
esac

checksum_for() {
  case "$1" in
    # BEGIN generated from dist/v0.1.5/SHA256SUMS (scripts/build-bundled-hive.sh)
    hive-daemon-darwin-amd64) echo "84252b3615b5d879e62a3772788a2fa53ffc7695f087260d9e2cad33b7934458" ;;
    hive-daemon-darwin-arm64) echo "82a394ae20a4fa471dd7f7355f40f968a4e5384f0c0c64acdea1eacd8fec9412" ;;
    hive-daemon-linux-amd64) echo "053d5d7f9f979b06cd09c37ff1814cc9e11588e019d284a6cefadda2911bdf9a" ;;
    hive-daemon-linux-arm64) echo "976123987939bb69960c28e544d140e8a8516f5722cc37f75ccf1f43b5ddab9d" ;;
    hive-darwin-amd64) echo "93998a57e61d462af3d067d970a3bc7b9f8a3bfdd8e979523a0e967dec24a6f8" ;;
    hive-darwin-arm64) echo "96c830d26383304b0a842bcde4d29f8ff4aecac187ce987c129f1c2a8589e12c" ;;
    hive-linux-amd64) echo "c76dd4d4da6c50fd342d45c4a716cac53f7e518076944b946f77ee04d62d1c54" ;;
    hive-linux-arm64) echo "35ffef413af3720e1b1afaccba8a34634d54415f8f9f0f0dec4fdde5b9c6e6e9" ;;
    # END generated
    *) echo "" ;;
  esac
}

digest() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else echo "install.sh: need sha256sum or shasum to verify downloads" >&2; exit 1
  fi
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT INT TERM
mkdir -p "$BIN_DIR"

for name in hive hive-daemon; do
  gz="$tmpdir/$name.gz"
  echo "Downloading $name ($os-$arch)..."
  curl -fsSL "$BASE_URL/$os-$arch/$name.gz" -o "$gz"

  expected=$(checksum_for "$name-$os-$arch")
  actual=$(digest "$gz")
  if [ -z "$expected" ] || [ "$actual" != "$expected" ]; then
    echo "install.sh: checksum mismatch for $name-$os-$arch" >&2
    echo "  expected: ${expected:-<none>}" >&2
    echo "  actual:   $actual" >&2
    echo "Refusing to install." >&2
    exit 1
  fi

  gunzip -f "$gz"
  chmod 755 "$tmpdir/$name"

  # Idempotent backup-then-swap (same scheme the app uses over SFTP).
  if [ -e "$BIN_DIR/$name" ]; then
    rm -f "$BIN_DIR/$name.bak"
    mv "$BIN_DIR/$name" "$BIN_DIR/$name.bak"
  fi
  mv "$tmpdir/$name" "$BIN_DIR/$name"
  echo "Installed $BIN_DIR/$name"
done

echo ""
echo "Hive $HIVE_VERSION installed. The TerminaLLM app starts the daemon on"
echo "your next Swarm connection."
