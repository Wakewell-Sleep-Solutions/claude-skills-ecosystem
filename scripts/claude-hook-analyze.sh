#!/usr/bin/env bash
# claude-hook-analyze.sh — Lightweight hook for Claude Code PostToolUse
# Called on every Write/Edit. Runs fast checks only (Tier 1 + targeted Semgrep).
# Full scans are triggered by code-analyzer.sh --all manually or pre-commit.
#
# Input: receives JSON on stdin from Claude Code hook system
# Output: findings printed to stderr (shown to Claude), exit 0 always

set -uo pipefail
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
[[ -d "$LOCALAPPDATA/Programs/Python" ]] && export PATH="$(ls -d "$LOCALAPPDATA"/Programs/Python/Python*/Scripts 2>/dev/null | head -1):$PATH" 2>/dev/null

# Read hook context from stdin
HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.command // empty' 2>/dev/null)

# Skip non-code files
[[ -z "$FILE_PATH" ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.py) ;; # Analyze these
  *) exit 0 ;; # Skip everything else
esac

# Find project root
find_root() {
  local dir="$(dirname "$1")"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/package.json" ]] && echo "$dir" && return
    dir="$(dirname "$dir")"
  done
}
PROJECT_ROOT="$(find_root "$FILE_PATH")"

ISSUES=()

# --- ESLint (fast, <1s) ---
if command -v eslint &>/dev/null; then
  ESLINT_OUT=$(eslint --format json "$FILE_PATH" 2>/dev/null || true)
  ESLINT_COUNT=$(echo "$ESLINT_OUT" | jq '[.[].messages[] | select(.severity == 2)] | length' 2>/dev/null || echo "0")
  if [[ "$ESLINT_COUNT" -gt 0 ]]; then
    ISSUES+=("ESLint: $ESLINT_COUNT errors")
    echo "$ESLINT_OUT" | jq -r '.[].messages[] | select(.severity == 2) | "  L\(.line): [\(.ruleId // "?")] \(.message)"' 2>/dev/null | head -5 >&2
  fi
fi

# --- Semgrep (targeted single file, <5s) ---
if command -v semgrep &>/dev/null; then
  SEMGREP_OUT=$(semgrep scan --config auto --json --quiet "$FILE_PATH" 2>/dev/null || true)
  SEMGREP_COUNT=$(echo "$SEMGREP_OUT" | jq '.results | length' 2>/dev/null || echo "0")
  if [[ "$SEMGREP_COUNT" -gt 0 ]]; then
    ISSUES+=("Semgrep: $SEMGREP_COUNT security findings")
    echo "$SEMGREP_OUT" | jq -r '.results[:5][] | "  \(.start.line): [\(.extra.severity)] \(.extra.message[:100])"' 2>/dev/null >&2
  fi
fi

# --- HIPAA quick check (regex, instant) ---
PHI_PATTERNS='console\.(log|info|warn|error|debug)\s*\(.*\b(ssn|dob|patient.?name|date.?of.?birth|medical.?record|insurance.?id|diagnosis)\b'
PHI_HITS=$(grep -niE "$PHI_PATTERNS" "$FILE_PATH" 2>/dev/null | head -3)
if [[ -n "$PHI_HITS" ]]; then
  ISSUES+=("HIPAA: Potential PHI in logs")
  echo "$PHI_HITS" | while read -r line; do echo "  $line" >&2; done
fi

# --- Secrets detection (instant) ---
SECRET_PATTERNS='(api[_-]?key|secret[_-]?key|password|token|bearer)\s*[:=]\s*["\x27][A-Za-z0-9+/=_-]{8,}'
SECRET_HITS=$(grep -niE "$SECRET_PATTERNS" "$FILE_PATH" 2>/dev/null | grep -viE '(process\.env|import|type|interface|example|placeholder|TODO|FIXME)' | head -3)
if [[ -n "$SECRET_HITS" ]]; then
  ISSUES+=("SECRETS: Possible hardcoded credentials")
  echo "$SECRET_HITS" | while read -r line; do echo "  $line" >&2; done
fi

# --- Output summary ---
if [[ ${#ISSUES[@]} -gt 0 ]]; then
  echo "⚠️  CODE ANALYZER FINDINGS:" >&2
  for issue in "${ISSUES[@]}"; do
    echo "  • $issue" >&2
  done
  echo "  Run 'bash ~/Documents/scripts/code-analyzer.sh --all <dir>' for full scan" >&2
fi

# Always exit 0 — hooks should not block Claude Code
exit 0
