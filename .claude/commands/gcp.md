---
description: Git commit with appropriate message and push to remote
argument-hint: "[optional: custom commit message]"
---

Create a git commit and push to the remote repository.

If the user provided a custom message in $ARGUMENTS, use that message (still append the Claude Code footer).
Otherwise, analyze the changes and create an appropriate commit message.

Follow these steps:
1. Run git status and git diff to see changes
2. Review recent commit messages for style consistency
3. Draft an appropriate commit message
4. Stage relevant files and create the commit with the Claude Code footer
5. Push to the remote repository
6. Verify with git status

Remember:
- Follow the project's commit message style
- Be concise (1-2 sentences)
- Focus on "why" rather than "what"
- DO NOT force push unless explicitly requested
- Check the remote branch before pushing
