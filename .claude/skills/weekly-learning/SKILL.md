---
name: weekly-learning
description: Mines the past week of agent sessions, merged PRs and dotfiles changes for post-worthy learnings, and logs 3-5 ideas in the vault idea bank. Use for "ukens lærdom", "weekly learning", or the weekly scheduled run.
disable-model-invocation: true
---

# Weekly learning

Produce **ideas, not drafts**. Magnus picks which idea to flesh out, then uses `write-linkedin-post`. Never post or send anything.

Idea bank: `~/dev/personal/vault/Projects/LinkedIn-innlegg - Idébank.md`.

## 1. Window

Default to the 7 days ending today, unless a range is given. Read the idea bank first, and skip anything already listed there.

## 2. Gather receipts

Cover every source below. Grep first, then read around the hits; never read a whole transcript.

| Source | How |
|---|---|
| Dotfiles | `git -C ~/dotfiles log --since=<date> --stat`. Read the diff of every added or removed rule, skill and hook. |
| PRs | `gh search prs --author @me --merged-at ">=<date>" --json repository,title,url,body --limit 50`. Read the bodies that describe a bug, a reversal or a design choice. |
| Claude Code sessions | `~/.claude/projects/*/*.jsonl` modified in the window. Skip dirs that start with `-private-tmp`. |
| Codex sessions | `~/.codex/sessions/YYYY/MM/DD/*.jsonl` in the window. |
| Vault | `git -C ~/dev/personal/vault log --since=<date> --name-only` for meetings and notes. |

Session signals worth grepping: corrections from Magnus ("nei", "feil", "ikke det", "stopp", "hvorfor"), reverts, repeated retries of the same command, a tool the agent routed around, and "it turns out".

## 3. Pick candidates

Use the retro lens: what Magnus learned, tried or ran into this week, and what evidence backs it. Any kind qualifies, for example:

- **Tips og triks**: a rule, hook, skill, prompt or CLI habit that changed behaviour.
- **Fallgruver**: a tool that misled the agents, a bug, a wrong assumption, a revert.
- **Shipping**: a feature, review finding or architecture decision from a PR.
- **Ways of working**: parallel agents, review flow, planning, how work is split.
- **Nyheter**: a release or tool he actually tried this week. Hands-on use is the receipt; hype alone is not.

Every candidate needs a **receipt**: his own number, a commit, a PR, or a concrete incident. No receipt, no idea. Reference pattern: the rtk post had "34M reported vs 2M real" and "840 `rtk proxy` calls".

## 4. Confidentiality filter

Work repos (`gjensidige/*`, Pureservice, Aprende/Eksamensportalen, askable) and private life: keep only the general pattern. Never include unreleased product details, customer or user data, internal system names, colleagues, security details or business figures. The durable-agents post is the model: two projects, no names.

Apply [[Fagformidling under arbeidsgivers merkevare]] (`Notes/` in the vault): the idea rests on his own documented experience, and vendor claims stay labelled as vendor claims.

## 5. Write to the idea bank

Append one section in Norwegian, with correct æ/ø/å:

```md
## Uke <ISO week> (<DD.MM>–<DD.MM.YYYY>)

### <Working title>
- **Krok:** <one sentence a reader would stop on>
- **Kvittering:** <PR link, commit, path or number>
- **Hvorfor andre bryr seg:** <the general lesson>
- **Kanal:** LinkedIn | Slack internt
- **Sensitivitet:** <what to leave out, or "ingen">
```

Write 3-5 ideas. A thin week gives fewer ideas, never padded ones. Commit only the idea bank: `git commit -m "linkedin: ukens lærdom uke <NN>" -- "Projects/LinkedIn-innlegg - Idébank.md"`.

## 6. Reply

List the working titles with one line each, and the path to the idea bank. Stop there.
