---
name: hei-huset-storybook-stories
description: Write and maintain stories for the Hei, huset! component system. Use for component documentation, interactive examples, story interaction tests, and Storybook accessibility failures.
---

# Hei, huset! stories

Work in the selected hei-huset-agent checkout. Read its `AGENTS.md`, authoritative
[testing guide](.agents/testing.md), component source and `.agents/skills/design-system/SKILL.md`.
Resolve guide links and repository paths from that checkout; sibling skill links stay local.

## Set the coverage boundary

State the behavior, its nearest meaningful test owner from the testing guide,
the fixture substitutions, and what remains unproved before adding or moving checks.
Keep cheap existing Bun component tests for logic and mounted behavior without real layout.
Add assertions in another suite only when they cover a distinct failure mode;
avoid repeating each behavior in component, story and app tests.

The shared harness in `web/.storybook/fixtures/harness.tsx` uses fixed requests,
a memory router, supplied auth, isolated storage and stubbed analytics. Query and
mutation retries are disabled. Stories prove isolated states and local interactions;
app integration claims require the guide's app checks. Record untested route,
motion and network claims explicitly. Actual persistence needs real-service verification.

For migrations, map every old assertion to a retained or replacement check by
file and test name. Run those checks and confirm their assertions before deleting
the originals. Keep assertions whose replacement does not prove the same claim.

## Author

Co-locate `name.stories.tsx` with `name.tsx`. Use CSF 3 with `Meta` and `StoryObj`
from `@storybook/react-vite`, `satisfies Meta<typeof Component>` and
`StoryObj<typeof meta>`. Match nearby stories; the global preview enables autodocs.

Use `Komponenter/Name` for primitives and `Bolig/Name` for product components.
Keep examples in Norwegian with correct æ, ø and å. Give each story a meaningful
state, such as empty, selected, invalid, disabled, loading or open.
Show composed primitives with labels, descriptions and required providers.

Use shared CSS and fonts through `web/.storybook/preview.tsx`; inherit its theme.
Token values belong to the Figma snapshot workflow. Derive mapped documentation
links with `web/.storybook/figma.ts` from `web/figma/code-connect.json`.

Controlled inputs need a React state adapter. Follow `input.stories.tsx`:
its key resets state when Controls changes; `useArgs` did not rerender inputs
in the portable-story Vitest run.
Add providers only where needed. Use a story-local MemoryRouter for router components,
and fixed fixtures with isolated query state for data-driven components.

## Find the real composition

Follow imports from the primitive to its module and route before changing it.
Search `Bolig/AppShell`, `Bolig/Oversikt`, `Bolig/ConditionFilterBar` and
`Bolig/Samtalehistorikk` for navigation, dashboard, filters and history.
Add missing states at the lowest useful level, then verify affected consumers
at the owner selected in the coverage boundary. Consult
[visual verification](docs/test-plans/storybook-visual-verification.md) for capture details.

## Exercise behaviour

Import `expect`, `fn`, `userEvent`, `waitFor` and `within` from `storybook/test`
as needed. Instrument callbacks explicitly with `fn()`.
Use the play context's `canvas` for local role/label queries. Radix portals live
outside the canvas: query `within(canvasElement.ownerDocument.body)` for overlays.
Wait for focus, animation completion and accessible state with `findByRole` or
`waitFor`; a resolved click can precede the next render or focus restoration.

Check observable local behavior: keyboard selection, input values, Escape dismissal,
focus restoration and callbacks. Wait for focus inside open overlays before axe runs.
Use Storybook Playwright specs for actual viewport changes, geometry, overflow,
scrolling, real hover and responsive portals, following the testing guide.

## Verify and complete

1. Run the affected story file in both themes from `web/`, for example
   `bun run test-storybook:light app/components/ui/input.stories.tsx`, then
   `bun run test-storybook:dark app/components/ui/input.stories.tsx`.
2. Inspect affected states in the browser. Run `make web-storybook-test-responsive`
   for browser layout changes; use the sibling skill for server/build prerequisites.
3. For visible production fixes, capture before/after evidence with
   `make web-storybook-evidence STORYBOOK_STORIES=<story-file>` and inspect its images
   and metadata. CI responsive artifacts contain reports/traces; use explicit
   capture/review commands for gallery screenshots.
4. Complete applicable gates in the testing guide, including `make web-check`
   for web changes, `make web-storybook-build` and the full `make web-storybook-test`
   for catalogue changes. Focused local verification does not replace required CI.

Keep light/dark checks and axe rules enabled. Fix missing story semantics or the
component defect when accessibility fails. Capture a discovered failing state
before editing through the repository's evidence workflow.

For starting Storybook, command selection and evidence handling, use
[hei-huset-storybook](../hei-huset-storybook/SKILL.md). During runner upgrades, retain
the dedicated Storybook Vite config and one Vitest project with theme selected by
`initialGlobals`. Keep Vitest/provider versions matched and verify both CLI and
in-app results; duplicate config directories cause duplicate project names.
