---
name: t3-add-project
description: Points T3 Code at a GitHub repo, cloning it first if no clone exists on this machine, then registering it as a T3 project. Use when the user gives a GitHub URL or owner/repo and asks to add it to T3, set up a T3 project for it, or "get it into T3". Also use to back up T3 projects or scheduled tasks, or move them to another machine.
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

## Back up or move projects between machines

T3 keeps projects only in its database (`~/.t3/userdata/statev2.sqlite`, table `projection_projects`), not in a file. `scripts/t3-projects.py` reads it read-only and never writes to it.

The manifest never goes in git: dotfiles is public, and the manifest names private and employer repos (`.gitignore` already blocks `.t3/*`). Carry it in the personal 1Password account as the document `T3 projects manifest`.

```bash
S=~/.agents/skills/t3-add-project/scripts/t3-projects.py
M=~/dotfiles/.t3/projects.json   # git-ignored

# Source machine
python3 -I "$S" export -o "$M"
op document create "$M" --title "T3 projects manifest" --vault Private   # or `op document edit "T3 projects manifest" "$M"` if it exists

# Target machine
op document get "T3 projects manifest" --vault Private --out-file "$M" --force
python3 -I "$S" status
```

Use the `onepassword-cli` skill for the account flag: the document goes in the personal account, which every machine signed in to it can reach.

The manifest stores each project's `path` relative to `~`, its `origin` remote, and the settings `t3_project_update` accepts: `scripts`, `projectIcon`, `faviconPath`, `pinned`, `archived`, `autoPull`, `defaultThreadEnvMode`, `defaultModelSelection`. Omitted keys mean the T3 default.

`status` prints one line per project: `missing` (no folder), `cloned` (folder exists, not in T3) or `registered`.

Restore only the projects the user names, never the whole manifest unasked. Per project:

1. `missing` with a GitHub remote: run `add-project.sh <remote> --dest <path> --title <title>`. `missing` without a remote: ask the user.
2. `cloned`: run `add-project.sh` the same way, or call `t3_project_create` (`title`, `workspaceRoot`, `scripts`, `defaultModelSelection`).
3. Then call `t3_project_list` for the new `projectId` and `t3_project_update` with the remaining manifest settings.

Skip paths outside `~/dev` that point at worktrees (`~/.codex/worktrees/...`). They are local to the source machine.

## Back up or move scheduled tasks

Scheduled tasks also live only in T3's database (table `scheduled_tasks`). `scripts/t3-scheduled-tasks.py` reads it read-only. The export holds each task's title, schedule, prompt, project path, workspace strategy, model, modes and `enabled`. It leaves out the webhook token and secret, the thread id and the run history.

The manifest never goes in git: prompts can name private repos and people. Carry it in the personal 1Password account as the document `T3 scheduled tasks`, next to `T3 projects manifest`.

```bash
S=~/.agents/skills/t3-add-project/scripts/t3-scheduled-tasks.py
M=~/dotfiles/.t3/scheduled-tasks.json   # git-ignored

# Source machine, after creating or changing a task
python3 -I "$S" export -o "$M"
op document create "$M" --title "T3 scheduled tasks" --vault Private   # or `op document edit "T3 scheduled tasks" "$M"` if it exists

# Target machine, after the projects are restored
op document get "T3 scheduled tasks" --vault Private --out-file "$M" --force
python3 -I "$S" status
```

Use the `onepassword-cli` skill for the account flag, as for the projects manifest.

`status` prints `missing`, `differs` (with the fields that differ) or `present` per task, matched by title. It warns when a title occurs twice.

Restore only the tasks the user names. Per `missing` task:

1. Find the `projectId` whose workspace root is the task's `project_path` with `t3_project_list`. `~/.t3/scratch` is T3's *No project*: omit `projectId`. A project that is not registered yet: restore it first (section above).
2. Call `schedule_task` with `title`, `prompt`, `schedule` and `enabled` from the manifest. `thread_mode` maps to the binding: `new_thread` is `bindToCurrentThread: false`, `fresh_session` is `freshSession: true`. The export has no thread id, so a task bound to a thread comes back unbound: tell the user.
3. `schedule_task` cannot set the workspace strategy, model, runtime mode or interaction mode. Run `status` again and give the user the fields it still reports under `differs`, to set in T3's scheduled task settings.
4. A `webhook` task gets a new URL and secret on creation. Tell the user to update the sender.
