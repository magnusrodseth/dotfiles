---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git push:*), Bash(git log:*), Bash(git branch:*)
description: Commit all changes and push to remote
model: claude-haiku-4-5
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Staged changes: !`git diff --cached --stat`
- Unstaged changes: !`git diff --stat`

## Task

1. Stage all changes with `git add -A`
2. Review the diff to understand what changed
3. Create a concise commit message that describes the changes (use conventional commit format if appropriate)
4. Commit the changes
5. Push to the current branch

Use the commit message format:

```txt
<type>: <short description>

<optional body if changes are complex>
```

If there are no changes to commit, inform me and do not create an empty commit.
