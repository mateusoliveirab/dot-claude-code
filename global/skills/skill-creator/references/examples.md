# Skill Examples

Concrete input/output examples for creating skills.

---

## Example 1: Simple Skill (no scripts)

**Input:** "I want a skill for writing database migration scripts for our Postgres DB"

**Output:**

```yaml
---
name: writing-migrations
description: Creates PostgreSQL migration scripts following team conventions. Use when writing DB migrations, schema changes, or data transforms.
metadata:
  author: Team
  version: "1.0.0"
---
```

```markdown
# Writing Migrations

Creates PostgreSQL migration scripts following team conventions.

## Workflow

- [ ] Analyze the schema change needed
- [ ] Generate migration file with timestamp
- [ ] Write UP migration
- [ ] Write DOWN migration (rollback)
- [ ] Validate SQL syntax
- [ ] Add to migrations directory

## File Format

ALWAYS use this naming: `YYYYMMDDHHMMSS_description.sql`

## Rules (LOW freedom)

- Every UP must have a matching DOWN
- Never use DROP without IF EXISTS
- Always wrap in transaction (BEGIN/COMMIT)
- Test rollback before committing

## Example

Input: Add email_verified column to users table
Output:
-- UP
BEGIN;
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_users_email_verified ON users(email_verified);
COMMIT;

-- DOWN
BEGIN;
DROP INDEX IF EXISTS idx_users_email_verified;
ALTER TABLE users DROP COLUMN IF EXISTS email_verified;
COMMIT;
```

---

## Example 2: Complex Skill (with references)

**Input:** "Create a skill for our API code review process with team standards"

**Output structure:**

```
reviewing-api-code/
├── SKILL.md                    # Workflow + key rules (~150 lines)
├── references/
│   ├── API_STANDARDS.md        # Detailed API conventions
│   └── SECURITY_CHECKLIST.md   # Security review points
└── scripts/
    └── lint-api.sh             # Automated checks
```

SKILL.md points to references:
```markdown
**API standards**: See [references/API_STANDARDS.md](references/API_STANDARDS.md)
**Security review**: See [references/SECURITY_CHECKLIST.md](references/SECURITY_CHECKLIST.md)
```
