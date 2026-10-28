---
name: hei-huset-storybook
description: Run or explore the Hei, huset! Storybook component catalogue. Use for starting Storybook, inspecting variants, themes or viewports, and running its build or browser checks.
---

# Hei, huset! Storybook

Work from the hei-huset-agent repository root, normally
`~/dev/work/hei-huset-agent`. Use the current checkout when working in a worktree.
Read its `AGENTS.md` and authoritative [testing guide](.agents/testing.md) before
choosing checks. Resolve that guide link and repository paths from the selected checkout.

## Start and manage

1. Run `make dev-status s=storybook`.
2. If dependencies are absent or the lockfile changed, run
   `bun install --cwd web --frozen-lockfile`. Private Gjensidige packages use
   the repository's existing registry authentication.
3. Run `make dev s=storybook`. It starts in the background, waits for the story
   index, and returns. Repeating it reuses the running server.
4. Open the reported URL, normally `http://127.0.0.1:6006`, in the in-app browser.
   Confirm that the requested story renders before reporting it ready.

Storybook needs only the web dependencies. The API, Docker, Azure login and app
authentication are unnecessary for the bundled stories.
Use `make dev-logs s=storybook` to diagnose startup,
`make dev-restart s=storybook` to restart, and `make dev-stop s=storybook` to stop.
The foreground `make web-storybook` is the supervisor's launch target.
`make dev` starts the application services; Storybook is opt-in.

## Explore the catalogue

- **Grunnlag** shows colours, typography, radii and shadows from the app CSS.
- **Komponenter** shows reusable UI primitives; **Bolig** shows product components.
- **Controls** changes props; **Docs** shows generated prop information,
  examples and available Figma links.
- **Tema** switches light/dark on the preview document, including Radix portals.
  The viewport toolbar previews mobile and desktop sizes.
- **Actions** displays callbacks, **Interactions** shows play-function steps,
  and **Accessibility** inspects the rendered state with axe.

Link a selected story using its Storybook URL. Open the iframe directly for
focused inspection. Preserve the story, theme and viewport in evidence captures.
Follow the repository's browser preference.

## Choose verification

Use the testing guide to select the owner of each assertion. Storybook's shared
harness substitutes router, auth, storage and analytics, and disables query retries.
Passing stories cannot certify those application integrations. The app's mock API
suite cannot certify actual persistence; real-service claims need real-service verification.

| Purpose | Command from the repository root | Result |
| --- | --- | --- |
| Static catalogue | `make web-storybook-build` | Builds `web/storybook-static/`; no publication |
| Interactions and accessibility | `make web-storybook-test` | Runs every story in Chromium, light and dark, without a running Storybook server |
| Responsive browser behavior | `make web-storybook-test-responsive` | Runs bounded Playwright checks with actual viewport changes in both themes |
| Selected visual review | `make web-storybook-capture-review` | Builds, captures `web/.storybook/visual-cases.ts`, and writes `web/test-results/storybook-review/index.html` |
| Interaction-state evidence | `make web-storybook-evidence` | Builds, tests both themes, and captures completed interactions into a temporary gallery with metadata and logs |

Install Chromium once with `cd web && bunx playwright install chromium`.
Responsive checks use the supervised preview or `STORYBOOK_URL` locally.
For a static local run, build first, then use
`CI=true make web-storybook-test-responsive`; that command serves the existing build.

For a focused evidence loop, append
`STORYBOOK_STORIES=app/components/ui/checkbox.stories.tsx` to the evidence command.
An explicit `STORYBOOK_CAPTURE_DIR` must be empty. Inspect gallery images yourself
and record passed/failed/untested assertions with reasons through the repository's
evidence workflow. Capture/review commands perform no automatic pixel comparison.
A passing capture confirms rendering, theme and dimensions; visual approval remains manual.
Keep generated images outside Git.

## CI evidence and completion

Inspect `.github/workflows/pr-storybook.yml` in the selected checkout before fetching artifacts.
The audited workflow uploads `storybook-responsive-evidence-<head>-<shard>` from
`web/test-results/storybook-responsive/` and `web/playwright-report/storybook-responsive/`.
These contain reports and retained failure traces, not a screenshot gallery.
CI disables responsive screenshots and trace screenshots. Interaction failures use
the separate `storybook-interaction-failures` artifact. Use explicit capture/review
commands above when screenshots are needed.

Focused checks shorten the local loop. Complete applicable gates from the testing
guide before pushing; browser checks remain separate from `make web-check`.
Retain full CI, light/dark and accessibility enforcement.

For story changes, use the sibling
[hei-huset-storybook-stories](../hei-huset-storybook-stories/SKILL.md) skill.
