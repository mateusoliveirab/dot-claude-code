# Scripts

This directory contains executable scripts that support the skill.

## Available Scripts

### helper.sh

Main helper script for [describe purpose].

**Usage**:
```bash
helper.sh [options] <command>
```

**Commands**:
- `command1` - Description
- `command2` - Description

**Options**:
- `-v, --verbose` - Enable verbose output
- `-d, --dry-run` - Show what would be done
- `-h, --help` - Show help

**Examples**:
```bash
# Basic usage
./helper.sh command1

# With verbose output
./helper.sh --verbose command1

# Dry run (no changes)
./helper.sh --dry-run command2
```

## Script Guidelines

All scripts in this directory should:

1. **Be self-contained** - Document dependencies clearly
2. **Handle errors gracefully** - Exit with helpful messages
3. **Support dry-run mode** - When applicable
4. **Use consistent formatting** - Follow existing patterns
5. **Be executable** - `chmod +x script.sh`

## Adding New Scripts

1. Copy `helper.sh` as template
2. Update header comments
3. Implement commands
4. Test thoroughly
5. Update this README
