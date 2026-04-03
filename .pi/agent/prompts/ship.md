---
description: Commit all changes and push to remote
---
## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Staged changes: !`git diff --cached --stat`
- Unstaged changes: !`git diff --stat`

## Task

1. Stage all changes with `git add -A`
2. Review the diff to understand what changed
3. Create a concise commit message (conventional commit format)
4. Commit the changes
5. Push to the current branch

Use the commit message format:

```txt
<type>: <short description>

<optional body if changes are complex>
```

IMPORTANT:
- Do NOT add "Co-Authored-By" or attribution footers
- Keep commit messages clean
- NEVER include line numbers in the commit message

If there are no changes to commit, inform me and do not create an empty commit.
