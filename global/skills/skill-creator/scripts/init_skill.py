#!/usr/bin/env python3
"""
Skill Initializer - Creates a new skill directory with standard structure and templates.

Usage:
    python init_skill.py <skill-name> [--path <directory>]

Examples:
    python init_skill.py processing-pdfs
    python init_skill.py processing-pdfs --path ~/.claude/skills
"""

import sys
import argparse
import re
from pathlib import Path

SKILL_MD_TEMPLATE = '''---
name: {name}
description: TODO: Describe what this skill does and WHEN to use it. Include trigger keywords.
compatibility: TODO: List requirements (e.g., "Requires Python 3.8+, git")
metadata:
  author: TODO
  version: "1.0.0"
---

# {title}

TODO: One-line description of what this skill does.

## When to Use

Use this skill when:
- TODO: trigger condition 1
- TODO: trigger condition 2

Do NOT use when:
- TODO: anti-pattern 1

## Workflow

**Degree of freedom: MEDIUM** — follow the sequence, adapt content to context.

Copy and track progress:
- [ ] Step 1: TODO - analyze/understand the task
- [ ] Step 2: TODO - plan the approach
- [ ] Step 3: TODO - execute
- [ ] Step 4: Validate → if errors, fix and re-validate before continuing
- [ ] Step 5: TODO - finalize

## Examples

**Input:**
```
TODO: example input
```

**Output:**
```
TODO: expected output
```

## Key Principles

- TODO: principle 1
- TODO: principle 2

## References

- See [references/TODO.md](references/TODO.md) for detailed guidance
'''

REFERENCE_TEMPLATE = '''# {title} Reference

TODO: Detailed reference content for {name}.

## Section 1

TODO

## Section 2

TODO
'''

SCRIPT_TEMPLATE = '''#!/usr/bin/env bash
# TODO: describe what this script does
# Usage: bash {name}.sh [args]

set -e  # fail fast

# Check dependencies
# command -v git >/dev/null 2>&1 || { echo "❌ git is required but not installed."; exit 1; }

echo "TODO: implement {name}.sh"
'''


def validate_name(name: str) -> tuple[bool, str]:
    """Validate skill name against spec requirements."""
    if not re.match(r"^[a-z0-9-]+$", name):
        return False, "Name must be kebab-case (lowercase letters, digits, hyphens only)"
    if name.startswith("-") or name.endswith("-") or "--" in name:
        return False, "Name cannot start/end with hyphen or have consecutive hyphens"
    if len(name) > 64:
        return False, f"Name too long ({len(name)} chars). Maximum is 64."
    return True, ""


def to_title(name: str) -> str:
    """Convert kebab-case to Title Case."""
    return " ".join(word.capitalize() for word in name.split("-"))


def init_skill(name: str, base_path: Path) -> Path:
    """Create skill directory structure from templates."""
    valid, error = validate_name(name)
    if not valid:
        print(f"❌ Invalid skill name '{name}': {error}")
        sys.exit(1)

    skill_dir = base_path / name

    if skill_dir.exists():
        print(f"❌ Directory already exists: {skill_dir}")
        sys.exit(1)

    title = to_title(name)

    # Create directories
    (skill_dir / "references").mkdir(parents=True)
    (skill_dir / "scripts").mkdir(parents=True)
    (skill_dir / "assets").mkdir(parents=True)

    # Create SKILL.md
    skill_md = skill_dir / "SKILL.md"
    skill_md.write_text(SKILL_MD_TEMPLATE.format(name=name, title=title))

    # Create placeholder reference
    ref_file = skill_dir / "references" / "reference.md"
    ref_file.write_text(REFERENCE_TEMPLATE.format(name=name, title=title))

    # Create placeholder script
    script_file = skill_dir / "scripts" / "helper.sh"
    script_file.write_text(SCRIPT_TEMPLATE.format(name=name))
    script_file.chmod(0o755)

    # Print results
    print(f"\n✅ Skill '{name}' initialized at: {skill_dir}")
    print(f"\n📁 Structure:")
    for f in sorted(skill_dir.rglob("*")):
        indent = "  " * (len(f.relative_to(skill_dir).parts) - 1)
        print(f"   {indent}{'📄' if f.is_file() else '📁'} {f.name}")

    print(f"\n📝 Next steps:")
    print(f"   1. Edit {skill_dir}/SKILL.md — fill in all TODO items")
    print(f"   2. Add content to references/ and scripts/")
    print(f"   3. Validate: python quick_validate.py {skill_dir}")
    print(f"   4. Test in a fresh Claude session")
    print()

    return skill_dir


def main():
    parser = argparse.ArgumentParser(
        description="Initialize a new skill directory with standard structure"
    )
    parser.add_argument("name", help="Skill name in kebab-case (e.g., processing-pdfs)")
    parser.add_argument(
        "--path",
        default=".",
        help="Base directory where the skill folder will be created (default: current directory)",
    )
    args = parser.parse_args()

    base_path = Path(args.path).expanduser().resolve()
    if not base_path.exists():
        print(f"❌ Base path does not exist: {base_path}")
        sys.exit(1)

    init_skill(args.name, base_path)


if __name__ == "__main__":
    main()
