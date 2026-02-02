---
description: Git pull with rebase from remote repository
---

! git pull --rebase

Report the results of the git pull --rebase operation, including:
- Number of commits being rebased
- Any conflicts that need resolution
- Current branch status
- If conflicts occur, provide guidance on how to resolve them

Note: If there are conflicts, you'll need to resolve them manually, then use:
- `git add <resolved-files>` to stage resolved conflicts
- `git rebase --continue` to continue the rebase
- `git rebase --abort` to abort the rebase if needed
