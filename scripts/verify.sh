#!/usr/bin/env bash
# =============================================================================
# verify.sh — Deterministic Verification Gate (V3)
# 
# This script is the single source of truth for all verification.
# It reads project-config.json, executes commands, and enforces thresholds.
# NO LLM involvement. Exit code 0 = pass. Exit code 1 = fail.
#
# Usage: bash scripts/verify.sh [lint|build|test|security|all]
# =============================================================================

set -euo pipefail

CONFIG_FILE="project-config.json"
REPORT_FILE=".agents/scratch/verification-report.txt"
mkdir -p .agents/scratch

# ── Helpers ──────────────────────────────────────────────────────────────────
log()  { echo "[verify] $*" | tee -a "$REPORT_FILE"; }
fail() { echo "[FAIL] $*"   | tee -a "$REPORT_FILE"; exit 1; }
pass() { echo "[PASS] $*"   | tee -a "$REPORT_FILE"; }

read_config() {
  local key="$1"
  python3 -c "import json,sys; d=json.load(open('$CONFIG_FILE')); v=d.get('$key'); print(v if v is not None else 'null')"
}

run_check() {
  local name="$1"
  local cmd
  cmd=$(read_config "${name}_cmd")

  if [ "$cmd" = "null" ] || [ -z "$cmd" ]; then
    fail "${name}_cmd is null or unconfigured. Verification is BLOCKED. Configure it in project-config.json."
  fi

  log "Running $name: $cmd"
  if ! eval "$cmd" >> "$REPORT_FILE" 2>&1; then
    fail "$name failed (exit code $?). See $REPORT_FILE for details."
  fi
  pass "$name passed."
}

check_coverage() {
  local threshold
  threshold=$(read_config "coverage_threshold_percent")

  if [ "$threshold" = "null" ]; then
    log "WARNING: coverage_threshold_percent not set. Skipping coverage gate."
    return 0
  fi

  # Try to extract coverage from common report formats (lcov, pytest-cov, nyc)
  local coverage_value=""

  if [ -f "coverage/lcov.info" ]; then
    local lines_found lines_hit
    lines_found=$(grep -c "^DA:" coverage/lcov.info || true)
    lines_hit=$(grep "^DA:" coverage/lcov.info | grep -cv ",0$" || true)
    if [ "$lines_found" -gt 0 ]; then
      coverage_value=$(python3 -c "print(round(($lines_hit / $lines_found) * 100, 1))")
    fi
  elif [ -f "coverage/coverage-summary.json" ]; then
    coverage_value=$(python3 -c "import json; d=json.load(open('coverage/coverage-summary.json')); print(d['total']['lines']['pct'])")
  elif [ -f ".coverage" ] && command -v coverage &>/dev/null; then
    coverage_value=$(coverage report | awk '/TOTAL/{print $NF}' | tr -d '%')
  fi

  if [ -z "$coverage_value" ]; then
    fail "Coverage report not found. Run test_cmd with coverage enabled. Expected: coverage/lcov.info, coverage/coverage-summary.json, or .coverage"
  fi

  log "Coverage detected: ${coverage_value}% (threshold: ${threshold}%)"

  local ok
  ok=$(python3 -c "print('yes' if float('$coverage_value') >= float('$threshold') else 'no')")

  if [ "$ok" != "yes" ]; then
    fail "Coverage ${coverage_value}% is below required threshold of ${threshold}%."
  fi
  pass "Coverage ${coverage_value}% meets threshold of ${threshold}%."
}

check_high_risk() {
  local changed_files
  changed_files=$(git diff --name-only "origin/main...HEAD" 2>/dev/null || git diff --name-only HEAD~1 2>/dev/null || echo "")

  if [ -z "$changed_files" ]; then
    log "No changed files detected against main. Skipping high-risk path check."
    return 0
  fi

  local high_risk_paths
  high_risk_paths=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print('\n'.join(d.get('high_risk_paths', [])))")

  while IFS= read -r path; do
    [ -z "$path" ] && continue
    if echo "$changed_files" | grep -q "^$path"; then
      log "HIGH RISK PATH DETECTED: $path — Full pipeline is required."
      echo "HIGH_RISK=true" >> "$REPORT_FILE"
      return 0
    fi
  done <<< "$high_risk_paths"

  log "No high-risk paths affected."
  echo "HIGH_RISK=false" >> "$REPORT_FILE"
}

# ── Main ─────────────────────────────────────────────────────────────────────
TARGET="${1:-all}"
echo "" > "$REPORT_FILE"
log "=== Verification Gate Start: $(date) ==="
log "Target: $TARGET"

case "$TARGET" in
  lint)     run_check "lint" ;;
  build)    run_check "build" ;;
  security) run_check "security" ;;
  test)
    run_check "test"
    check_coverage
    ;;
  risk)     check_high_risk ;;
  all)
    check_high_risk
    run_check "lint"
    run_check "build"
    run_check "test"
    check_coverage
    run_check "security"
    ;;
  *)
    fail "Unknown target: $TARGET. Use: lint|build|test|security|risk|all"
    ;;
esac

log "=== Verification Gate Complete: PASS ==="
exit 0
