---
description: Validation requirements after fixes and code changes
---

# Working Approach

## After Any Fix or Change

Test before reporting done — don't assume it works.

If the endpoint can be hit, hit it. If the script can be run, run it. If edge cases can be exercised, exercise them. Only report done after validation passes.

- Bash scripts: `bash -n <script>` (syntax) + `bash <script> --dry-run` if supported
- JSON files: `jq empty <file>`
- Endpoints/features: curl, browser, MCP — test directly, not just by reading the code
