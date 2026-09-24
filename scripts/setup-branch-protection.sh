#!/usr/bin/env bash
# =============================================================================
# setup-branch-protection.sh — One-time GitHub Branch Protection Setup (V3)
#
# Run this ONCE after creating your repository.
# Configures main branch protection via GitHub API so that:
#   - Direct pushes to main are BLOCKED for everyone (including admins).
#   - PRs require all CI checks to pass before merge is allowed.
#   - The Merge button is physically disabled until CI is green.
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated: gh auth login
#   - Repo must have at least one commit and the CI workflow must exist.
#
# Usage:
#   export GITHUB_REPO="owner/repo-name"
#   bash scripts/setup-branch-protection.sh
# =============================================================================

set -euo pipefail

REPO="${GITHUB_REPO:?ERROR: Set GITHUB_REPO env var, e.g. export GITHUB_REPO=Savchhq/my-project}"
BRANCH="main"

echo "[setup] Configuring branch protection for: $REPO ($BRANCH)"

# Required CI check names must match the job names in .github/workflows/ci.yml exactly.
# If you rename jobs in ci.yml, update this list.
REQUIRED_CHECKS=(
  "secret-scan"
  "sast-scan"
  "lint"
  "build"
  "test-and-coverage"
)

# Build the required_status_checks JSON array
CHECKS_JSON=$(printf '"%s",' "${REQUIRED_CHECKS[@]}" | sed 's/,$//')

gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${REPO}/branches/${BRANCH}/protection" \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": [${CHECKS_JSON}]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
EOF

echo ""
echo "[setup] Branch protection applied successfully."
echo ""
echo "What this means:"
echo "  - Direct push to main: BLOCKED (for everyone, including admins)."
echo "  - Merge without passing CI: PHYSICALLY IMPOSSIBLE (GitHub disables the button)."
echo "  - Required checks: ${REQUIRED_CHECKS[*]}"
echo ""
echo "To verify, go to: https://github.com/${REPO}/settings/branches"
