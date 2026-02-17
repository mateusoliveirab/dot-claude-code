# Workflows Reference

How to structure the step-by-step execution logic of a skill.

## Pattern Types

| Pattern | Best For | Key Feature |
|---------|----------|-------------|
| Sequential | Linear multi-phase tasks | Validation checkpoints between phases |
| Conditional | Tasks with branching paths | Decision tree with clear conditions |
| Validation-First | Error-prone operations | Pre-checks before every action |
| Resumption | Long-running or interruptible tasks | Checklist state tracking |

---

## Sequential Workflow Pattern

Linear pipeline where each phase has a validation checkpoint before proceeding.

### Structure

```markdown
### Phase 1: {Name}
1. {Step}
2. {Step}
- Checkpoint: {what must be true to continue}

### Phase 2: {Name}
1. {Step}
- Checkpoint: {what must be true to continue}
```

### Example: PDF Processing (5 phases)

```markdown
### Phase 1: Input Validation
1. Verify file exists and is a valid PDF
2. Check file size (max 50MB)
- Checkpoint: file readable, under size limit

### Phase 2: Content Extraction
1. Extract text from all pages
2. Identify tables and images
- Checkpoint: extracted text is non-empty
  - If EMPTY: retry with OCR fallback
  - If STILL EMPTY: report failure with diagnostic info

### Phase 3: Transformation
1. Convert to markdown, reconstruct tables
- Checkpoint: output is valid markdown

### Phase 4: Quality Check
1. Compare page count vs extracted sections
2. Verify no empty sections or encoding issues
- Checkpoint: all sections populated

### Phase 5: Output
1. Write to destination, report summary
```

---

## Conditional Workflow Pattern

Tasks that branch based on input or context.

### Example: Content Generation Skill

```markdown
### Step 1: Detect Mode
- If target file does NOT exist --> CREATE mode
- If target file exists --> EDIT mode

### CREATE Mode
1. Determine content type, generate outline
2. Write full content, validate against style guide

### EDIT Mode
1. Read existing content, identify sections to modify
2. Preserve unchanged sections, apply edits
3. Validate output matches original structure

### Step Final: Write file, report changes
```

### Writing Clear Conditions

| Good Condition | Bad Condition | Why |
|----------------|---------------|-----|
| `If file exists at {path}` | `If appropriate` | Objectively testable |
| `If line count > 100` | `If file is large` | Precise threshold |
| `If language is TypeScript` | `If it looks like TS` | Deterministic check |
| `If user specified --force` | `If user wants to override` | Explicit flag |

---

## Validation-First Pattern

Every action is preceded by a check. Prevents cascading failures.

Structure: `Pre-check --> If fails: stop/fix --> Action --> Post-check --> If fails: rollback/retry`

### Example: Database Migration Skill

```markdown
### Step 1: Validate Migration File
- Pre-check: file exists with valid SQL syntax
- If INVALID --> report syntax errors, stop
- Action: parse into up/down statements
- Post-check: both statements present
- If MISSING DOWN --> warn: not reversible

### Step 2: Check Current State
- Pre-check: database is reachable
- If UNREACHABLE --> report connection error, stop
- Action: read current schema version
- Post-check: version is one behind migration
- If MISMATCH --> suggest running pending migrations first

### Step 3: Apply Migration
- Pre-check: no active transactions blocking DDL
- If BLOCKED --> report blocking queries, stop
- Action: execute UP in a transaction
- Post-check: schema version incremented
- If FAILED --> execute DOWN, report error
```

**Impact:** Validation-first catches 70-90% of issues before they cause broken outputs.

---

## Resumption Pattern

For tasks that may be interrupted or span multiple invocations.

Use a checklist to track completion state. On resumption: check which steps are done, skip them, resume from first incomplete.

### Example: Multi-File Refactoring

```markdown
- [ ] Identify all files matching pattern
- [ ] Create backup branch
- [ ] Transform file 1/N ... N/N
- [ ] Run tests
- [ ] Report results

Resumption: branch exists --> skip creation. File transformed --> skip.
Always re-run tests. Output: `[PROGRESS] {completed}/{total} files`
```

---

## Good vs Bad Workflow Steps

**Bad -- vague:** `1. Analyze the code 2. Make improvements 3. Test everything`
Problem: "analyze" how? "improvements" to what? Not actionable.

**Good -- specific:** `1. Read all .ts files in src/ 2. Find functions >50 lines 3. Extract repeated blocks into helpers 4. Verify tests pass`

**Bad -- no error handling:** `1. Read config 2. Parse JSON 3. Update field 4. Write file`

**Good -- explicit error paths:**

```markdown
1. Read config file
   - If NOT FOUND --> create with default template
2. Parse JSON
   - If INVALID --> report error with line number, stop
3. Update target field
   - If FIELD MISSING --> add with default value
4. Write file
   - If WRITE FAILS --> report permissions error
```

---

## Quick Decision Checklist

1. Straight pipeline? --> **Sequential**
2. Behavior changes based on input? --> **Conditional**
3. Failures common or costly? --> **Validation-First**
4. Task may be interrupted? --> **Resumption**
5. Multiple concerns? --> Combine patterns
