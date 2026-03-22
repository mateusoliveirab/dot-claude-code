#!/usr/bin/env bash
# discover-docs.sh
# Lists all tracked README.md and CLAUDE.md files in the repository.
# Usage: bash discover-docs.sh [repo-root]
#
# Output: one file path per line, sorted, relative to repo root.
# Excludes nothing — git ls-files already respects .gitignore.

set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel)}"

cd "$REPO_ROOT"

DOCS=$(git ls-files | grep -E "(README|CLAUDE)\.md$" | sort || true)

if [ -z "$DOCS" ]; then
  echo "No documentation files found."
else
  echo "$DOCS"
fi
