#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_NAME="${APP_NAME:-XWorkmate}"
TARGET_APP="/Applications/$APP_NAME.app"
DMG_PATH="${1:-}"
APP_NAME_SLUG="$(printf '%s' "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
MOUNT_POINT="$(mktemp -d "/tmp/${APP_NAME_SLUG}-install.XXXXXX")"
OPEN_AFTER_INSTALL="${OPEN_AFTER_INSTALL:-0}"

cleanup() {
  hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
  rmdir "$MOUNT_POINT" 2>/dev/null || true
}

trap cleanup EXIT

if [[ -z "$DMG_PATH" ]]; then
  shopt -s nullglob
  dmgs=("$DIST_DIR"/"$APP_NAME"-*.dmg)
  shopt -u nullglob
  if [[ "${#dmgs[@]}" -eq 0 ]]; then
    echo "No DMG found under $DIST_DIR for $APP_NAME" >&2
    exit 1
  fi
  IFS=$'\n' dmgs=($(ls -t "${dmgs[@]}"))
  unset IFS
  DMG_PATH="${dmgs[0]}"
fi

if [[ ! -f "$DMG_PATH" ]]; then
  echo "DMG not found: $DMG_PATH" >&2
  exit 1
fi

echo "Mounting $DMG_PATH..."
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_POINT" -nobrowse -readonly -quiet

SOURCE_APP="$MOUNT_POINT/$APP_NAME.app"
if [[ ! -d "$SOURCE_APP" ]]; then
  echo "Expected app bundle missing from DMG: $SOURCE_APP" >&2
  exit 1
fi

if [[ -d "$TARGET_APP" ]]; then
  echo "Replacing existing app at $TARGET_APP"
  rm -rf "$TARGET_APP"
fi

echo "Installing to $TARGET_APP..."
ditto "$SOURCE_APP" "$TARGET_APP"
xattr -dr com.apple.quarantine "$TARGET_APP" 2>/dev/null || true

if [[ "$OPEN_AFTER_INSTALL" == "1" ]]; then
  open "$TARGET_APP"
fi

echo "Installed: $TARGET_APP"
