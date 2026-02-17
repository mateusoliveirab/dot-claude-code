#!/usr/bin/env python3
"""
Audit and scoring script for Agent Skills - evaluates a skill directory against
best practices from the skill-creator specification.

Usage:
    python audit_skill.py <skill_directory>

Example:
    python audit_skill.py ../git-commit
    python audit_skill.py ~/.claude/skills/processing-pdfs

Exit codes:
    0 - Production ready (score >= 80)
    1 - Needs improvement (score 60-79)
    2 - Requires refactor (score < 60)
    3 - Script error (invalid path, missing SKILL.md, etc.)
"""

import sys
import re
import json
from pathlib import Path

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False


# ---------------------------------------------------------------------------
# Category weights (must sum to 1.0)
# ---------------------------------------------------------------------------

WEIGHTS = {
    "frontmatter":   0.15,
    "documentation": 0.20,
    "workflow":      0.20,
    "examples":      0.15,
    "structure":     0.15,
    "scripts":       0.10,
    "cross_model":   0.05,
}

# Fields that are explicitly invalid in frontmatter
INVALID_FIELDS = {"auto_invoke", "auto-invoke", "trigger", "keywords", "tags"}

# Fields that are valid in frontmatter
ALLOWED_FIELDS = {"name", "description", "license", "allowed-tools", "metadata", "compatibility"}

# Degrees of freedom labels Claude should use
DOF_LABELS = {"LOW", "MED", "HIGH", "MEDIUM"}

# Reserved words not allowed in skill names
RESERVED_NAME_WORDS = {"anthropic", "claude"}


# ---------------------------------------------------------------------------
# Frontmatter parsing (yaml with regex fallback)
# ---------------------------------------------------------------------------

def extract_frontmatter(content: str) -> tuple[dict | None, str, str | None]:
    """
    Extract YAML frontmatter from content.

    Returns (frontmatter_dict, body, error_message).
    On parse failure, frontmatter_dict is None and error_message is set.
    """
    if not content.startswith("---"):
        return None, content, "No YAML frontmatter found (file must start with ---)"

    match = re.match(r"^---\n(.*?)\n---\n?(.*)", content, re.DOTALL)
    if not match:
        return None, content, "Invalid frontmatter format (opening --- found but no closing ---)"

    frontmatter_text = match.group(1)
    body = match.group(2)

    if HAS_YAML:
        try:
            data = yaml.safe_load(frontmatter_text)
            if not isinstance(data, dict):
                return None, body, "Frontmatter must be a YAML dictionary"
            return data, body, None
        except yaml.YAMLError as exc:
            return None, body, f"Invalid YAML in frontmatter: {exc}"
    else:
        # Regex fallback: extract simple key: value pairs (no nested support)
        data = {}
        for line in frontmatter_text.splitlines():
            kv = re.match(r"^(\w[\w-]*):\s*(.*)$", line)
            if kv:
                data[kv.group(1)] = kv.group(2).strip()
        return data, body, None


# ---------------------------------------------------------------------------
# Individual category scorers
# ---------------------------------------------------------------------------

def score_frontmatter(frontmatter: dict | None, parse_error: str | None) -> tuple[float, list[str]]:
    """
    Score frontmatter validity (0-100).
    Checks: valid YAML, required fields, naming convention, no invalid fields.
    """
    suggestions = []

    if frontmatter is None:
        suggestions.append(f"CRITICAL: {parse_error}")
        return 0.0, suggestions

    score = 100.0

    # Required fields
    if "name" not in frontmatter:
        suggestions.append("CRITICAL: Missing required field 'name' in frontmatter")
        score -= 40
    else:
        name = str(frontmatter["name"]).strip()
        if not re.match(r"^[a-z0-9-]+$", name):
            suggestions.append(
                f"Name '{name}' must be kebab-case (lowercase letters, digits, hyphens only)"
            )
            score -= 20
        elif name.startswith("-") or name.endswith("-") or "--" in name:
            suggestions.append(
                f"Name '{name}' cannot start/end with a hyphen or have consecutive hyphens"
            )
            score -= 15
        if len(name) > 64:
            suggestions.append(f"Name is too long ({len(name)} chars, max 64)")
            score -= 10
        for reserved in RESERVED_NAME_WORDS:
            if reserved in name.split("-"):
                suggestions.append(f"Name contains reserved word '{reserved}'")
                score -= 15

    if "description" not in frontmatter:
        suggestions.append("CRITICAL: Missing required field 'description' in frontmatter")
        score -= 40
    else:
        desc = str(frontmatter["description"]).strip()
        if not desc:
            suggestions.append("Description is empty -- must describe WHAT and WHEN to use the skill")
            score -= 30
        else:
            if "<" in desc or ">" in desc:
                suggestions.append("Description must not contain angle brackets (< or >)")
                score -= 10
            if len(desc) > 1024:
                suggestions.append(f"Description too long ({len(desc)} chars, max 1024)")
                score -= 10
            # Check for WHEN keyword (description should say when to use it)
            if "use when" not in desc.lower() and "when" not in desc.lower():
                suggestions.append(
                    "Description should explain WHEN to use the skill (include trigger context)"
                )
                score -= 10

    # Invalid fields
    invalid_found = set(frontmatter.keys()) & INVALID_FIELDS
    if invalid_found:
        suggestions.append(
            f"CRITICAL: Invalid frontmatter field(s): {', '.join(sorted(invalid_found))}. "
            f"Remove them -- they are not part of the spec."
        )
        score -= 35

    # Unknown fields (not invalid, just unrecognized)
    unknown = set(frontmatter.keys()) - ALLOWED_FIELDS - INVALID_FIELDS
    if unknown:
        suggestions.append(
            f"Unrecognized frontmatter field(s): {', '.join(sorted(unknown))}. "
            f"Allowed: {', '.join(sorted(ALLOWED_FIELDS))}"
        )
        score -= 10

    return max(0.0, score), suggestions


def score_documentation(skill_md_path: Path, content: str, body: str) -> tuple[float, list[str]]:
    """
    Score documentation quality (0-100).
    Checks: line count, conciseness, consistent terminology.
    """
    suggestions = []
    score = 100.0

    lines = content.splitlines()
    line_count = len(lines)

    if line_count > 500:
        suggestions.append(
            f"SKILL.md has {line_count} lines -- must be under 500. "
            f"Move detailed content to references/."
        )
        score -= 40
    elif line_count > 400:
        suggestions.append(
            f"SKILL.md has {line_count} lines -- approaching 500-line limit. "
            f"Consider moving content to references/."
        )
        score -= 15
    elif line_count > 300:
        suggestions.append(
            f"SKILL.md has {line_count} lines -- aim for 100-200 lines for core instructions."
        )
        score -= 5

    # Check for empty/stub sections (sections with only a heading and no content)
    heading_pattern = re.compile(r"^#{1,3} .+", re.MULTILINE)
    headings = heading_pattern.findall(body)
    if len(headings) == 0 and len(body.strip()) < 50:
        suggestions.append("SKILL.md body appears empty -- add workflow, examples, and key rules")
        score -= 30

    # Consistent terminology: look for mixed use of "skill" vs "command" vs "plugin"
    alt_terms = re.findall(r"\b(plugin|command|module)\b", body, re.IGNORECASE)
    if alt_terms:
        suggestions.append(
            f"Inconsistent terminology: found '{', '.join(set(t.lower() for t in alt_terms))}' "
            f"-- prefer 'skill' throughout"
        )
        score -= 10

    # Check for TODO placeholders left in body
    todos = re.findall(r"\bTODO\b", body)
    if todos:
        suggestions.append(
            f"Found {len(todos)} TODO placeholder(s) in body -- replace with real content"
        )
        score -= 15

    # Windows-style backslash paths
    if re.search(r"[A-Za-z0-9]\\[A-Za-z0-9]", body):
        suggestions.append(
            "Backslash paths detected -- use forward slashes for cross-platform compatibility"
        )
        score -= 5

    return max(0.0, score), suggestions


def score_workflow(body: str) -> tuple[float, list[str]]:
    """
    Score workflow design (0-100).
    Checks: checklists, feedback loops, degrees of freedom labels.
    """
    suggestions = []
    score = 100.0

    # Checklists: - [ ] items
    checklist_items = re.findall(r"- \[[ x]\]", body)
    if not checklist_items:
        suggestions.append(
            "CRITICAL: No checklist items found (- [ ]) -- "
            "add a step-by-step workflow checklist for multi-step processes"
        )
        score -= 40
    elif len(checklist_items) < 3:
        suggestions.append(
            f"Only {len(checklist_items)} checklist item(s) found -- "
            f"consider expanding the workflow with more concrete steps"
        )
        score -= 15

    # Feedback loops: look for explicit re-validation or loop language
    feedback_patterns = [
        r"feedback loop",
        r"re-validate",
        r"re-check",
        r"iterate",
        r"if.*fails?.*fix",
        r"fix.*and.*re",
        r"checkpoint",
    ]
    has_feedback = any(
        re.search(pat, body, re.IGNORECASE) for pat in feedback_patterns
    )
    if not has_feedback:
        suggestions.append(
            "No feedback loops found -- add validation checkpoints and fix-and-retry steps "
            "for quality-critical operations"
        )
        score -= 20

    # Degrees of freedom labels
    dof_found = re.findall(r"\b(LOW|MED|HIGH|MEDIUM)\b", body)
    if not dof_found:
        suggestions.append(
            "No degrees of freedom labels found (LOW/MED/HIGH) -- "
            "add explicit freedom levels per section so agents know how strictly to follow instructions"
        )
        score -= 20
    elif len(set(dof_found)) < 2:
        suggestions.append(
            f"Only one degree of freedom level used ({dof_found[0]}) -- "
            f"consider differentiating sections with LOW/MED/HIGH as appropriate"
        )
        score -= 5

    # Check for at least one workflow section heading
    if not re.search(r"^#{1,3}\s*(workflow|steps?|process|phase)", body, re.IGNORECASE | re.MULTILINE):
        suggestions.append(
            "No 'Workflow' section heading found -- add a dedicated workflow/steps section"
        )
        score -= 10

    return max(0.0, score), suggestions


def score_examples(body: str, skill_path: Path = None) -> tuple[float, list[str]]:
    """
    Score examples quality (0-100).
    Checks: input/output pairs, at least 1 concrete example.
    Also searches references/ for examples if not found in SKILL.md body.
    """
    suggestions = []
    score = 100.0

    # Combine body with references content for example detection
    combined_text = body
    refs_has_examples = False
    if skill_path:
        refs_dir = skill_path / "references"
        if refs_dir.is_dir():
            for ref_file in refs_dir.glob("*.md"):
                ref_content = ref_file.read_text(errors="replace")
                if re.search(r"\b(Input|Example input|Given)\b", ref_content, re.IGNORECASE) and \
                   re.search(r"\b(Output|Expected output|Result)\b", ref_content, re.IGNORECASE):
                    refs_has_examples = True
                    combined_text += "\n" + ref_content

    # Look for explicit Input/Output pairs
    input_markers = re.findall(r"\b(Input|Example input|Given)\b", combined_text, re.IGNORECASE)
    output_markers = re.findall(r"\b(Output|Expected output|Result)\b", combined_text, re.IGNORECASE)

    has_input_output = len(input_markers) >= 1 and len(output_markers) >= 1

    # Also look for example sections
    example_section = re.search(
        r"^#{1,3}\s*examples?", combined_text, re.IGNORECASE | re.MULTILINE
    )

    # Check if SKILL.md links to examples in references
    links_to_examples = bool(re.search(r"\[.*examples?.*\]\(references/", body, re.IGNORECASE))

    if not has_input_output and not example_section:
        suggestions.append(
            "CRITICAL: No examples found -- add at least 1 concrete input/output pair. "
            "Examples are the most effective way to calibrate agent behavior."
        )
        score -= 50
    elif not has_input_output:
        suggestions.append(
            "Examples section exists but no explicit Input/Output pairs found -- "
            "add labeled 'Input:' and 'Output:' pairs to clarify the transformation"
        )
        score -= 20

    # Check for minimum 1 code block (in combined text)
    code_blocks = re.findall(r"```", combined_text)
    if len(code_blocks) < 2:
        suggestions.append(
            "No code blocks found -- add concrete examples with code fences (```) "
            "to show exact input/output format"
        )
        score -= 15

    # Reward more than 1 example
    if len(input_markers) >= 2 and len(output_markers) >= 2:
        pass  # good, no deduction
    elif has_input_output:
        suggestions.append(
            "Only 1 example found -- consider adding 2-3 varied examples to cover "
            "different cases and calibrate agent style"
        )
        score -= 5

    # If examples are in references but not linked from SKILL.md, warn
    if refs_has_examples and not links_to_examples:
        suggestions.append(
            "Examples found in references/ but SKILL.md has no link to them -- "
            "add a markdown link so the agent can discover them"
        )
        score -= 5

    return max(0.0, score), suggestions


def score_structure(skill_path: Path, body: str) -> tuple[float, list[str]]:
    """
    Score directory and reference structure (0-100).
    Checks: references max 1-level deep, progressive disclosure, directory layout.
    """
    suggestions = []
    score = 100.0

    refs_dir = skill_path / "references"
    scripts_dir = skill_path / "scripts"
    assets_dir = skill_path / "assets"

    # references/ directory check
    if refs_dir.exists():
        # Check for nested subdirectories in references (multi-hop is forbidden)
        nested = [p for p in refs_dir.rglob("*") if p.is_dir()]
        if nested:
            suggestions.append(
                f"References contain subdirectories ({', '.join(str(n.name) for n in nested)}) -- "
                f"references must be exactly one level deep (no subdirectory navigation)"
            )
            score -= 25

        # Check that SKILL.md links to references using relative markdown links
        ref_files = list(refs_dir.glob("*.md"))
        if ref_files:
            links_in_body = re.findall(r"\[.*?\]\(references/[^)]+\)", body)
            if not links_in_body:
                suggestions.append(
                    f"references/ contains {len(ref_files)} file(s) but SKILL.md has no links to them -- "
                    f"add markdown links like [description](references/FILE.md)"
                )
                score -= 15
    else:
        # Not required, but if SKILL.md body is long, suggest creating references
        body_lines = len(body.splitlines())
        if body_lines > 200:
            suggestions.append(
                f"SKILL.md body is {body_lines} lines with no references/ directory -- "
                f"consider moving detailed content to references/ for progressive disclosure"
            )
            score -= 10

    # Check for multi-hop references in body (link -> another link -> another)
    # Heuristic: look for link-to-link language
    multi_hop = re.search(
        r"see\s+\[.*?\]\(references/.*?\).*?for.*?see\s+\[", body, re.IGNORECASE | re.DOTALL
    )
    if multi_hop:
        suggestions.append(
            "Possible multi-hop reference chain detected -- "
            "each reference should be self-contained (SKILL.md -> reference, not chain navigation)"
        )
        score -= 15

    # Discourage deeply nested markdown headings (h4+) in SKILL.md
    deep_headings = re.findall(r"^#{4,}", body, re.MULTILINE)
    if len(deep_headings) > 3:
        suggestions.append(
            f"Found {len(deep_headings)} level-4+ headings -- "
            f"flatten structure; deep nesting in SKILL.md often indicates content that belongs in references/"
        )
        score -= 10

    return max(0.0, score), suggestions


def score_scripts(skill_path: Path) -> tuple[float, list[str], bool]:
    """
    Score scripts quality (0-100).
    Checks: error handling, dependency checks.
    Returns (score, suggestions, scripts_exist).
    """
    suggestions = []
    scripts_dir = skill_path / "scripts"

    if not scripts_dir.exists():
        return 100.0, [], False

    script_files = [
        f for f in scripts_dir.iterdir()
        if f.is_file() and f.suffix in (".py", ".sh", ".bash") or (f.suffix == "" and f.is_file())
    ]
    if not script_files:
        return 100.0, [], False

    score = 100.0

    for script in script_files:
        try:
            src = script.read_text(errors="replace")
        except OSError:
            continue

        name = script.name

        # Check for shebang
        if not src.startswith("#!"):
            suggestions.append(
                f"scripts/{name}: Missing shebang line -- "
                f"add #!/usr/bin/env python3 or #!/usr/bin/env bash"
            )
            score -= 10

        if script.suffix == ".sh" or (script.suffix == "" and "bash" in src[:80]):
            # Bash: check for set -e or set -euo pipefail
            if not re.search(r"set -[a-z]*e[a-z]*", src):
                suggestions.append(
                    f"scripts/{name}: No 'set -e' found -- add 'set -e' for fail-fast error handling"
                )
                score -= 10

            # Bash: check for dependency/command checks
            if not re.search(r"command -v|which |type ", src):
                suggestions.append(
                    f"scripts/{name}: No dependency checks found -- "
                    f"add 'command -v tool' checks with actionable error messages"
                )
                score -= 10

        elif script.suffix == ".py":
            # Python: check for sys.exit on error paths
            if "sys.exit" not in src and "SystemExit" not in src:
                suggestions.append(
                    f"scripts/{name}: No sys.exit() found -- "
                    f"add explicit exit codes on error paths"
                )
                score -= 10

            # Python: check for try/except or explicit error handling
            if "try:" not in src and "except " not in src:
                suggestions.append(
                    f"scripts/{name}: No try/except found -- "
                    f"add error handling for file I/O and external calls"
                )
                score -= 10

            # Python: check for __main__ guard
            if '__name__ == "__main__"' not in src and "__name__ == '__main__'" not in src:
                suggestions.append(
                    f"scripts/{name}: No __main__ guard found -- "
                    f"wrap execution in 'if __name__ == \"__main__\":'"
                )
                score -= 5

        # Check for hardcoded magic numbers without comments
        magic = re.findall(r"(?<!\w)(?<!\.)(?<!#)\b([2-9]\d{2,})\b", src)
        if len(magic) > 2:
            suggestions.append(
                f"scripts/{name}: Possible magic numbers ({', '.join(magic[:3])}...) -- "
                f"document hardcoded values with inline comments"
            )
            score -= 5

    return max(0.0, score), suggestions, True


def score_cross_model(body: str, frontmatter: dict) -> tuple[float, list[str]]:
    """
    Score cross-model compatibility (0-100).
    Checks: no time-sensitive info, explicit structure for smaller models.
    """
    suggestions = []
    score = 100.0

    # Time-sensitive info patterns
    time_patterns = [
        r"\b(before|after|until|since)\s+(january|february|march|april|may|june|july|august"
        r"|september|october|november|december)\s+\d{4}",
        r"\b20\d{2}\b",          # year references like "2024", "2025"
        r"\bv\d+\.\d+\.\d+\b",   # exact version pins like v1.2.3
        r"\bcurrent(ly)?\s+(as of|in)\b",
        r"\bas of\s+\d{4}",
    ]
    for pat in time_patterns:
        hits = re.findall(pat, body, re.IGNORECASE)
        if hits:
            suggestions.append(
                "Time-sensitive information detected (year references, version pins, 'as of' dates) -- "
                "skills should be evergreen; remove or parameterize time-bound references"
            )
            score -= 20
            break  # one deduction per category

    # Explicit structure: check that instructions are structured for smaller models
    # Smaller models benefit from numbered lists, headers, explicit directives
    numbered_lists = re.findall(r"^\d+\.", body, re.MULTILINE)
    bullet_lists = re.findall(r"^[-*]\s", body, re.MULTILINE)
    headings = re.findall(r"^#{1,3} ", body, re.MULTILINE)

    structure_score = len(numbered_lists) + len(bullet_lists) + len(headings) * 2
    if structure_score < 5:
        suggestions.append(
            "Insufficient structural formatting -- "
            "add numbered lists, bullet points, and section headings so smaller models "
            "can parse instructions reliably"
        )
        score -= 25

    # Check for vague directives that confuse smaller models
    vague = re.findall(
        r"\b(appropriately|as needed|if applicable|as appropriate|use judgment)\b",
        body, re.IGNORECASE
    )
    if len(vague) > 3:
        suggestions.append(
            f"Found {len(vague)} vague directive(s) ('{vague[0]}', etc.) -- "
            f"replace with concrete conditions that smaller models can evaluate deterministically"
        )
        score -= 15

    return max(0.0, score), suggestions


# ---------------------------------------------------------------------------
# Overall audit runner
# ---------------------------------------------------------------------------

def audit_skill(skill_path_str: str) -> dict:
    """
    Run full audit on a skill directory.
    Returns a result dict with per-category scores and overall score.
    """
    skill_path = Path(skill_path_str).expanduser().resolve()

    if not skill_path.exists():
        return {
            "error": f"Path does not exist: {skill_path}",
            "skill_path": str(skill_path),
        }
    if not skill_path.is_dir():
        return {
            "error": f"Path is not a directory: {skill_path}",
            "skill_path": str(skill_path),
        }

    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        return {
            "error": f"SKILL.md not found in {skill_path}",
            "skill_path": str(skill_path),
        }

    content = skill_md.read_text(errors="replace")
    frontmatter, body, parse_error = extract_frontmatter(content)

    # Run all scorers
    fm_score, fm_suggestions = score_frontmatter(frontmatter, parse_error)
    doc_score, doc_suggestions = score_documentation(skill_md, content, body)
    wf_score, wf_suggestions = score_workflow(body)
    ex_score, ex_suggestions = score_examples(body, skill_path)
    st_score, st_suggestions = score_structure(skill_path, body)
    sc_score, sc_suggestions, scripts_exist = score_scripts(skill_path)
    cm_score, cm_suggestions = score_cross_model(body, frontmatter or {})

    categories = {
        "frontmatter": {
            "score": round(fm_score, 1),
            "weight": WEIGHTS["frontmatter"],
            "weighted_score": round(fm_score * WEIGHTS["frontmatter"], 2),
            "suggestions": fm_suggestions,
        },
        "documentation": {
            "score": round(doc_score, 1),
            "weight": WEIGHTS["documentation"],
            "weighted_score": round(doc_score * WEIGHTS["documentation"], 2),
            "suggestions": doc_suggestions,
        },
        "workflow": {
            "score": round(wf_score, 1),
            "weight": WEIGHTS["workflow"],
            "weighted_score": round(wf_score * WEIGHTS["workflow"], 2),
            "suggestions": wf_suggestions,
        },
        "examples": {
            "score": round(ex_score, 1),
            "weight": WEIGHTS["examples"],
            "weighted_score": round(ex_score * WEIGHTS["examples"], 2),
            "suggestions": ex_suggestions,
        },
        "structure": {
            "score": round(st_score, 1),
            "weight": WEIGHTS["structure"],
            "weighted_score": round(st_score * WEIGHTS["structure"], 2),
            "suggestions": st_suggestions,
        },
        "scripts": {
            "score": round(sc_score, 1),
            "weight": WEIGHTS["scripts"],
            "weighted_score": round(sc_score * WEIGHTS["scripts"], 2),
            "suggestions": sc_suggestions,
            "note": "N/A (no scripts/ directory)" if not scripts_exist else None,
        },
        "cross_model": {
            "score": round(cm_score, 1),
            "weight": WEIGHTS["cross_model"],
            "weighted_score": round(cm_score * WEIGHTS["cross_model"], 2),
            "suggestions": cm_suggestions,
        },
    }

    # Overall weighted score
    overall = sum(cat["weighted_score"] for cat in categories.values())
    overall = round(overall, 1)

    # Interpret overall score
    if overall >= 80:
        grade = "production-ready"
    elif overall >= 60:
        grade = "needs-improvement"
    else:
        grade = "requires-refactor"

    # Collect all suggestions across CRITICAL gates
    critical_gates = ["frontmatter", "documentation", "workflow", "examples", "structure"]
    critical_failures = []
    for gate in critical_gates:
        cat = categories[gate]
        if cat["score"] < 60:
            critical_failures.append(
                f"{gate} (score: {cat['score']}/100)"
            )

    # Flatten all suggestions
    all_suggestions = []
    for cat_name, cat in categories.items():
        for s in cat["suggestions"]:
            all_suggestions.append(f"[{cat_name.upper()}] {s}")

    return {
        "skill_path": str(skill_path),
        "skill_md_lines": len(content.splitlines()),
        "overall_score": overall,
        "grade": grade,
        "critical_gate_failures": critical_failures,
        "categories": categories,
        "all_suggestions": all_suggestions,
    }


# ---------------------------------------------------------------------------
# Human-readable output
# ---------------------------------------------------------------------------

CATEGORY_LABELS = {
    "frontmatter":   "Frontmatter      (15%)",
    "documentation": "Documentation    (20%)",
    "workflow":      "Workflow Design  (20%)",
    "examples":      "Examples         (15%)",
    "structure":     "Structure        (15%)",
    "scripts":       "Scripts          (10%)",
    "cross_model":   "Cross-Model       (5%)",
}

GRADE_DESCRIPTIONS = {
    "production-ready":  "Production ready",
    "needs-improvement": "Needs improvement",
    "requires-refactor": "Requires refactor",
}


def score_bar(score: float, width: int = 20) -> str:
    """Render a simple ASCII progress bar."""
    filled = int(score / 100 * width)
    return "[" + "#" * filled + "." * (width - filled) + "]"


def print_report(result: dict) -> None:
    """Print a human-readable audit report to stdout."""
    if "error" in result:
        print(f"ERROR: {result['error']}")
        return

    overall = result["overall_score"]
    grade = result["grade"]
    categories = result["categories"]

    print()
    print("=" * 60)
    print(f"  Skill Audit Report")
    print(f"  Path: {result['skill_path']}")
    print("=" * 60)
    print()

    # Per-category scores
    print("Category Scores:")
    print("-" * 60)
    for cat_key, label in CATEGORY_LABELS.items():
        cat = categories[cat_key]
        s = cat["score"]
        bar = score_bar(s)
        note = f"  [{cat['note']}]" if cat.get("note") else ""
        flag = ""
        if s < 60:
            flag = "  CRITICAL"
        elif s < 80:
            flag = "  WARNING"
        print(f"  {label}  {bar}  {s:5.1f}/100{flag}{note}")

    print("-" * 60)

    # Overall
    bar = score_bar(overall, width=30)
    print(f"\n  Overall Score:  {bar}  {overall:.1f}/100")
    print(f"  Grade:          {GRADE_DESCRIPTIONS.get(grade, grade)}")

    if grade == "production-ready":
        print("  Status:         Ready for use in production skill libraries.")
    elif grade == "needs-improvement":
        print("  Status:         Address the suggestions below before deploying.")
    else:
        print("  Status:         Significant rework required before this skill is usable.")

    # Critical gate failures
    if result["critical_gate_failures"]:
        print()
        print("  Critical Gate Failures (must all pass):")
        for failure in result["critical_gate_failures"]:
            print(f"    - {failure}")

    # Suggestions
    all_suggestions = result["all_suggestions"]
    if all_suggestions:
        print()
        print("Actionable Suggestions:")
        print("-" * 60)
        for i, s in enumerate(all_suggestions, 1):
            # Wrap long lines at 78 chars
            prefix = f"  {i}. "
            indent = " " * len(prefix)
            words = s.split()
            lines = []
            current = prefix
            for word in words:
                if len(current) + len(word) + 1 > 78:
                    lines.append(current)
                    current = indent + word
                else:
                    current = current + (" " if current != prefix else "") + word
            lines.append(current)
            print("\n".join(lines))
    else:
        print()
        print("  No suggestions -- skill meets all criteria.")

    print()
    print("=" * 60)
    print()


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python audit_skill.py <skill_directory>")
        sys.exit(3)

    result = audit_skill(sys.argv[1])
    print_report(result)

    # Also emit JSON to a .audit.json sidecar next to SKILL.md (optional)
    # Uncomment the lines below if you want a persistent JSON report:
    # audit_json = Path(sys.argv[1]) / ".audit.json"
    # audit_json.write_text(json.dumps(result, indent=2))

    # Print JSON to stderr so it can be captured separately if needed
    print(json.dumps(result, indent=2), file=sys.stderr)

    if "error" in result:
        sys.exit(3)

    grade = result["grade"]
    if grade == "production-ready":
        sys.exit(0)
    elif grade == "needs-improvement":
        sys.exit(1)
    else:
        sys.exit(2)
