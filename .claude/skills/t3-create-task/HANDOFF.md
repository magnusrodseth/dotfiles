# Conversation handoff

A cross-app handoff creates a new T3 thread with supplied context. It does not
move the source chat, transfer a live provider session or automatically copy tool
history. Codex conversation IDs are not T3 thread IDs.

Write a compact brief containing:

- The user's current objective and the exact next action. If work is complete,
  ask T3 to acknowledge the context and wait for the user's next instruction.
- Settled decisions and constraints, including actions that remain unauthorized.
- The provider preference: Anthropic Claude Opus 5.5 (`claude-opus-5-5`) at
  medium reasoning effort for every T3 task. Never Codex when Opus 5.5 is
  available, and no silent substitution of provider, model or effort. Carry any
  explicit task-specific override instead.
- Completed work, verification results and any qualifications or remaining gates.
- Real repository/check-out paths, branches, PR/document links and relevant
  uncommitted changes. Distinguish source snapshots from current deployment facts.
- Remaining work and completion criteria. Separate proposals from approved work.

Include only necessary context. Exclude credentials and raw customer data. Keep
private workspace paths and business context in the handoff file, not the public
skill. References supplement the brief; they do not replace its key decisions.

The receiving agent should read the destination's AGENTS.md before taking new
actions. Do not delegate further, message people, merge or deploy unless the
user has authorized that action.

Verify that T3 recorded the brief. Say whether the agent acknowledged it or the
first turn is still pending. Keep the source conversation available.

## Primary references

- [Native CLI implementation](https://github.com/pingdotgg/t3code/blob/main/apps/server/src/cli/thread.ts)
- [Desktop-owned CLI launcher](https://github.com/pingdotgg/t3code/blob/main/apps/desktop/src/app/DesktopCliShim.ts)
- [T3 orchestration MCP](https://github.com/pingdotgg/t3code/blob/main/docs/orchestration-v2/orchestrator-mcp-server.md)

Use installed `--help` as the syntax authority; upstream main may be newer.
