---
name: address-copilot-review
description: |
  Take a GitHub pull request through Copilot's code review end to end: check out the PR, fetch Copilot's summary and inline review comments, investigate the codebase to judge each one, apply agreed fixes, commit and push, then reply to and resolve each Copilot thread. Pauses for approval before any GitHub write and asks before dismissing a comment it disagrees with. Use when the user asks to "address the Copilot review", "go through Copilot comments", handle/triage a Copilot PR review, or reply to and resolve Copilot review threads on a PR.
version: 0.1.0
---

# Address Copilot review

Take a PR through Copilot's code review end to end: check it out, read every Copilot comment, investigate the code to judge each one, apply the fixes you agree on, commit and push, then reply to and resolve each thread.

Mechanics worth knowing up front: GitHub's REST API posts replies, but **thread resolution is GraphQL only**.

## Golden rules

- **Pause before any GitHub write.** Investigate and present a per-comment assessment first; only apply fixes / commit / push / reply / resolve after the user approves.
- **Ask on every disagreement.** If a comment looks wrong, not applicable, or a false positive, surface it and let the user decide. Never silently dismiss or resolve it.
- Match each fix to the comment it addresses. One commit referencing the review is usually enough.
- Only resolve threads you actually addressed (or that the user told you to close). Leave disputed threads open unless the user says otherwise.

## Workflow

### 1. Check out the PR
Accepts a PR number, URL, or defaults to the current branch's PR.
```bash
gh pr checkout <PR>
gh pr view <PR> --json number,title,headRefName,url
```

### 2. Read the Copilot review
Summary review (the overview + finding count):
```bash
gh pr view <PR> --json reviews \
  --jq '.reviews[] | select(.author.login=="copilot-pull-request-reviewer") | .body'
```
Inline findings (the actionable comments; top-level only, skip replies):
```bash
gh api repos/{owner}/{repo}/pulls/<PR>/comments --paginate \
  --jq '.[] | select(.user.login=="Copilot" and .in_reply_to_id==null)
        | {id, path, line, body}'
```
Each finding's `id` is its REST databaseId. You need it both to reply and to map to the thread for resolving.

### 3. Investigate and judge
For each finding, read the referenced `path:line` plus enough surrounding context to confirm or refute the claim. Classify each as **agree** (real, worth fixing), **disagree** (wrong / not applicable / false positive), or **needs clarification**.

### 4. Present and get approval
Show the user a per-comment verdict with the proposed fix (or the reason to push back). **Ask about every disagreement.** Wait for approval before touching GitHub.

### 5. Fix, commit, push
Apply the agreed fixes. Verify they compile / lint / test where applicable. Then:
```bash
git add -A && git commit -m "fix: address Copilot review on <subject>"
git push
```

### 6. Reply, then resolve each thread
Reply to a finding (use its databaseId from step 2; reference the pushed SHA):
```bash
gh api repos/{owner}/{repo}/pulls/<PR>/comments/<COMMENT_ID>/replies \
  -f body="Fixed in <sha>. <what changed>"
```
Resolution is GraphQL only. Fetch thread node IDs and map them back to your comment IDs:
```bash
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)
gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
    reviewThreads(first:100){ nodes{
      id isResolved comments(first:1){ nodes{ databaseId path } } } } } }
}' -f owner="$OWNER" -f repo="$REPO" -F pr=<PR>
```
Match each thread by its first comment's `databaseId` (it equals the `id` from step 2), then resolve:
```bash
gh api graphql -f query='
mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } } }' \
  -f id=<THREAD_NODE_ID>
```

## Notes

- `{owner}`/`{repo}` placeholders resolve automatically inside `gh api` REST paths; GraphQL needs them passed explicitly (the `OWNER`/`REPO` capture above).
- If Copilot left only a summary and no inline comments, there's nothing to reply to or resolve. Just relay the summary.
- Keep replies short: what was wrong, what changed, the commit SHA. The reply is the audit trail for why the thread is resolved.
