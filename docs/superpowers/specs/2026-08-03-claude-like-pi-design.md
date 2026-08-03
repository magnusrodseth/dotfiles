# Claude-like global Pi experience

**Date:** 2026-08-03

**Status:** Implemented 2026-08-03. Two deviations from the design below, both
recorded inline: the local extension needed `.pi/.gitignore` restructured to be
trackable at all, and the approved footer collided with a second `setFooter`
owner that the design did not account for (`compact-footer.ts` in
`git:github.com/magnusrodseth/pi-extensions`), now filtered out per-resource.

## Goal

Make Pi feel like Magnus's current minimal Claude Code setup while retaining Pi's GitHub Copilot access to `gpt-5.6-sol`.

The global experience should:

- show a concise animated Pi identity header;
- keep tool activity compact while work is running;
- expose full tool evidence with `Ctrl+O`;
- show only thinking effort, branch, and remaining context around the composer;
- suppress startup diagnostics that have already been handled elsewhere;
- update installed Pi packages automatically without delaying an interactive launch.

This applies globally to every interactive Pi session.

## Research findings

Claude Code's official interactive-mode documentation describes `Ctrl+O` as its detailed transcript viewer and documents its compact activity, effort, composer, and footer interactions. Magnus's installed Claude Code 2.1.220 uses the fullscreen renderer and a deliberately minimal custom status line. Pi already reserves `Ctrl+O` for tool-output expansion and exposes extension APIs for replacing the header and footer, adding widgets, changing the working indicator, and controlling tool expansion.

Relevant primary sources:

- [Claude Code interactive mode](https://code.claude.com/docs/en/interactive-mode)
- [Claude Code fullscreen renderer](https://code.claude.com/docs/en/fullscreen)
- [Pi settings](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/settings.md)
- [Pi extensions](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/extensions.md)
- [Pi package management](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/packages.md)

The closest existing UI package is [`cc-my-pi`](https://github.com/timvdhoorn/cc-my-pi). Its source was reviewed locally:

- it provides compact Claude-style built-in tool rows, grouped tool calls, rich diffs, a spinner, queue steering, image paste, and `Ctrl+O` expansion;
- all 205 source tests pass after installing dependencies, and TypeScript typechecking passes;
- its published npm 1.2.0 tarball is unusable because it omits `extensions/queue-steer/` ([upstream issue #1](https://github.com/timvdhoorn/cc-my-pi/issues/1));
- therefore the package must be installed from its audited GitHub source, not npm;
- its transitive production dependency tree currently reports one moderate and two high denial-of-service/image-processing advisories. None is directly authored by the package, but the updater should continue taking upstream dependency fixes;
- it overlaps with `@heyhuynhgiabuu/pi-diff`, so the existing standalone diff package must be removed to avoid competing renderers.

`pi-claude-style-scroll` can approximate Claude's fullscreen pinned composer, but version 0.3.3 only declares compatibility through Pi 0.80 while this machine runs Pi 0.83. It is excluded from the initial implementation. The stable interface is more important than alternate-screen parity.

## Considered approaches

### 1. Audited UI package plus a small local adapter — selected

Use `cc-my-pi` for tool rendering and interaction behavior. Disable its over-detailed bundled header and footer, replacing them with a small dotfiles-owned extension that renders only the approved information.

This keeps custom code small while preserving control over the exact global layout.

### 2. Build the whole experience locally

Reimplement tool renderers, grouping, diffs, queue steering, spinner, header, and footer in the dotfiles repository.

This avoids third-party runtime code but duplicates a large, actively evolving extension and creates a substantial maintenance burden.

### 3. Configure stock Pi only

Use `quietStartup` and Pi's existing `Ctrl+O` behavior without custom rendering.

This cannot achieve grouped one-line tool activity, the approved header, the minimal footer, or Claude-like completion feedback.

## Approved interface

### Header

The header uses an animated logo, not Claude's crab logo. cc-my-pi's own header
is disabled, so the logo is drawn locally. A π mascot was tried first and
rejected: at terminal resolution it read as "a bar on two legs" rather than as
the glyph. The shipped logo is a shell prompt in a rounded frame, after Lucide's
`terminal` icon, which says "coding agent" more directly than a maths symbol.
Proportions follow the source SVG: chevron spanning y=5..17, underline at y=19
from x=12..20, so the rule sits below and right of the chevron tip rather than
level with it.

The three text fields sit vertically centred against the logo. It contains only:

```text
╭━━━━━━━━━━━━━━━━━━╮
┃  ██▄             ┃
┃    ▀██▄          ┃
┃       ▀██▄       ┃   Pi v<version>
┃          █▖      ┃   GPT-5.6 Sol with high effort · GitHub Copilot
┃       ▄██▀       ┃   ~/current/working/directory
┃    ▄██▀          ┃
┃  ██▀             ┃
┃           █████  ┃
╰━━━━━━━━━━━━━━━━━━╯
```

Two rendering constraints drove the final glyphs, both learned by drawing it
wrong first:

- **The chevron steps two columns per row.** Terminal cells are roughly twice as
  tall as they are wide, so a one-column-per-row diagonal renders as a
  near-vertical wobble, not a point. Each row's trailing half-block meets the
  next row's leading half-block across the row boundary, which makes the arms a
  continuous stroke rather than a staircase of solid pairs.
- **The frame mixes weights on purpose.** Unicode has no heavy *rounded* corner:
  `╭╮╰╯` exist only at light weight, and `┏┓┗┛` are heavy but square. Rounded
  corners were worth more than a matched join, so light corners carry heavy
  edges.

The reveal animation is deliberately finite (the logo draws itself row by row,
then the timer clears). A header timer that never stops would re-render the
whole TUI forever for a logo that scrolls away after the first turn.

Values are dynamic:

- Pi version comes from Pi's exported `VERSION`;
- model and provider come from the active model;
- effort comes from the active thinking level;
- path comes from the session working directory and contracts `$HOME` to `~`.

No skill, prompt, extension, theme, MCP, package, or onboarding counts appear.

### Working transcript

Collapsed output is the default:

```text
∴ Thinking · ctrl+o to expand
● Multiple Tools: 4 done
├ ● Read api/src/agent/graph.py
├ ● Search “create_chat_model” · 8 matches
├ ● Bash make api-test-fast · passed
└ ● Edit api/src/llm.py · +6 −2
Implemented the change and verified the tests.
✻ Brewed for 5s
```

The exact values vary by turn, but the density contract is fixed:

- one glanceable row per tool;
- adjacent/concurrent calls grouped;
- read bodies hidden in collapsed mode;
- searches show counts, not matches;
- MCP calls show summaries;
- Bash shows command plus outcome, not live output;
- edits show a small diff statistic or short preview;
- live tool previews are disabled;
- `Ctrl+O` expands full evidence;
- `Ctrl+Shift+O` remains available for the package's higher detail cap.

### Composer and effort

Immediately above the composer, right-aligned:

```text
◉ high · Shift+Tab
```

The level updates when the model or thinking level changes. Pi's native `Shift+Tab` behavior remains unchanged.

The composer retains cc-my-pi's Claude-style `❯` presentation.

### Footer

One line only:

```text
feat/1356-image-interpretation-pipeline · 94% context left
```

The branch comes from Pi's footer data provider. Context is computed from the active model's context window and `ctx.getContextUsage()`, rounded to a whole remaining percentage and clamped to `0–100%`.

No cost, token counts, provider, permission mode, MCP status, package status, or session metadata appears in the footer. Model/provider information already lives in the header.

### Explicit omissions

- Pi has no permission UI by design, so Claude's `bypass permissions` footer row is not imitated.
- No subagent package is added in this change. A future compatible subagent extension may add navigation only when agents actually exist.
- Fullscreen/pinned-composer behavior is deferred until an extension supports Pi 0.83 or Pi provides it natively.

## Components and ownership

### `cc-my-pi` Git package

Install as an unpinned Git package so scheduled updates can advance it:

```text
git:github.com/timvdhoorn/cc-my-pi
```

Remove `npm:@heyhuynhgiabuu/pi-diff` because cc-my-pi owns edit/write diff rendering.

The cc-my-pi settings file is global at `~/.pi/settings.json` and is authored in dotfiles. Initial values:

```json
{
  "toolBackground": "transparent",
  "readOutputMode": "hidden",
  "searchOutputMode": "count",
  "mcpOutputMode": "summary",
  "previewLines": 3,
  "expandedPreviewMaxLines": 4000,
  "extraExpandedPreviewMaxLines": 12000,
  "extraToolOutputExpanded": false,
  "groupToolCalls": true,
  "bashOutputMode": "summary",
  "bashCollapsedLines": 3,
  "liveToolPreview": false,
  "diffCollapsedLines": 8,
  "showTruncationHints": false,
  "themeAdaptive": true,
  "imagePasterEnabled": true,
  "escSteerEnabled": true,
  "doubleEscClearEnabled": true,
  "queueSteerEnabled": true,
  "spinnerEnabled": true,
  "sessionCommandsEnabled": true,
  "copyCommandEnabled": true,
  "claudeHeaderEnabled": false,
  "statuslineEnabled": false,
  "ccMyPiSetupDone": true
}
```

Disabling the bundled header/footer avoids renderer races. The package still owns compact tools, spinner, composer, queue behavior, image paste, `/clear`, `/exit`, and `/copy-code`.

### Dotfiles-owned `claude-parity` Pi extension

A global extension under `.pi/agent/extensions/claude-parity/` owns three shallow UI components:

1. `SlimPiHeader`: animated π mascot and three approved text fields;
2. `EffortWidget`: right-aligned active thinking level plus `Shift+Tab` hint;
3. `SlimFooter`: branch and remaining context.

The extension uses only documented Pi APIs:

- `ctx.ui.setHeader()`;
- `ctx.ui.setWidget(..., { placement: "aboveEditor" })`;
- `ctx.ui.setFooter()`;
- `model_select`, `thinking_level_select`, `message_end`, `turn_end`, and session lifecycle events for invalidation;
- footer branch-change subscription for git updates.

Animation timers and footer subscriptions are disposed during `session_shutdown`.

### Startup-noise policy

Pi's global `.pi/agent/settings.json` keeps:

- `quietStartup: true`;
- GitHub Copilot / GPT-5.6 Sol / high thinking defaults;
- `lastChangelogVersion: "9999.0.0"` as a deliberate sentinel because Pi has no supported “never show changelog” setting. Pi only displays entries newer than this value.

A shell wrapper applies `PI_OFFLINE=1` only to interactive Pi sessions, suppressing Pi's startup version/package checks and telemetry without affecting explicit package commands such as `pi install` or `pi update`. Explicit maintenance commands call the real Pi binary without offline mode.

cc-my-pi's separate once-daily update notifier does not honor `PI_OFFLINE`. The scheduled updater writes its state file with a future check time and non-new cached version so the bundle does not produce its own update banner. Package freshness is owned by the scheduled updater instead.

### Skill diagnostics

Do not hide malformed skills. Repair the four YAML descriptions that currently parse as compact mappings by changing them to folded block scalars:

- `hei-huset-agent/.agents/skills/playwright/SKILL.md`;
- `dotfiles/.claude/skills/cmux-orchestration/SKILL.md`;
- `dotfiles/.claude/skills/cmux-team/SKILL.md`;
- `dotfiles/.claude/skills/pr-status/SKILL.md`.

Once valid, the `[Skill conflicts]` section naturally disappears while future real diagnostics remain actionable.

## Scheduled updates

A stowed macOS LaunchAgent runs a dotfiles-owned updater:

- at login (`RunAtLoad`);
- once daily at a quiet hour;
- never in the interactive Pi startup path;
- with a lock to prevent concurrent runs;
- using `/opt/homebrew/bin/pi update --extensions`;
- with stdout/stderr written to `~/Library/Logs/pi-extension-update.log`;
- leaving failures visible in the log and retrying on the next scheduled run;
- refreshing the cc-my-pi update-check suppression state after a successful run.

This makes normal startup immediate while keeping npm and Git Pi packages current. Failures remain available in the log and through LaunchAgent exit status, not as TUI banners.

## Error handling

- Invalid JSON in either settings file must fail validation before installation; no extension should overwrite an unreadable settings file.
- Header/footer rendering falls back to plain text when model, git, or context data is unavailable.
- Outside a Git repository, the footer displays only context remaining.
- Context absence displays `100% context left` before the first model response.
- Updater failures leave a non-zero log entry and release the lock; they never block Pi.
- If cc-my-pi fails to load, the local header/footer may still render and Pi's built-in tools remain the recovery path after disabling the package.

## Verification

### Static checks

- `jq empty` for both Pi settings files;
- `plutil -lint` for the LaunchAgent;
- `bash -n` for the updater;
- TypeScript typecheck for the local extension against the installed Pi version;
- skill frontmatter validation in both repositories;
- confirm no runtime cache/log file is tracked.

### Behavioral checks

Start a fresh interactive Pi session and verify:

1. header contains only Pi version, model/effort/provider, and cwd;
2. no changelog, package update notice, skill diagnostic, or resource catalog appears;
3. default model is `github-copilot/gpt-5.6-sol` at high thinking;
4. read/search/bash/edit calls render as focused grouped rows;
5. `Ctrl+O` expands and collapses full tool evidence;
6. `Ctrl+Shift+O` enables the higher detail cap;
7. effort widget updates after `Shift+Tab`;
8. footer updates branch and context percentage;
9. `/clear`, `/exit`, image paste, queue steering, and copy behavior still work;
10. LaunchAgent update runs successfully without changing startup latency.

### Regression checks

- `pi update --extensions` still works explicitly despite the interactive offline wrapper;
- print, JSON, and RPC modes bypass cosmetic UI behavior and retain normal network startup semantics;
- existing project source changes in `hei-huset-agent` remain untouched except for the targeted skill frontmatter repair.

## Rollback

1. Remove the `cc-my-pi` Git package entry.
2. Restore `npm:@heyhuynhgiabuu/pi-diff` if its previous diff renderer is desired.
3. Disable or remove the local `claude-parity` extension.
4. Unload the LaunchAgent and remove its plist.
5. Remove `~/.pi/settings.json` and restore ordinary Pi startup checks.

All changes are configuration-level and reversible; no Pi installation files are patched.
