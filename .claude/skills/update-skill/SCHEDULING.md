# Collecting Feedback and Wiring the Loop

How to store feedback so a batch exists to act on, and how to put the loop on a schedule so maintenance actually happens.

## The feedback notepad (lowest-friction start)

The simplest source is a running notepad per skill. When a skill misbehaves or a teammate gripes, append one dated line. Do not fix anything yet, just capture.

Convention for this dotfiles repo:

```
~/dotfiles/.claude/skills/<skill-name>/FEEDBACK.md
```

Append-only, newest at the bottom:

```markdown
# Feedback: <skill-name>

- 2026-06-29: read-up-on dumped 40 files instead of summarizing; wanted the conclusion only.
- 2026-06-30: same skill re-read files I'd already shown it. (2nd report of over-fetching)
```

When `/update-skill` runs, it reads the whole file, clusters, acts on what clears the rubric, then clears the resolved lines and leaves the deferred ones.

`FEEDBACK.md` is scratch state, not skill content. Gitignore it (or keep it deliberately, your call), but never let it count toward the skill's own length.

## Other feedback sources

- **GitHub.** For a team skill committed to a repo, pull issue and PR comments that mention the skill. A small script (`gh issue list`, `gh pr list --search`, or the GraphQL API) that dumps them to text is enough. Look for repeated friction and for label toggling (a teammate flipping the same label on and off is a signal the skill's automation is wrong).
- **Slack.** Aggregate thread replies where people correct the skill's output. The correction itself ("link the docs whenever you note documentation") is the feedback.
- **The user's recollection.** Often the fastest source. Ask: "What has annoyed you about this skill in the last week or two?" and treat the answers as reports subject to the same two-data-point rule.

## Putting it on a schedule

The point of a schedule is to lower friction: a draft improvement that lands on your desk weekly gets reviewed; an improvement you have to remember to start does not.

Cadence: weekly is a sane default. Long enough to fill a batch window, short enough that drift never gets far.

Mechanisms:

- **Claude Code routines / scheduled agents.** A cron-style routine that runs `/update-skill <name>`, reads the feedback source, and opens a draft PR.
- **A plain cron job** invoking the agent in a container (e.g. a Docker-based runner) that can clone the repo, run the skill, and push a branch.
- **Whatever scheduler is already in your stack** (Codex automations, Warp's Oz, GitHub Actions on a `schedule:` trigger).

The scheduled run should stop at a **draft PR**, never an auto-merge. The agent gathers the batch, runs the rubric, and proposes. A human reviews, tweaks, and ships. That review step is where overfitting gets caught.

## What a scheduled run produces

A good draft PR contains:

1. The clustered feedback it acted on (so a human can sanity-check the evidence).
2. The rubric verdicts (change / defer / reject with reasons).
3. The single coherent edit to the skill.
4. The deferred bucket, untouched, for next time.
