# Stacked PRs — worked examples

## The `nytt-fra-huset` stack and the #80→#81 auto-close

**The stack** (hei-huset-admin), built in dependency order `A1 → (A2 ∥ B1) → B2`:

```
admin main  ←  B1 #79                  ←  B2 #80
               branch: feat/email-body-admin   branch: feat/email-body-ai
               (edit + persist email_body)      base: feat/email-body-admin   (AI generate button)
```
B2 sat on B1's branch, so #80's diff was just the AI-button layer.

**What went wrong.** The repo has `delete_branch_on_merge: true`. When **B1 #79 merged**, its branch `feat/email-body-admin` was auto-deleted. #80's base was that branch, so GitHub **closed #80** at the same instant (timeline shows a lone `closed` event, no `base_ref_changed` — it did **not** retarget). The head branch `feat/email-body-ai` survived.

**The recovery (what actually happened).** A new PR **#81** was opened reusing the surviving head branch `feat/email-body-ai` with base `main`, then rebased onto post-B1 `main` so its diff was AI-button-only again. Two minutes of churn + a lost review thread.

**What the cardinal rule would have done.** Before merging #79:
```bash
gh pr edit 80 --repo gjensidige/hei-huset-admin --base main   # retarget FIRST
gh pr merge 79 --squash --delete-branch                       # branch delete now can't close #80
git fetch origin && git rebase --onto origin/main <feat/email-body-admin tip> feat/email-body-ai
git push --force-with-lease                                   # #80's diff back to AI-button-only
```
#80 stays open the whole time. No reopen, no lost thread.

## Cross-repo dependency (not a git stack)

The same feature also needed `terraform-aks #2803` (GenAI role) and `boligvertikal-kubernetes-manifests #2727` (egress + `OPENAI_ENDPOINT`) before the AI button worked **at runtime**. These live in other repos — no shared branch, nothing to retarget. They are pure **merge ordering**: the infra/access PRs merge and deploy before (or with) the consumer, and the consumer's rollout is gated on them. The retarget/rebase mechanics in SKILL.md do not apply.
