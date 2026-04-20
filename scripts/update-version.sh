#!/usr/bin/env bash
set -euo pipefail

PACKAGE_FILE="package.nix"
CURRENT_VERSION=$(grep 'version = "' "$PACKAGE_FILE" | head -1 | sed 's/.*version = "\(.*\)";/\1/')

get_latest_version() {
  local tmp
  tmp=$(mktemp)
  curl -fsSL "https://edgedl.me.gvt1.com/edgedl/android/cli/latest/linux_x86_64/android" -o "$tmp"
  chmod +x "$tmp"
  "$tmp" --version 2>/dev/null | tail -1
  rm -f "$tmp"
}

LATEST_VERSION=$(get_latest_version)

if [[ "${1:-}" == "--check" ]]; then
  if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "Already up to date: $CURRENT_VERSION"
    exit 1
  else
    echo "Update available: $CURRENT_VERSION -> $LATEST_VERSION"
    exit 0
  fi
fi

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already up to date: $CURRENT_VERSION"
  exit 0
fi

echo "Updating $CURRENT_VERSION -> $LATEST_VERSION"

declare -A PLATFORMS=(
  ["x86_64-linux"]="linux_x86_64"
  ["aarch64-darwin"]="darwin_arm64"
)

for nix_platform in "${!PLATFORMS[@]}"; do
  url_platform="${PLATFORMS[$nix_platform]}"
  url="https://edgedl.me.gvt1.com/edgedl/android/cli/${LATEST_VERSION}/${url_platform}/android"

  echo "Fetching hash for $nix_platform..."
  nix_hash=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
  sri_hash=$(nix hash convert --hash-algo sha256 --to sri "$nix_hash")

  sed -i "s|\"$nix_platform\" = \"sha256-[^\"]*\"|\"$nix_platform\" = \"$sri_hash\"|" "$PACKAGE_FILE"
  echo "  $nix_platform: $sri_hash"
done

sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_FILE"

echo "Updated to $LATEST_VERSION"
