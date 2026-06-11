---
name: address-review
description: |
  Take a GitHub pull request's code review feedback end to end: check out the PR, fetch review summaries and unresolved inline threads from any reviewer (bots like Copilot and humans alike), investigate the codebase to judge each comment, apply agreed fixes, commit and push, then reply to each thread and resolve where appropriate. Pauses for approval before any GitHub write, asks before dismissing a comment it disagrees with, and leaves human-opened threads for the human to resolve unless told otherwise. Use when the user asks to "address the review", "address review comments", "go through the PR feedback", "address the Copilot review", handle/triage a PR review, or reply to and resolve review threads on a PR.
version: 0.2.0
---

# Address PR review

Take a PR's review feedback end to end: check it out, read every unresolved review thread (from bots and humans), investigate the code to judge each one, apply the fixes you agree on, commit and push, then reply to each thread and resolve where appropriate.

Mechanics worth knowing up front: GitHub's REST API posts replies, but **thread resolution is GraphQL only**. The GraphQL `reviewThreads` query is the single source of truth here; each thread's first comment carries a `databaseId` that equals the REST comment `id`, which is what you reply to.

## Golden rules

- **Pause before any GitHub write.** Investigate and present a per-comment assessment first; only apply fixes / commit / push / reply / resolve after the user approves.
- **Ask on every disagreement.** If a comment looks wrong, not applicable, or a false positive, surface it and let the user decide. Never silently dismiss or resolve it. This applies doubly to human reviewers: never push back on a colleague's comment autonomously.
- **Bot threads get resolved; human threads don't (by default).** After fixing and replying, resolve bot-opened threads. For human-opened threads, reply with what changed but leave resolution to the human, since many teams treat "who opened it resolves it" as etiquette and branch protection may require their sign-off. The user can override with "resolve everything".
- Match each fix to the comment it addresses. One commit referencing the review is usually enough.
- Only resolve threads you actually addressed (or that the user told you to close). Leave disputed threads open unless the user says otherwise.

## Known bot reviewers

| Bot | Inline comment login | Summary review login |
|---|---|---|
| GitHub Copilot | `Copilot` | `copilot-pull-request-reviewer` |

Copilot uses two different logins depending on the endpoint; filtering by only one of them misses half the picture. Other review bots (CodeRabbit, Sourcery, etc.) typically use a single `*[bot]` login. Treat any login ending in `[bot]` or matching the table as a bot for resolution etiquette.

## Workflow

### 1. Check out the PR
Accepts a PR number, URL, or defaults to the current branch's PR.
```bash
gh pr checkout <PR>
gh pr view <PR> --json number,title,headRefName,url
```

### 2. Discover reviewers and decide scope
```bash
gh pr view <PR> --json reviews --jq '[.reviews[].author.login] | unique'
```
- **No reviewer named by the user**: address all unresolved threads from everyone.
- **Reviewer named** ("address the Copilot review", "address Jonas's comments"): filter threads to that login (for Copilot, the inline login `Copilot`).

### 3. Fetch the review feedback
Summary reviews (overview text; substitute the reviewer's login, or drop the `select` to see all):
```bash
gh pr view <PR> --json reviews \
  --jq '.reviews[] | select(.author.login=="copilot-pull-request-reviewer") | .body'
```
Unresolved inline threads, all reviewers, one call (this also yields the thread node IDs needed to resolve later):
```bash
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)
gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
    reviewThreads(first:100){ nodes{
      id isResolved isOutdated path
      comments(first:1){ nodes{ databaseId author{login} body } } } } } }
}' -f owner="$OWNER" -f repo="$REPO" -F pr=<PR> \
  --jq '.data.repository.pullRequest.reviewThreads.nodes | map(select(.isResolved==false))'
```
Per thread: `id` is the GraphQL node ID (for resolving), and `comments.nodes[0].databaseId` is the REST comment id (for replying). `isOutdated` means the commented line has since changed; the finding may already be addressed, so check before re-fixing.

### 4. Investigate and judge
For each thread, read the referenced `path` plus enough surrounding context to confirm or refute the claim. Classify each as **agree** (real, worth fixing), **disagree** (wrong / not applicable / false positive), or **needs clarification**.

### 5. Present and get approval
Show the user a per-comment verdict with the proposed fix (or the reason to push back), grouped by reviewer when there is more than one. **Ask about every disagreement.** Wait for approval before touching GitHub.

### 6. Fix, commit, push
Apply the agreed fixes. Verify they compile / lint / test where applicable. Then:
```bash
git add -A && git commit -m "fix: address review feedback on <subject>"
git push
```
Mention the reviewer in the message when addressing a single reviewer's feedback.

### 7. Reply, then resolve where appropriate
Reply to a thread (use its first comment's `databaseId` from step 3; reference the pushed SHA):
```bash
gh api repos/{owner}/{repo}/pulls/<PR>/comments/<COMMENT_ID>/replies \
  -f body="Fixed in <sha>. <what changed>"
```
Then resolve **bot threads only** (and any threads the user explicitly told you to resolve), using the thread `id` from step 3:
```bash
gh api graphql -f query='
mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } } }' \
  -f id=<THREAD_NODE_ID>
```
Human threads stay open with your reply on them unless the user said to resolve everything.

## Notes

- `{owner}`/`{repo}` placeholders resolve automatically inside `gh api` REST paths; GraphQL needs them passed explicitly (the `OWNER`/`REPO` capture above).
- If a reviewer left only a summary and no inline comments, there's nothing to reply to or resolve. Just relay the summary.
- Keep replies short: what was wrong, what changed, the commit SHA. The reply is the audit trail for the thread.
- More than 100 threads: add pagination on `reviewThreads` (`after:` cursor), though in practice 100 covers nearly every PR.
- Scope is GitHub review threads only. Plain issue comments on the PR and other platforms (GitLab, Gerrit) are out of scope.
