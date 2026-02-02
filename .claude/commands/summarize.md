# Session Summary & Log

Summarize the current Claude Code session and log it to ~/.claude.txt with intelligent file management.

## Usage
```
/summarize [optional description]
```

## Arguments
- `optional description` - Custom context or details about what was accomplished

## What it does
1. **Analyze Session**: Reviews the conversation history using Claude's analysis
2. **Generate Summary**: Creates a structured summary of work accomplished
3. **Smart Logging**: Efficiently prepends to ~/.claude.txt with automatic file size management
4. **Context Addition**: Includes optional user description for additional context

## Examples
- `/summarize` - Auto-generate and log session summary
- `/summarize debugging GitHub Actions workflow issues` - Add specific context
- `/summarize fixed authentication, updated configs` - Brief description of changes

## Summary Content
The generated summary includes:
- **Key Tasks**: Main activities and accomplishments
- **Files Modified**: Code changes and new files created
- **Commands Run**: Important terminal commands executed
- **Technical Decisions**: Solutions implemented and approaches taken
- **Problems Resolved**: Issues identified and fixed

## File Management
- **Smart Prepending**: Uses efficient temporary file method for large logs
- **Size Management**: Automatically truncates files over 10,000 lines (keeps most recent 9,900)
- **Atomic Updates**: Ensures log file integrity during updates
- **Timestamp Format**: `MM/DD/YYYY HH:MM` for consistent chronological ordering

## Implementation
Uses `~/.claude/scripts/summarize.sh` which can operate in multiple modes:
- Auto-generation via `claude -p` (preferred)
- Manual summary with `--summary "text"`
- Prompt-only mode with `--prompt`
- Fallback to description-only if Claude CLI unavailable

## File Location
Logs stored in `~/.claude.txt` - review to track development progress across sessions.

Run the Bash tool: `~/.claude/scripts/summarize.sh "$ARGS"`

ARGUMENTS: $ARGS
