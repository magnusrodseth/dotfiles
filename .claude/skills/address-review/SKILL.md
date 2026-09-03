---
name: address-review
description: "Take a GitHub PR's review feedback end to end: fetch unresolved threads from bots and humans, judge each, apply fixes, push, then reply and resolve. Use for \"address the review\" or \"go through the PR feedback\"."
version: 0.3.0
---

# Address PR review

Take a PR's review feedback end to end: check it out, read every unresolved review thread (from bots and humans), investigate the code to judge each one, apply the fixes you agree on, commit and push, then reply to each thread and resolve where appropriate.

Mechanics worth knowing up front: GitHub's REST API posts replies, but **thread resolution is GraphQL only**. The GraphQL `reviewThreads` query is the single source of truth here; each thread's first comment carries a `databaseId` that equals the REST comment `id`, which is what you reply to.

## Golden rules

- **Pause before any GitHub write.** Investigate and present a per-comment assessment first; only apply fixes / commit / push / reply / resolve after the user approves.
- **Ask on every disagreement.** If a comment looks wrong, not applicable, or a false positive, surface it and let the user decide. Never silently dismiss or resolve it. This applies doubly to human reviewers: never push back on a colleague's comment autonomously.
- **Bot threads get resolved; human threads don't (by default).** After fixing and replying, resolve bot-opened threads. For human-opened threads, reply with what changed but leave resolution to the human, since many teams treat "who opened it resolves it" as etiquette and branch protection may require their sign-off. The user can override with "resolve everything".
- **A comment can be right and still not belong in this PR.** Review bots regularly raise something genuinely new: a failure mode nobody had considered, a missing index, an auth hole in a neighbouring function. "Agree" and "apply here" are separate decisions. Surface those as their own class (see step 4) and let the user choose between fixing now and opening a follow-up issue. Silently widening the PR to absorb them is how a two-file fix becomes unreviewable.
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
Capture the head SHA at the same time and keep it for the rest of the run:
```bash
HEAD_SHA=$(gh pr view <PR> --json headRefOid -q .headRefOid)
```
Every piece of feedback belongs to a commit. A review left against an earlier head may
already be addressed, and after you push in step 6 the whole picture shifts. Anchoring to
`HEAD_SHA` is what stops you re-fixing something twice or reporting a stale verdict as
current.
- **No reviewer named by the user**: address all unresolved threads from everyone.
- **Reviewer named** ("address the Copilot review", "address Jonas's comments"): filter threads to that login (for Copilot, the inline login `Copilot`).

### 3. Fetch the review feedback
Summary reviews (overview text; substitute the reviewer's login, or drop the `select` to see all):
```bash
gh pr view <PR> --json reviews \
  --jq '.reviews[] | select(.author.login=="copilot-pull-request-reviewer") | .body'
```

**Sort bot summaries by `updated_at`, never by `created_at`.** Most review bots post one
summary comment and then *edit it in place* on every subsequent review, so the newest
verdict lives in the oldest comment. Sorting by creation time reads a stale body and
concludes there is nothing left to address:
```bash
gh api --paginate "repos/{owner}/{repo}/issues/<PR>/comments?per_page=100" \
  --jq '[.[] | select(.user.login | test("copilot|coderabbit|greptile|sourcery"; "i"))]
        | sort_by(.updated_at) | last | {updated_at, body}'
```
Read that body for actionable items too. A bot's summary regularly names something that
never became an inline thread, so a run driven only by `reviewThreads` misses it.
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
For each thread, read the referenced `path` plus enough surrounding context to confirm or refute the claim. Classify each as:

| Verdict | Meaning | Action |
|---|---|---|
| **agree** | Real, and in scope for this PR | Fix it here |
| **agree, out of scope** | Real, but it is a pre-existing problem or a new concern this PR did not introduce | Ask the user: fix now, or open a follow-up issue and link it in the reply |
| **disagree** | Wrong, not applicable, or a false positive | Ask the user before dismissing. Never resolve silently |
| **needs clarification** | The comment is ambiguous or you cannot tell without context you do not have | Ask |

The middle row is the one that gets mishandled. A bot that has read the whole file will
point at things the diff did not cause, and some of them are worth knowing about. Treat
"this is a real finding" and "this belongs in this PR" as two separate questions, and put
the second one to the user.

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

### 8. Re-request review, once

Only if the user wants another pass from the bot.

**Check whether a review is already running before asking for one.** A push usually
re-triggers the bot on its own, and a trigger comment posted on top of an in-flight review
gets a duplicate run or is dropped:
```bash
gh pr checks <PR> --json name,state \
  --jq '.[] | select(.name | test("copilot|greptile|coderabbit"; "i")) | .state'
```
`PENDING` or `IN_PROGRESS` means wait; post nothing.

When it completes, re-read against the **new** head, not the one from step 2:
```bash
NEW_SHA=$(gh pr view <PR> --json headRefOid -q .headRefOid)
```
Threads whose latest review predates `NEW_SHA` have not seen your fix yet, and reporting
them as unaddressed is wrong. Anything genuinely new here is fresh feedback on the fixes
you just pushed, so re-enter at step 4 and get approval again. Do not loop unattended.

## Notes

- `{owner}`/`{repo}` placeholders resolve automatically inside `gh api` REST paths; GraphQL needs them passed explicitly (the `OWNER`/`REPO` capture above).
- A summary with no inline comments has nothing to reply to or resolve, but it is not nothing. Read it for findings that never became threads, run them through step 4 like any other comment, and relay the rest.
- Keep replies short: what was wrong, what changed, the commit SHA. The reply is the audit trail for the thread.
- More than 100 threads: add pagination on `reviewThreads` (`after:` cursor), though in practice 100 covers nearly every PR.
- Scope is GitHub review threads only. Plain issue comments on the PR and other platforms (GitLab, Gerrit) are out of scope.
