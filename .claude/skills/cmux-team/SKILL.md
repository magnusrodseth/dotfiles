---
name: cmux-team
description: Boot a three-tier cmux agent team (an orchestrator lead plus plan/build/test worker panes) for the current repo, named after a feature, all driven over the cmux socket. Run it from a terminal surface INSIDE cmux. Usage: /cmux-team <feature-slug>.
disable-model-invocation: true
---

# cmux-team

Boot a **three-tier team** for the current repo in one shot: an **orchestrator lead** on the left, **plan / build / test** workers on the right, each a `Codex` agent, all wired over the cmux socket. **One team = one workspace = one feature.** You drive only the lead; the lead drives the workers.

Exact `cmux` CLI syntax and every gotcha live in the **`cmux-orchestration`** skill: consult it first. This skill is only the team-boot recipe layered on top. To swap the agent, replace `Codex` below with `pi` / `codex` / your harness.

## Argument

The feature slug is the invocation argument (`/cmux-team checkout-flow`). It names the workspace and the roster file. If none was given, ask for one before doing anything.

## Load-bearing rules (from cmux-orchestration, restated because they bite here)

- The team lives in a **new workspace**, which is NOT your caller workspace. **Scope every `new-split` / `send` / `send-key` / `read-screen` on the team with `--workspace "$WS"`**, or you get `not_found`.
- `send` types, `send-key enter` submits. Keep them separate for the agent REPLs.
- Capture refs from `--json` at creation and thread them through; never guess. Reference the workspace by `workspace:N`, never by name.
- Stop a pane with `close-surface`; there is no `close-pane`.

## Step 1 — Preflight: you must be able to reach the socket

Drive cmux from a terminal surface INSIDE cmux (default `cmuxOnly`), or from any shell when `automation.socketControlMode` is `password`/`allowAll` and `CMUX_SOCKET_PASSWORD` is set. Either way, confirm the socket answers and stop if it doesn't:

```bash
export CMUX_QUIET=1
cmux identify --json >/dev/null 2>&1 || {
  echo "Can't reach the cmux socket. Run /cmux-team from a surface INSIDE cmux, or enable socketControlMode=password/allowAll + CMUX_SOCKET_PASSWORD to drive it from an external shell."
  exit 1
}
```

Do NOT `open -a cmux` or change the socket mode automatically. If preflight fails, report that and stop.

## Step 2 — Create the team workspace (lead on the left)

```bash
FEATURE="<the invocation argument>"
read WS LEAD < <(cmux workspace create --name "$FEATURE" --cwd "$PWD" --focus false --json \
                 | jq -r '[.workspace_ref, .surface_ref] | @tsv')
```

## Step 3 — Split the workers off the lead (scoped to $WS)

Three workers stacked on the right; the lead keeps the left half.

```bash
PLAN=$(cmux new-split right --workspace "$WS" --surface "$LEAD"  --focus false --json | jq -r .surface_ref)
BUILD=$(cmux new-split down --workspace "$WS" --surface "$PLAN"  --focus false --json | jq -r .surface_ref)
TEST=$(cmux new-split down  --workspace "$WS" --surface "$BUILD" --focus false --json | jq -r .surface_ref)
```

## Step 4 — Make roles legible

```bash
cmux rename-tab --workspace "$WS" --surface "$LEAD"  "lead"
cmux rename-tab --workspace "$WS" --surface "$PLAN"  "plan"
cmux rename-tab --workspace "$WS" --surface "$BUILD" "build"
cmux rename-tab --workspace "$WS" --surface "$TEST"  "test"
cmux workspace rename "$WS" --title "team:$FEATURE | lead plan build test"
```

## Step 5 — Optional services pane (delegate to the repo's own up-command)

Boot the repo's own dev command, don't invent one. Skip the pane if the repo ships none.

```bash
UP=""
{ [ -f justfile ] || [ -f Justfile ]; } && just --summary 2>/dev/null | tr ' ' '\n' | grep -qx dev && UP="just dev"
[ -z "$UP" ] && [ -f Makefile ] && grep -qE '^dev:' Makefile && UP="make dev"
[ -z "$UP" ] && [ -f package.json ] && jq -e '.scripts.dev' package.json >/dev/null 2>&1 && UP="pnpm dev"
if [ -n "$UP" ]; then
  SVC=$(cmux new-split down --workspace "$WS" --surface "$TEST" --focus false --json | jq -r .surface_ref)
  cmux rename-tab --workspace "$WS" --surface "$SVC" "services"
  cmux send --workspace "$WS" --surface "$SVC" "$UP"; cmux send-key --workspace "$WS" --surface "$SVC" enter
fi
```

## Step 6 — Boot the agents (workers first, then the lead)

Each pane runs an **interactive** `Codex` REPL (see the interactive-vs-headless recipe in `cmux-orchestration`: `send "Codex"` + `send-key enter`, then **wait for the REPL to render** before prompting). Do NOT fire the kickoff before the input box appears: poll `cmux read-screen --workspace "$WS" --surface "$S"` until Codex's prompt is visible, rather than guessing a sleep.

Launch all three workers, wait for their REPLs, then kick each off to acknowledge and wait:

```bash
for S in "$PLAN" "$BUILD" "$TEST"; do
  cmux send --workspace "$WS" --surface "$S" "Codex"; cmux send-key --workspace "$WS" --surface "$S" enter
done
# wait for each REPL (poll read-screen), then per worker, with its role:
cmux send --workspace "$WS" --surface "$PLAN"  "You are the PLAN worker on team $FEATURE. Reply 'ready: plan' and wait for the lead."   ; cmux send-key --workspace "$WS" --surface "$PLAN"  enter
cmux send --workspace "$WS" --surface "$BUILD" "You are the BUILD worker on team $FEATURE. Reply 'ready: build' and wait for the lead." ; cmux send-key --workspace "$WS" --surface "$BUILD" enter
cmux send --workspace "$WS" --surface "$TEST"  "You are the TEST worker on team $FEATURE. Reply 'ready: test' and wait for the lead."   ; cmux send-key --workspace "$WS" --surface "$TEST"  enter
```

Then the lead, handed the feature and the worker refs, told to drive them:

```bash
cmux send --workspace "$WS" --surface "$LEAD" "Codex"; cmux send-key --workspace "$WS" --surface "$LEAD" enter
# wait for the lead REPL, then:
cmux send --workspace "$WS" --surface "$LEAD" "You are the LEAD of team $FEATURE. Workers: plan=$PLAN, build=$BUILD, test=$TEST. Drive them with cmux send / read-screen, scoping every call with --workspace $WS. Feature: $FEATURE. Start by handing the feature to plan, then coordinate build and test."
cmux send-key --workspace "$WS" --surface "$LEAD" enter
```

## Step 7 — Write a roster (for ref recovery)

```bash
mkdir -p .cmux-team
jq -n --arg f "$FEATURE" --arg w "$WS" --arg l "$LEAD" --arg p "$PLAN" --arg b "$BUILD" --arg t "$TEST" \
  '{feature:$f, workspace:$w, agents:{lead:$l, plan:$p, build:$b, test:$t}}' \
  > ".cmux-team/$FEATURE.roster.json"
```

Add `.cmux-team/` to the repo's `.gitignore` if it isn't already.

## Step 8 — Report

```
## Team "<feature>" booted — workspace <WS>

| Role  | Surface |
|-------|---------|
| lead  | <LEAD>  |
| plan  | <PLAN>  |
| build | <BUILD> |
| test  | <TEST>  |
(+ services: <UP> in <SVC>, if booted)

Roster: .cmux-team/<feature>.roster.json
Drive the lead; it drives the workers.
Read any pane:  cmux read-screen --workspace <WS> --surface <ref> --lines 40
Tear down:      cmux workspace close <WS>
```
