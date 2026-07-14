---
name: stacked-prs
description: Manage a stack of dependent pull requests (a chain where each PR's base is the branch below it, up to main) using git + gh. Use when working with stacked or dependent PRs, merging the bottom of a stack, retargeting a PR's base to main, propagating main or a review fix up a chain of branches, resolving conflicts across a PR stack, or recovering a stacked PR that was auto-closed when its base branch was deleted.
---

# Stacked PRs

A **stack** is a chain of PRs where each PR's base branch is the **head** branch of the one below it, down to a PR whose base is `main`:

```
main  ←  A (branch a)  ←  B (branch b)  ←  C (branch c)
         PR #A            PR #B            PR #C
         base: main       base: a          base: b
```

Each PR's diff shows only **its own layer** because it is compared against the branch below. The bottom is closest to main; the top is furthest.

**Map a stack before touching it:**
```bash
gh pr list --repo <owner/repo> --state open \
  --json number,title,headRefName,baseRefName,mergeable,reviewDecision
```
Chain them by `baseRefName == headRefName` down to the PR whose base is `main`. That order is the stack, bottom→top. Anything whose base is `main` is a bottom.

## The cardinal rule (read before merging anything in a stack)

> **GitHub closes — it does NOT reliably retarget — a PR whose base branch is deleted.** With `delete_branch_on_merge` enabled (common), merging the bottom PR deletes its branch, which silently **closes** the PR sitting on it.
>
> **So retarget the next PR up to `main` BEFORE you merge/delete the branch it sits on:**
> ```bash
> gh pr edit <next-up-PR> --repo <owner/repo> --base main
> ```

Retarget-before-merge makes the auto-close impossible — the dependent now sits on `main`, which never gets deleted. Do not rely on GitHub's documented auto-retarget; it does not fire when the branch is auto-deleted on merge (verified). Check the repo's setting with `gh api repos/<owner/repo> --jq .delete_branch_on_merge`.

## Operations

Pick by what the user is doing. Every destructive step (merge, force-push, branch delete, retarget) is **outward-facing**: confirm before each, and never force-push a branch someone else may be reviewing without saying so.

### status — map and report
Read-only. Run the `gh pr list` map above; print the chain bottom→top with each PR's base, `mergeable`, `reviewDecision`, and whether it is behind `main` (`gh pr view <n> --json ... ` or compare `git rev-list --count origin/main..origin/<branch>`). Surface any PR whose base is a branch that no longer exists (orphaned — see **recover**).

### sync — bring the stack current with main
`main` moved; propagate it up **bottom-up** with merges (not rebase — merging avoids force-pushing branches under review):
```bash
git fetch origin
# bottom first, then each branch into the next up the stack:
git checkout a && git merge origin/main   && git push      # bottom ← main
git checkout b && git merge a             && git push      # next  ← bottom
git checkout c && git merge b             && git push      # ...up the stack
```
Resolve each conflict **once, at the lowest layer where it arises**; the merge upward carries the resolution. Hand conflicts to the `merge-resolver` skill. Done when every branch is `behind=0` vs `main`.

### land — merge the bottom and propagate, safely
For `main ← a ← b`, to land the bottom `a` without closing `b`:
```bash
git fetch origin
ATIP=$(git rev-parse origin/a)                       # 1. capture bottom tip FIRST
gh pr edit <PR-b> --base main                        # 2. retarget dependent to main (cardinal rule)
gh pr merge <PR-a> --squash --delete-branch          # 3. merge bottom (branch deletion now can't close b)
git fetch origin
git rebase --onto origin/main "$ATIP" b              # 4. drop a's commits → b's diff = just b's layer
git push --force-with-lease                          # 5. (force needed: rebase rewrote b)
```
Then repeat from the new bottom up the stack. Rebase (step 4) is what keeps the landed PR's diff scoped to its own layer; the squash-merge of `a` is already in `main`, so replaying only `b`'s commits is correct. Hand any rebase conflicts to `merge-resolver`.

### recover — a stacked PR was closed/orphaned
The base branch was deleted, so GitHub closed the PR. The **head branch survives** (auto-delete only removes the *merged* PR's head). Recreate against `main` and clean the diff:
```bash
gh pr create --repo <owner/repo> --head <orphaned-branch> --base main --title "..." --body "..."
git fetch origin && git checkout <orphaned-branch>
git rebase --onto origin/main <former-base-tip-sha> <orphaned-branch>   # if the old base SHA is known
git push --force-with-lease
```
If the former base SHA is unknown, `git rebase origin/main` and drop the already-merged commits during the rebase. This is the cure; **land** is the prevention.

## Cross-repo dependencies are not git stacks

When the dependency spans repos (e.g. a schema PR in repo X must merge before a consumer PR in repo Y works at runtime), there is no shared branch to retarget. Treat it as **merge ordering only**: sequence the merges bottom-up across repos, and gate the consumer's deploy on the dependency. None of the retarget/rebase mechanics apply.

## Worked example

The `nytt-fra-huset` epic stack and the exact #80→#81 auto-close it caused (and how the cardinal rule prevents it) are in [EXAMPLES.md](EXAMPLES.md). Read it when you want a concrete walk-through.
