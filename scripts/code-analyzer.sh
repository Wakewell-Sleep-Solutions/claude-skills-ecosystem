#!/usr/bin/env bash
# code-analyzer.sh — Closed-loop code analysis for Claude Code hooks
# Runs Tier 1 (lint+typecheck), Tier 2 (security), Tier 3 (deep analysis)
# Outputs JSON findings that Claude Code can parse and auto-fix
#
# Usage:
#   code-analyzer.sh <file|dir>           # Analyze a file or directory
#   code-analyzer.sh --tier 1 <file>      # Run only Tier 1 (fast, <1s)
#   code-analyzer.sh --tier 2 <file|dir>  # Run only Tier 2 (security, <30s)
#   code-analyzer.sh --tier 3 <dir>       # Run only Tier 3 (deep, 1-5min)
#   code-analyzer.sh --all <dir>          # Run all tiers sequentially
#   code-analyzer.sh --hook <file>        # Hook mode: Tier 1+2, compact output

set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Colors
RED='\033[0;31m'
YLW='\033[0;33m'
GRN='\033[0;32m'
BLU='\033[0;34m'
RST='\033[0m'

# Defaults
TIER="all"
TARGET=""
HOOK_MODE=false
FINDINGS=0
OUTPUT_FILE=""

usage() {
  echo "Usage: code-analyzer.sh [--tier 1|2|3] [--all] [--hook] [--json <outfile>] <file|dir>"
  exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier) TIER="$2"; shift 2 ;;
    --all) TIER="all"; shift ;;
    --hook) HOOK_MODE=true; TIER="hook"; shift ;;
    --json) OUTPUT_FILE="$2"; shift 2 ;;
    --help|-h) usage ;;
    *) TARGET="$1"; shift ;;
  esac
done

[[ -z "$TARGET" ]] && { echo "Error: No target file or directory specified"; usage; }

# Resolve to absolute path
TARGET="$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"

# Find project root (nearest package.json)
find_project_root() {
  local dir="$1"
  [[ -f "$dir" ]] && dir="$(dirname "$dir")"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/package.json" ]] && echo "$dir" && return
    dir="$(dirname "$dir")"
  done
  echo ""
}

PROJECT_ROOT="$(find_project_root "$TARGET")"
IS_TS_FILE=false
IS_JS_FILE=false
[[ "$TARGET" == *.ts || "$TARGET" == *.tsx ]] && IS_TS_FILE=true
[[ "$TARGET" == *.js || "$TARGET" == *.jsx || "$TARGET" == *.mjs ]] && IS_JS_FILE=true

# JSON output accumulator
RESULTS='{"findings":[],"summary":{}}'

add_finding() {
  local tool="$1" severity="$2" file="$3" line="$4" message="$5" rule="$6"
  FINDINGS=$((FINDINGS + 1))
  if [[ -n "$OUTPUT_FILE" ]]; then
    RESULTS=$(echo "$RESULTS" | jq --arg t "$tool" --arg s "$severity" --arg f "$file" \
      --arg l "$line" --arg m "$message" --arg r "$rule" \
      '.findings += [{"tool":$t,"severity":$s,"file":$f,"line":$l,"message":$m,"rule":$r}]')
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIER 1: Instant feedback — ESLint + TypeScript
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_tier1() {
  echo -e "${BLU}━━━ Tier 1: Lint + Typecheck ━━━${RST}"
  local tier1_findings=0

  # ESLint
  if command -v eslint &>/dev/null; then
    if [[ -f "$TARGET" ]] && ($IS_TS_FILE || $IS_JS_FILE); then
      echo -e "  ${BLU}ESLint${RST}: $TARGET"
      local eslint_out
      if eslint_out=$(eslint --format json "$TARGET" 2>/dev/null); then
        echo -e "  ${GRN}✓ No ESLint issues${RST}"
      else
        local count
        count=$(echo "$eslint_out" | jq '[.[].messages | length] | add // 0' 2>/dev/null || echo "?")
        echo -e "  ${RED}✗ ESLint: $count issues${RST}"
        # Parse individual findings
        echo "$eslint_out" | jq -r '.[].messages[] | "\(.line)|\(.severity)|\(.ruleId // "unknown")|\(.message)"' 2>/dev/null | while IFS='|' read -r line sev rule msg; do
          local severity="warning"
          [[ "$sev" == "2" ]] && severity="error"
          add_finding "eslint" "$severity" "$TARGET" "$line" "$msg" "$rule"
          tier1_findings=$((tier1_findings + 1))
        done
        # Show first 5 issues inline
        echo "$eslint_out" | jq -r '.[].messages[:5][] | "    L\(.line): [\(.ruleId // "?")] \(.message)"' 2>/dev/null
      fi
    elif [[ -d "$TARGET" ]] && [[ -n "$PROJECT_ROOT" ]]; then
      echo -e "  ${BLU}ESLint${RST}: $TARGET (directory)"
      if eslint_out=$(cd "$PROJECT_ROOT" && eslint --format json "$TARGET" 2>/dev/null); then
        echo -e "  ${GRN}✓ No ESLint issues${RST}"
      else
        local count
        count=$(echo "$eslint_out" | jq '[.[].messages | length] | add // 0' 2>/dev/null || echo "?")
        echo -e "  ${RED}✗ ESLint: $count issues${RST}"
      fi
    fi
  else
    echo -e "  ${YLW}⚠ ESLint not found${RST}"
  fi

  # TypeScript
  if ($IS_TS_FILE || $IS_JS_FILE) && [[ -n "$PROJECT_ROOT" ]]; then
    if [[ -f "$PROJECT_ROOT/tsconfig.json" ]]; then
      echo -e "  ${BLU}TypeScript${RST}: typecheck"
      local tsc_out
      if tsc_out=$(cd "$PROJECT_ROOT" && npx tsc --noEmit 2>&1); then
        echo -e "  ${GRN}✓ No type errors${RST}"
      else
        local count
        count=$(echo "$tsc_out" | grep -c "error TS" || echo "0")
        echo -e "  ${RED}✗ TypeScript: $count errors${RST}"
        echo "$tsc_out" | grep "error TS" | head -5 | while read -r line; do
          echo "    $line"
        done
      fi
    fi
  fi

  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIER 2: Security scanning — Semgrep + Snyk
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_tier2() {
  echo -e "${BLU}━━━ Tier 2: Security Scanning ━━━${RST}"

  # Semgrep
  if command -v semgrep &>/dev/null; then
    echo -e "  ${BLU}Semgrep${RST}: scanning..."
    local semgrep_out
    if semgrep_out=$(semgrep scan --config auto --json "$TARGET" 2>/dev/null); then
      local count
      count=$(echo "$semgrep_out" | jq '.results | length' 2>/dev/null || echo "0")
      if [[ "$count" == "0" ]]; then
        echo -e "  ${GRN}✓ No security issues (Semgrep)${RST}"
      else
        echo -e "  ${RED}✗ Semgrep: $count findings${RST}"
        echo "$semgrep_out" | jq -r '.results[:10][] | "    \(.path):\(.start.line) [\(.extra.severity)] \(.check_id): \(.extra.message[:120])"' 2>/dev/null
        # Add to findings
        echo "$semgrep_out" | jq -r '.results[] | "\(.path)|\(.start.line)|\(.extra.severity)|\(.check_id)|\(.extra.message)"' 2>/dev/null | while IFS='|' read -r file line sev rule msg; do
          add_finding "semgrep" "$sev" "$file" "$line" "$msg" "$rule"
        done
      fi
    else
      echo -e "  ${YLW}⚠ Semgrep scan had issues (check rules config)${RST}"
    fi
  else
    echo -e "  ${YLW}⚠ Semgrep not installed${RST}"
  fi

  # Snyk Code (SAST)
  if command -v snyk &>/dev/null; then
    if [[ -n "$PROJECT_ROOT" ]]; then
      echo -e "  ${BLU}Snyk Code${RST}: scanning..."
      local snyk_out
      if snyk_out=$(cd "$PROJECT_ROOT" && snyk code test --json 2>/dev/null); then
        echo -e "  ${GRN}✓ No vulnerabilities (Snyk Code)${RST}"
      else
        local count
        count=$(echo "$snyk_out" | jq '.runs[0].results | length' 2>/dev/null || echo "?")
        if [[ "$count" != "?" && "$count" != "0" ]]; then
          echo -e "  ${RED}✗ Snyk Code: $count vulnerabilities${RST}"
          echo "$snyk_out" | jq -r '.runs[0].results[:5][] | "    [\(.level)] \(.message.text[:120])"' 2>/dev/null
        else
          # Might be auth error
          local err_msg
          err_msg=$(echo "$snyk_out" | jq -r '.error // empty' 2>/dev/null)
          if [[ -n "$err_msg" ]]; then
            echo -e "  ${YLW}⚠ Snyk: $err_msg${RST}"
            echo -e "  ${YLW}  Run 'snyk auth' to authenticate${RST}"
          fi
        fi
      fi

      # Snyk Open Source (dependency scan)
      echo -e "  ${BLU}Snyk OSS${RST}: dependency scan..."
      if snyk_oss=$(cd "$PROJECT_ROOT" && snyk test --json 2>/dev/null); then
        echo -e "  ${GRN}✓ No dependency vulnerabilities${RST}"
      else
        local vuln_count
        vuln_count=$(echo "$snyk_oss" | jq '.vulnerabilities | length' 2>/dev/null || echo "?")
        if [[ "$vuln_count" != "?" && "$vuln_count" != "0" ]]; then
          echo -e "  ${RED}✗ Snyk OSS: $vuln_count dependency vulnerabilities${RST}"
          echo "$snyk_oss" | jq -r '.vulnerabilities[:5][] | "    [\(.severity)] \(.packageName)@\(.version): \(.title)"' 2>/dev/null
        fi
      fi
    fi
  else
    echo -e "  ${YLW}⚠ Snyk not installed. Run: npm install -g snyk && snyk auth${RST}"
  fi

  # npm audit (always available)
  if [[ -n "$PROJECT_ROOT" ]] && [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
    echo -e "  ${BLU}npm audit${RST}: checking..."
    local audit_out
    if audit_out=$(cd "$PROJECT_ROOT" && npm audit --json 2>/dev/null); then
      local high_count
      high_count=$(echo "$audit_out" | jq '.metadata.vulnerabilities.high + .metadata.vulnerabilities.critical' 2>/dev/null || echo "0")
      if [[ "$high_count" == "0" || "$high_count" == "null" ]]; then
        echo -e "  ${GRN}✓ No high/critical npm vulnerabilities${RST}"
      else
        echo -e "  ${RED}✗ npm audit: $high_count high/critical vulnerabilities${RST}"
      fi
    fi
  fi

  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TIER 3: Deep analysis — SonarQube (if available)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run_tier3() {
  echo -e "${BLU}━━━ Tier 3: Deep Analysis ━━━${RST}"

  # SonarCloud (paid cloud instance — no Docker needed)
  SONAR_ORG="everestsleep"
  SONAR_URL="https://sonarcloud.io"

  if command -v sonar-scanner &>/dev/null && [[ -n "$PROJECT_ROOT" ]]; then
    local project_key="${SONAR_ORG}_$(basename "$PROJECT_ROOT")"
    local sonar_token="${SONAR_TOKEN:-}"

    if [[ -z "$sonar_token" ]]; then
      echo -e "  ${YLW}⚠ SONAR_TOKEN not set. Run with: irun bash code-analyzer.sh --tier 3 <dir>${RST}"
    else
      echo -e "  ${BLU}SonarCloud${RST}: deep analysis → ${project_key}..."
      (cd "$PROJECT_ROOT" && sonar-scanner \
        -Dsonar.projectKey="$project_key" \
        -Dsonar.organization="$SONAR_ORG" \
        -Dsonar.sources="." \
        -Dsonar.host.url="$SONAR_URL" \
        -Dsonar.token="$sonar_token" \
        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
        -Dsonar.exclusions="**/node_modules/**,**/dist/**,**/build/**,**/*.test.*,**/coverage/**" 2>&1 | tail -5)

      echo -e "  ${BLU}Results at: $SONAR_URL/dashboard?id=$project_key${RST}"

      # Pull results via API after scan
      sleep 3
      local issues_count
      issues_count=$(curl -s -u "$sonar_token:" "$SONAR_URL/api/issues/search?projectKeys=$project_key&severities=CRITICAL,BLOCKER&resolved=false" | jq '.total' 2>/dev/null || echo "?")
      if [[ "$issues_count" != "?" && "$issues_count" != "0" ]]; then
        echo -e "  ${RED}✗ SonarCloud: $issues_count critical/blocker issues${RST}"
        curl -s -u "$sonar_token:" "$SONAR_URL/api/issues/search?projectKeys=$project_key&severities=CRITICAL,BLOCKER&resolved=false&ps=5" \
          | jq -r '.issues[:5][] | "    [\(.severity)] \(.component | split(":")[1]):\(.line) — \(.message[:100])"' 2>/dev/null
      else
        echo -e "  ${GRN}✓ No critical/blocker issues (SonarCloud)${RST}"
      fi
    fi
  else
    echo -e "  ${YLW}⚠ sonar-scanner not installed. Run: brew install sonar-scanner${RST}"
  fi

  # HIPAA-specific checks (custom)
  if [[ -n "$PROJECT_ROOT" ]]; then
    echo -e "  ${BLU}HIPAA scan${RST}: checking for PHI leaks..."
    local phi_patterns='(ssn|social.?security|date.?of.?birth|dob|patient.?name|medical.?record|mrn|insurance.?id|diagnosis|icd.?code)'
    local phi_hits
    phi_hits=$(grep -rniE "$phi_patterns" "$TARGET" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep -viE '(type|interface|schema|validation|sanitize|mask|redact|encrypt)' | head -10)
    if [[ -n "$phi_hits" ]]; then
      local count
      count=$(echo "$phi_hits" | wc -l | tr -d ' ')
      echo -e "  ${RED}✗ HIPAA: $count potential PHI references found${RST}"
      echo "$phi_hits" | while read -r line; do
        echo -e "    ${RED}$line${RST}"
      done
    else
      echo -e "  ${GRN}✓ No obvious PHI leaks detected${RST}"
    fi
  fi

  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Run selected tiers
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BLU}╔══════════════════════════════════════════════╗${RST}"
echo -e "${BLU}║     Code Analyzer — Closed Loop System       ║${RST}"
echo -e "${BLU}╚══════════════════════════════════════════════╝${RST}"
echo -e "Target: ${GRN}$TARGET${RST}"
[[ -n "$PROJECT_ROOT" ]] && echo -e "Project: ${GRN}$PROJECT_ROOT${RST}"
echo ""

case "$TIER" in
  1) run_tier1 ;;
  2) run_tier2 ;;
  3) run_tier3 ;;
  hook) run_tier1; echo ""; run_tier2 ;;
  all) run_tier1; echo ""; run_tier2; echo ""; run_tier3 ;;
esac

# Summary
echo ""
echo -e "${BLU}━━━ Summary ━━━${RST}"
if [[ $FINDINGS -eq 0 ]]; then
  echo -e "${GRN}✓ All checks passed${RST}"
else
  echo -e "${RED}✗ $FINDINGS issues found — Claude Code will auto-fix${RST}"
fi

# Write JSON output if requested
if [[ -n "$OUTPUT_FILE" ]]; then
  RESULTS=$(echo "$RESULTS" | jq --arg f "$FINDINGS" '.summary.total_findings = ($f | tonumber)')
  echo "$RESULTS" > "$OUTPUT_FILE"
  echo -e "JSON report: ${BLU}$OUTPUT_FILE${RST}"
fi

exit 0
