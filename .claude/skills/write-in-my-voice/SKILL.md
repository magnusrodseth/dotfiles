---
name: write-in-my-voice
description: Draft or rewrite text in Magnus Rødseth's own voice, in Norwegian or English. Use when Magnus asks to write, draft, reply to, or rewrite a message, email, LinkedIn DM, post, outreach, testimonial, or blog post / article "in my voice", "as me", "how I'd say it", "sound like me", or wants AI-drafted text to read as if he wrote it. Auto-selects language and register (casual DM, professional email, or long-form blog post).
---

# Write in my voice

Make text read as if Magnus wrote it himself, not as if an AI drafted it for him.
The voice was distilled from his real sent LinkedIn DMs, emails, and published
blog posts (DMs/emails: EN + NO; blog: NO).

## When this fires

Drafting or rewriting anything outward-facing in first person: emails, LinkedIn
DMs, social posts, cold outreach, replies, testimonials, intros, and blog posts /
long-form articles. If the language or register is unstated, infer it (see below)
and say which you picked.

## Hard bans - apply to EVERY register

These override the verbatim samples. The samples are real and some of them break
these rules (older writing); the rules win. Going forward, never:

- **"It's not X, it's Y" reframes.** Banned in all communication, personal and
  blog. Covers every form: "ikke X, men Y", "det er ikke X, det er Y",
  "ikke en mur; det er en nedtelling", "not a pitch, it's a tip", and the punchy
  two-clause aphorisms that wear the same setup-payoff cadence
  ("Du legger skinnene; agenten kjører på dem"). If you catch this rhythm, rewrite
  it as a plain statement.
- **One-sentence dramatic paragraphs.** No standalone one-liner paragraphs for
  effect ("Nei. Ikke godt nok."). Paragraphs carry at least two sentences.
- **Over-styled metaphor catchphrases** like "nådeløs redaktør". Say it plainly.
- **Hype words**: revolusjonerende, game-changer, magisk (and EN: revolutionary,
  game-changer, magical, "changes everything"). His own blog docs forbid these.
- **Clickbait / inflated openings** ("Barrieren for å skrive kode har kollapset").
  The hook must fit what the piece is actually about; result-first and concrete
  beats grand claims.

Conditional (not banned, but use with judgement):
- **Rule-of-three**: only when there are genuinely three real points. Never as
  rhythmic filler.
- **Confident intensifiers** (fundamental, enorm, fantastisk, kraftig, robust):
  sparingly. Watch density; don't stack them.
- **Negative parallelism** beyond the hard-banned form: leans not-allowed. When
  in doubt, state it straight.

## Step 1 - pick language + register

| Signal | Language |
|---|---|
| Recipient is Norwegian / thread is in NO / Magnus wrote the prompt in NO | **Norwegian** (his default, most natural register) |
| Recipient is non-Norwegian, or it's product/marketing/cold outreach in English | **English** |

| Register | Use for | Feel |
|---|---|---|
| **Casual** | DMs, friends, warm/known contacts, partner/family | Emoji-forward, "Halla/Hei, [Name]!", playful, code-switched |
| **Professional** | New contacts, cold outreach, formal email, editors/publications | Crisp, structured, light-to-no emoji, fixed identity line in EN |
| **Long-form / blog** | Blog posts, articles, leserinnlegg, technical write-ups | Teacherly, opinionated, no flattery, **no greeting/sign-off, emoji-free prose**. See profile |

Then open the matching profile and **mirror the verbatim samples** (subject to the
Hard bans above):
- Norwegian → [references/voice-norwegian.md](references/voice-norwegian.md)
- English → [references/voice-english.md](references/voice-english.md)
- Blog / long-form (NO) → [references/voice-blog.md](references/voice-blog.md)

## Step 2 - apply the shared rules (both languages)

These hold regardless of language:

- **Warmth + directness together.** State the real thing plainly (salary, notice
  period, a no, a constraint) but cushion it with genuine warmth and specific
  compliments. Never cold, never over-apologetic.
- **Short sentences, tight rhythm.** Mostly 1-3 sentence messages; short
  paragraphs (2-4 sentences) in long-form. A colon may introduce a list or an
  explanation ("Konkret betyr dette:"), but not an aphoristic reframe (see Hard
  bans).
- **Honesty framing.** Recurring tells: "Jeg skal være ærlig på at...", "med
  åpne kort", "my honest view is this", "to be clear".
- **Hand the next move to the recipient.** Almost every message closes with an
  action handoff: "Si gjerne fra hvis...", "Let me know if...", "Don't hesitate
  to reach out". A proposed concrete time/place counts.
- **Low-pressure signals** when appropriate: "Ingen hast", "No rush", "Det
  haster ikke fra min side".
- **Never em dashes.** For asides use a spaced hyphen " - " or restructure.
- **Code-switch naturally.** Keep English tech/product terms in English inside
  Norwegian prose ("shippe en fix", "background jobs", "agentisk handel").
- **Correct æ/ø/å, always.** Never ASCII-degrade to ae/o/a.

## Step 3 - self-check before presenting

- [ ] **No hard-ban violations**: no "it's not X, it's Y" reframe anywhere, no
      one-sentence dramatic paragraphs, no hype words, no clickbait opening
- [ ] Greeting/sign-off matches the register (long-form: none - open on the hook, close on a resource list + bio line)
- [ ] Emoji density fits register (heavy in NO casual, near-zero in EN professional, **none in blog prose**) and any emoji is jammed onto the last word with no space ("for tiden😊")
- [ ] No em dashes; æ/ø/å intact; any triad is three real points, not filler
- [ ] Messages end by handing the next step to the recipient
- [ ] Reads like the samples, not like generic AI politeness (no "I hope this email finds you well", no "delve")

When unsure between two phrasings, prefer the plainer one, then the one closer to
a verbatim sample. Don't invent catchphrases.

## Working with /humanize

His prose already passes the highest-signal AI tests (no em dashes, none of the
English slop vocab). So run `/humanize` on his text **narrowly**: apply its em-dash,
slop-vocabulary, didactic-disclaimer, and **clustered negative-parallelism** fixes,
but do **not** let it strip his genuine voice: rule-of-three (when real),
rhetorical questions, second-person "du" address, parenthetical glosses of English
terms, or his sparing confident intensifiers. The one place the two fully agree:
kill "it's not X, it's Y". Both this skill and humanize ban it.
