#!/usr/bin/env bash
set -euo pipefail

# Installs this repo's git hooks. Run once after cloning.
repo_root="$(git rev-parse --show-toplevel)"
hook="$repo_root/.git/hooks/pre-commit"

cat > "$hook" <<'EOF'
#!/usr/bin/env bash
exec "$(git rev-parse --show-toplevel)/scripts/check-no-local-paths.sh"
EOF

chmod +x "$hook"
echo "✓ pre-commit hook installed → $hook"
