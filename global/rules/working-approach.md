---
description: Working approach and task execution guidelines
---

# Working Approach

- Always ask clarifying questions BEFORE creating detailed implementations.
- Suggest and discuss options before executing.
- Do not implement improvements or features that were not requested. If you identify something that could be improved, suggest it for discussion instead of implementing directly.
- Focus only on what was asked.

## Validation Loop After Fixes

After making any fix or change (especially after debugging errors):
1. Test the changed endpoint/feature directly (curl, browser, MCP, etc.)
2. Test edge cases (empty input, missing fields, error paths)
3. Only report done after all validations pass

## Fast Mode Usage

- Use fast mode (`/fast`) for simple tasks: code review, bug fixes, refactoring, small edits
- Use thinking mode (default) for complex tasks: architecture decisions, new features, debugging, planning
