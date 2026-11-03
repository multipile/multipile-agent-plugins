#!/usr/bin/env bash
# Validates the marketplace for both hosts.
#
#   1. Generated catalogs are current (build-catalog.mjs --check)
#   2. Claude Code: `claude plugin validate` on the marketplace and on every plugin
#   3. Codex: add the marketplace and install every plugin into a throwaway CODEX_HOME,
#      so the real ~/.codex is never touched
#
# A missing CLI is skipped with a notice, unless REQUIRE_CLIS=1 (CI sets this).
# Set CLAUDE_STRICT=0 to let Claude validation warnings pass.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

read_config() { node -p "const c=JSON.parse(require('fs').readFileSync('marketplace.config.json','utf8')); $1"; }
MK_NAME="$(read_config 'c.name')"
PLUGIN_ROOT="$(read_config 'c.pluginRoot ?? "./plugins"')"
PLUGINS="$(read_config 'c.plugins.map(p => p.dir).join(" ")')"

step() { printf '\n==> %s\n' "$*"; }
missing_cli() {
  if [ "${REQUIRE_CLIS:-0}" = "1" ]; then
    echo "error: $1 is not installed and REQUIRE_CLIS=1" >&2
    exit 1
  fi
  printf '    skipped: %s is not installed (%s)\n' "$1" "$2"
}

step "Generated catalogs are current"
node scripts/build-catalog.mjs --check

step "Claude Code validation"
if command -v claude >/dev/null 2>&1; then
  strict=(--strict)
  [ "${CLAUDE_STRICT:-1}" = "0" ] && strict=()
  claude plugin validate "$ROOT" "${strict[@]}"
  for p in $PLUGINS; do
    claude plugin validate "$ROOT/$PLUGIN_ROOT/$p" "${strict[@]}"
  done
else
  missing_cli claude "npm install -g @anthropic-ai/claude-code"
fi

step "Codex validation (throwaway CODEX_HOME)"
if command -v codex >/dev/null 2>&1; then
  export CODEX_HOME="$ROOT/.validate-codex-home"
  rm -rf "$CODEX_HOME"
  mkdir -p "$CODEX_HOME"
  trap 'rm -rf "$CODEX_HOME"' EXIT
  codex plugin marketplace add "$ROOT" --json >/dev/null
  echo "    added marketplace $MK_NAME"
  for p in $PLUGINS; do
    codex plugin add "$p@$MK_NAME" --json >/dev/null
    echo "    installed $p@$MK_NAME"
  done
  installed="$(codex plugin list --json | node -p 'JSON.parse(require("fs").readFileSync(0,"utf8")).installed.filter(p => p.enabled).length')"
  expected="$(printf '%s\n' $PLUGINS | wc -l | tr -d ' ')"
  if [ "$installed" != "$expected" ]; then
    echo "error: Codex reports $installed enabled plugin(s), expected $expected" >&2
    exit 1
  fi
else
  missing_cli codex "npm install -g @openai/codex"
fi

printf '\nAll checks passed.\n'
