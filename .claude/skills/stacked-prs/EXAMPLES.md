# Stacked PRs: worked examples

Identifiers here are deliberately generic. These examples come from private
client repos and this dotfiles repo is public, so repo names, PR numbers and
branch names are anonymised. The mechanic is the entire lesson; the identifiers
carried nothing.

## A two-PR hand-rolled chain and the auto-close on merge

This predates GitHub's native stacked pull requests (public preview 30.07.2026).
It is a **hand-rolled chain**: two ordinary PRs whose bases happened to point at
each other, with GitHub unaware they were related. The failure below is specific
to that world. In a native stack, merging the bottom retargets the layer above
automatically and #B would never have closed.

**The chain**, built in dependency order `B1 → B2`:

```
main  ←  B1 #A                    ←  B2 #B
         branch: feat/base-layer        branch: feat/child-layer
         (edit + persist a field)       base: feat/base-layer  (button built on it)
```

B2 sat on B1's branch, so #B's diff was just the child layer.

**What went wrong.** The repo has `delete_branch_on_merge: true`. When **B1 #A
merged**, its branch `feat/base-layer` was auto-deleted. #B's base was that
branch, so GitHub **closed #B** at the same instant (the timeline shows a lone
`closed` event and no `base_ref_changed`, so it did **not** retarget). The head
branch `feat/child-layer` survived.

**The recovery (what actually happened).** A new PR **#C** was opened reusing the
surviving head branch `feat/child-layer` with base `main`, then rebased onto
post-B1 `main` so its diff was child-layer-only again. Two minutes of churn plus
a lost review thread.

**What the cardinal rule would have done.** Before merging #A:

```bash
gh pr edit B --repo <owner>/<repo> --base main   # retarget FIRST
gh pr merge A --squash --delete-branch           # branch delete now can't close #B
git fetch origin && git rebase --onto origin/main <feat/base-layer tip> feat/child-layer
git push --force-with-lease                      # #B's diff back to child-layer-only
```

#B stays open the whole time. No reopen, no lost thread.

**What a native stack does instead.** `gh stack link <B1-branch> <B2-branch>`
would have made the pair a real stack. Then `gh stack merge <B1-PR> --yes`
merges the bottom and rebases #B onto `main` in the same operation. There is
nothing to retarget by hand, so nothing to forget.

## Cross-repo dependency (not a stack)

The same feature also needed two PRs in **other repos**: one granting a workload
role, and one opening egress plus setting an endpoint env var, before the
feature worked **at runtime**. These live in separate repos, so there is no
shared branch and nothing to retarget. They are pure **merge ordering**: the
infra and access PRs merge and deploy before (or with) the consumer, and the
consumer's rollout is gated on them. The retarget and rebase mechanics in
SKILL.md do not apply.
