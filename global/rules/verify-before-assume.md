---
name: verify-before-assume
description: Never write or apply facts you don't know for certain — verify first
metadata:
  type: feedback
---

If a fact can be verified, verify it — don't assume it.

If it's in the codebase, read it. If it's in the docs, search for it. If it's an external name (env var, config key, CLI flag, API param, model ID), look it up before writing it. Only ask the user if it genuinely can't be found.

A plausible-sounding answer that's wrong is worse than a pause to check.
