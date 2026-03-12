#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/hellovigoss/myskills.git"
SKILLS_DIR="${HOME}/.claude/skills"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <skill-name> [skill-name ...]"
  echo ""
  echo "Available skills:"
  echo "  electron-remote-debugging  - Debug live Electron apps"
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git clone --depth 1 --quiet "$REPO" "$TMPDIR/myskills"

for skill in "$@"; do
  if [ ! -d "$TMPDIR/myskills/$skill" ] || [ ! -f "$TMPDIR/myskills/$skill/SKILL.md" ]; then
    echo "Error: skill '$skill' not found in repo"
    exit 1
  fi

  mkdir -p "$SKILLS_DIR/$skill"
  cp -r "$TMPDIR/myskills/$skill/." "$SKILLS_DIR/$skill/"
  echo "Installed '$skill' to $SKILLS_DIR/$skill/"
done

echo "Done. Restart Claude Code to pick up new skills."
