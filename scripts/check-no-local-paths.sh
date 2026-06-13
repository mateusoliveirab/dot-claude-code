#!/usr/bin/env bash
set -euo pipefail

# Blocks commits that introduce machine-specific absolute paths.
# Used as a pre-commit hook (see scripts/install-hooks.sh) and runnable manually.

# Patterns that indicate a local/machine-specific path.
PATTERN='/home/[^/"]+/|/Users/[^/"]+/|/mnt/c/Users/'

# Only scan staged, added/changed text; ignore this script and the hook installer.
mapfile -t files < <(git diff --cached --name-only --diff-filter=ACM | grep -Ev '^scripts/(check-no-local-paths|install-hooks)\.sh$' || true)

found=0
for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  # Added lines only (exclude the "+++" diff header); awk avoids grep-variant quirks.
  while IFS= read -r line; do
    if [[ "$line" =~ $PATTERN ]]; then
      [[ $found -eq 0 ]] && echo "✗ Local/machine-specific paths found in staged changes:" >&2
      echo "  $f: ${line#+}" >&2
      found=1
    fi
  done < <(git diff --cached -U0 -- "$f" | awk '/^\+/ && !/^\+\+\+/')
done

if [[ $found -ne 0 ]]; then
  echo "" >&2
  echo "Remove the local paths or commit with --no-verify to override." >&2
  exit 1
fi
