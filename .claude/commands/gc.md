---
description: Git commit with an appropriate commit message
argument-hint: "[optional: custom commit message]"
---

Create a git commit following the Git Safety Protocol and commit message conventions.

If the user provided a custom message in $ARGUMENTS, use that message (still append the Claude Code footer).
Otherwise, analyze the changes and create an appropriate commit message.

Follow these steps:
1. Run git status and git diff to see changes
2. Review recent commit messages for style consistency
3. Draft an appropriate commit message
4. Stage relevant files and create the commit
5. Verify with git status

Remember:
- Follow the project's commit message style
- Be concise (1-2 sentences)
- Focus on "why" rather than "what"
- Append the Claude Code footer
