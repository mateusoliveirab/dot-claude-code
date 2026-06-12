---
description: Validation requirements after fixes and code changes
---

# Working Approach

## Validation Loop After Fixes

After making any fix or change (especially after debugging errors):
1. Test the changed endpoint/feature directly (curl, browser, MCP, etc.)
2. Test edge cases (empty input, missing fields, error paths)
3. Only report done after all validations pass

## Validate After Any Script/Code Change

After editing any script or config file, always run validation before reporting done:
- Bash scripts: `bash -n <script>` (syntax) + `bash <script> --dry-run` if supported
- JSON files: `jq empty <file>`
- Never skip this step — making a change without testing it is incomplete work
