---
name: gh-image
description: Upload local images to GitHub and get back ready-to-paste markdown (user-attachments URLs) for embedding in issues, PRs, comments, READMEs, gists, or Discussions, via the gh image CLI extension (drogers0/gh-image). Use when the user wants to attach/embed/upload an image or screenshot into a GitHub issue/PR/comment, mentions "gh image", "user-attachments URL", "include the screenshots in the issue", or asks to file an issue/PR with an image. For locating macOS screenshots first, see the screenshots skill.
license: MIT
compatibility: opencode
user-invokable: true
metadata:
  scope: global
  tools: gh
---

# gh-image

GitHub has no public image-upload API. The web comment box uses an internal endpoint that mints `https://github.com/user-attachments/assets/<uuid>` URLs. The `gh image` extension (`drogers0/gh-image`) replays that flow from the terminal, so you can embed images in GitHub markdown without leaving the CLI. Private-repo uploads stay private (the asset's visibility inherits the **target repo**).

For finding/curating macOS screenshots in `~/screenshots/` before uploading, see the **screenshots** skill — this skill is about the upload tool itself and works with *any* image path.

## Quick start

```bash
# One-time install
gh extension list | grep -q 'drogers0/gh-image' || gh extension install drogers0/gh-image

# Upload (repo inferred from the current git remote)
gh image screenshot.png
# -> ![screenshot.png](https://github.com/user-attachments/assets/…)

gh image a.png b.png --repo owner/repo   # multiple files / explicit repo
```

Each successful upload prints one `![name](url)` line to **stdout**; errors go to stderr and the process exits non-zero (other files in the batch still upload). Capture stdout and paste the markdown into the target body.

## Workflow: file an issue/PR/comment with images

1. **Curate first.** Read each image with the Read tool; upload only the ones that show the point. Never batch-dump.
2. **Upload** the keepers; collect the returned markdown URLs.
3. **Embed.** Either inline with command substitution, or build a body file:
   ```bash
   gh issue create --repo owner/repo --title "…" --body "$(cat <<EOF
   Summary text.

   ### Before
   $(gh image before.png --repo owner/repo)

   ### After
   $(gh image after.png --repo owner/repo)
   EOF
   )"
   ```
   For existing items: `gh issue view N --json body -q .body` → append a `## Screenshots` section pairing each label with its URL → `gh issue edit N --body-file …`. Same shape for `gh pr edit` and `gh pr comment --body-file`.
4. **Group** related shots under `###` sub-headings; one short label each.

## Authentication

`gh image` reads the `user_session` cookie from your browser (Chrome · Brave · Chromium · Edge · Firefox · Opera · Safari) — separate from `gh auth` (which it also uses, for repo-ID lookup). Verify and inspect:

```bash
gh image check-token            # prints the authenticated username; exit 0 = valid
gh image extract-token          # prints the raw session token to stdout
```

Override resolution order (first wins): `--token <value>` → `GH_SESSION_TOKEN` env → browser cookie. Prefer the env var over `--token` (flags are visible in `ps aux`).

> **Security:** a `user_session` cookie is *full account access*, not a scoped PAT — treat it like a password. Don't echo it into shared logs/repos. For CI, use a dedicated bot account with `GH_SESSION_TOKEN` as a scoped environment secret.

## Requirements & limits

- **Write access to the target repo** — the upload token is only issued to users who can write there.
- A supported browser with a *live* GitHub session, or `GH_SESSION_TOKEN`.
- `gh` CLI installed and authenticated.
- Visibility inherits the target repo: upload **to the same repo** where the issue/PR lives. Don't upload to repo A and embed in repo B — other viewers may get 403.
- Undocumented internal API; may change without notice.

## Troubleshooting

| Symptom | Cause → fix |
|---|---|
| `uploadToken not found on repo page — do you have write access?` | Most often **not actually an access problem**. Common causes: (1) **SAML/SSO org** — your browser `user_session` isn't SSO-authorized for that org right now: open the repo in that browser, complete the SSO prompt, retry. (2) The cookie was read from a browser/profile logged into a *different* GitHub account or not logged in — run `gh image check-token` to see who you are. (3) Session expired — re-login in the browser. (4) Genuinely lack write access — confirm with `gh api repos/OWNER/REPO --jq .permissions`. |
| `gh: image: unknown command` | `gh extension install drogers0/gh-image` |
| `401 / authentication required` | Session invalid/expired: re-login in the browser, or pass `GH_SESSION_TOKEN`. (`gh auth login` fixes the repo-ID lookup, not the upload cookie.) |
| Keychain prompt on macOS (first use) | Click **Always Allow** so `gh image` can read the browser cookie-encryption key. |
| Wrong repo detected | Pass `--repo owner/repo`, or run from inside the repo so `origin` is auto-detected. |
| Filename starts with `-` | Separate with `--`: `gh image -- -shot.png` |

## How it works (for debugging)

Resolve `user_session` → fetch the repo page to scrape an `uploadToken` from its JS payload → request an S3 upload policy from `/upload/policies/assets` → upload the file to S3 with the presigned fields → finalize the asset with GitHub → print `![name](url)`. The "uploadToken not found" error fails at step 2, which is why it's almost always a session/SSO problem rather than the file.
