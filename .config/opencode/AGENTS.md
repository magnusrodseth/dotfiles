## Refactoring

<!-- rules:refactoring -->
Keep behavior-preserving refactoring separate from behavior changes so each can be reviewed independently.
When prerequisite refactoring materially simplifies the requested change, explain why and do it first.
Propose optional refactoring with its scope and benefit before including it.
Pause between phases only when I request a review checkpoint.
<!-- /rules:refactoring -->

## Writing Style

<!-- rules:writing-style -->
- **Never use em dashes** (—). Use alternatives: commas, parentheses, colons, semicolons, or separate sentences.
- Write plainly: one idea per sentence, active voice, present tense. Prefer the short common word over the long formal one. Cut hedges, filler, and throat-clearing.
- Keep prose sentences under ~25 words. Split a longer one in two.
- Use a table or a list when the content is a set of parallel facts.
- Full ASD-STE100 Simplified Technical English is opt-in, not the default. Use it when I ask for it, or when I run `/wait-what`.
<!-- /rules:writing-style -->

## No Slop

<!-- rules:no-slop -->
This applies to your own prose in every response, not only when I ask for it. `/humanize` is the deep on-demand pass over text I hand you; this is what you must not write in the first place.

**Write at the register first, because that is where the behaviour lives.** State the claim directly, then qualify it. Do not withhold it through a setup clause and deliver it as a payoff, and do not close every paragraph on its strongest phrasing instead of its most useful qualification. Punchy fragments, the emphatic colon, terminal emphasis and most of the phrase list below are surfaces of that one habit, so fixing them one at a time leaves the cause.

**The list below is a detector for what slips past that instruction, not the primary rule.** It is not exhaustive, and naming tokens is weaker than naming the register: ban an enumerated phrase and the habit moves into a synonym nobody listed. Use the register instruction to write, and this list to check.

- **Never emit citation artifacts.** `utm_source=chatgpt.com`, `oai_citation`, `:contentReference`, `turn0search`, `grok_render_citation`, `【NN†...】`, `[attached_file:N]`, placeholder dates (`2025-XX-XX`), placeholder URLs.
- **No negative parallelism.** "It's not just X, it's Y", "This isn't about X. It's about Y." State the claim in positive form.
- **No rule-of-three padding** when two or four is the real number, and no repeated sentence openings for rhythm.
- **No puffery or stakes inflation.** "game-changing", "revolutionary", "seamless", "a testament to", "stands as", "in today's fast-paced".
- **No weasel attributions.** "studies show", "experts say", "many companies", with no named source.
- **No superficial `-ing` tails.** "..., highlighting the importance of...", "..., underscoring the need for...". Cut the clause, or name the actual consequence.
- **No emphatic colon doing an em dash's job.** A colon is for a real list or a quote.
- **No craft-metaphor verbs or abstract metaphor nouns** standing in for the specific: *sanded down, stitched together, distilled, crystallized, surfaced, anchored*; *substrate, wedge, vector, nexus, bedrock, "API surface", endgame*. Say what actually happened. In-domain uses are correct and stay.
- **Name the mechanism, not the feeling.** "`.toSQL()` returns the exact string sent to the database", not "SQL you can read".
- **No chatbot scaffolding.** No "Great question!", "I hope this helps!", "Let me know if you need anything else", "You're absolutely right!", and no closing summary that restates what I just read.
- **Never invent a specific to sound concrete.** No fabricated numbers, sources, quotes or anecdotes. If the specific does not exist, say that, or leave it out.
- **Cut any sentence that would read identically in another project's docs.** It says nothing about this one.
<!-- /rules:no-slop -->

## GitHub References

<!-- rules:github-refs -->
- **Always render a GitHub reference as a markdown link, never as bare text.** This applies everywhere: chat replies, commit bodies, PR and issue descriptions, review comments, and docs. Covers issues, pull requests, workflow runs, commits, releases, discussions, projects and gists.
- Link text is the short human form, and the target is the full URL:
  - `#1731` → `[#1731](https://github.com/<owner>/<repo>/pull/1731)`
  - a workflow run → `[run 18234567890](https://github.com/<owner>/<repo>/actions/runs/18234567890)`
  - a commit → `[3bf4ae5b](https://github.com/<owner>/<repo>/commit/3bf4ae5b...)`
  - another repo's issue → `[gjensidige/skills#39](https://github.com/gjensidige/skills/issues/39)`
- Resolve the owner and repo from the working directory's `origin` remote when they are not stated. If you cannot determine the real URL, say so rather than inventing one; a wrong link is worse than a bare number.
- **One deliberate exception: text that GitHub itself renders.** Inside an issue body, PR description, or a comment posted to GitHub, a bare `#1731` already autolinks, so leave it bare there. The rule is about surfaces that do not autolink, which is everything else, including this chat.
- Do not link the same reference more than once in a short passage. First mention links, later mentions stay plain.
<!-- /rules:github-refs -->

## Calendar Event Titles

<!-- rules:calendar-titles -->
For meetings with other people, use a title that makes sense to every participant. Prefer names and purpose, for example `Magnus x Ola: Lunsj`.
<!-- /rules:calendar-titles -->

## Context7

<!-- rules:context7 -->
Before you write or debug code against a library, framework, SDK, CLI or cloud
API, load the `find-docs` skill and fetch the current docs, even for a library
you know well. It covers API syntax, configuration, version migration and
setup. Skip it for refactoring, business logic and general concepts. Without
the skill, run `npx ctx7@latest library <name> "<question>"`, then
`npx ctx7@latest docs <id> "<question>"`.
<!-- /rules:context7 -->
