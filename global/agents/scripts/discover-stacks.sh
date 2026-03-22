#!/usr/bin/env bash
# discover-stacks.sh
# Finds directories that contain a stack indicator file but have no README.md.
# Usage: bash discover-stacks.sh [repo-root]
#
# Stack indicators: package.json, pyproject.toml, Cargo.toml, go.mod,
#                   requirements.txt, composer.json
#
# Output: one directory path per line (relative to repo root).
#         Empty output means all stacks are documented.

set -euo pipefail

REPO_ROOT="${1:-$(git rev-parse --show-toplevel)}"

cd "$REPO_ROOT"

# All directories that contain a stack indicator (excluding node_modules)
STACK_DIRS=$(
  git ls-files \
    | grep -E "(package\.json|pyproject\.toml|Cargo\.toml|go\.mod|requirements\.txt|composer\.json)$" \
    | grep -v "node_modules" \
    | sed 's|/[^/]*$||' \
    | sort -u \
    || true
)

# Directories that already have a README.md
DOCUMENTED_DIRS=$(
  git ls-files \
    | grep -E "README\.md$" \
    | sed 's|/README\.md$||' \
    | sort -u \
    || true
)

# No stack indicators found at all
if [ -z "$STACK_DIRS" ]; then
  echo "No stacks found."
  exit 0
fi

# Root-level stack indicators have an empty dirname — normalize to "."
# then check if root README exists
MISSING=()
while IFS= read -r dir; do
  dir="${dir:-.}"
  readme_path="${dir}/README.md"
  [ "$dir" = "." ] && readme_path="README.md"

  if ! git ls-files --error-unmatch "$readme_path" > /dev/null 2>&1; then
    MISSING+=("$dir")
  fi
done <<< "$STACK_DIRS"

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "All stacks are documented."
else
  printf '%s\n' "${MISSING[@]}"
fi
