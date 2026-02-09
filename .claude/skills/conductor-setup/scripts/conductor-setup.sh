#!/bin/zsh
set -e

echo "==> Conductor workspace setup"

symlink_env() {
  local src="$1"
  local dest="$2"
  if [ ! -f "$src" ]; then
    echo "  WARN: $src not found — skipping (add it via Repository Settings > Open In)"
    return 0
  fi
  ln -sf "$src" "$dest"
  echo "  OK: $dest -> $src"
}

# Discover .env files in CONDUCTOR_ROOT_PATH and symlink them
echo "==> Symlinking .env files from CONDUCTOR_ROOT_PATH"
find "$CONDUCTOR_ROOT_PATH" -maxdepth 2 -name ".env" -not -path "*/node_modules/*" -not -path "*/.next/*" | while read -r envfile; do
  rel="${envfile#$CONDUCTOR_ROOT_PATH/}"
  symlink_env "$envfile" "$rel"
done

# Also handle .env.local if present
find "$CONDUCTOR_ROOT_PATH" -maxdepth 2 -name ".env.local" -not -path "*/node_modules/*" -not -path "*/.next/*" | while read -r envfile; do
  rel="${envfile#$CONDUCTOR_ROOT_PATH/}"
  symlink_env "$envfile" "$rel"
done

echo "==> Conductor workspace ready"
