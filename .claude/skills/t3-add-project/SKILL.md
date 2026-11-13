---
name: t3-add-project
description: Points T3 Code at a GitHub repo, cloning it first if no clone exists on this machine, then registering it as a T3 project. Use when the user gives a GitHub URL or owner/repo and asks to add it to T3, set up a T3 project for it, or "get it into T3".
---

# Add a T3 project from a GitHub repo

Run the script. It is idempotent: an existing clone is reused, and an existing project is left alone.

```bash
bash ~/.agents/skills/t3-add-project/scripts/add-project.sh <github-url|owner/repo> [--dest <path>] [--title <title>]
```

It does this, in order:

1. Parses `owner/repo` from an https URL, ssh URL or shorthand.
2. Finds an existing clone: any checkout in `~/dev/*/` or `~/dev/*/*/` whose `origin` points to that repo.
3. With no clone, runs `gh repo clone` into `~/dev/work/<repo>` for the `gjensidige` owner, else `~/dev/personal/<repo>`. `--dest` overrides the path.
4. Registers the path with `t3 project add` unless `t3 thread list --project <path>` already resolves it. The title defaults to the repo name.

It prints `repo`, `path`, `cloned`, `registered` (`yes` or `already`) and `branch`.

## When it stops

- **Path holds another repo or non-git files**: ask the user where it goes, then rerun with `--dest`.
- **`gh repo clone` fails**: report the error. Check `gh auth status` for private repos.
- **T3 CLI not found or server stopped**: inside T3, register with `t3_project_create` (`title`, `workspaceRoot`) instead. Otherwise tell the user to open T3 Code.

## Done when

The script exits 0 and the user gets the path, whether it was cloned, and whether the project is new. Do not pull or switch branches in an existing clone. Mention a dirty tree or a non-default branch so the user knows what T3 will open.
