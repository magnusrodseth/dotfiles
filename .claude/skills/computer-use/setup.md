# Setup and portability

The skill needs shell access to the two CLIs. Visual tasks also need a harness tool that displays local images. It does not require `cua_repl`, Playwright code, a particular model, or a ChatGPT plugin. Harness restrictions still apply.

## Dependencies

Inspect the existing installation and package manager before changing it:

```bash
command -v agent-browser
command -v agent-desktop
agent-browser --version
agent-desktop version
```

Official sources:

- [agent-browser](https://github.com/vercel-labs/agent-browser)
- [agent-desktop](https://github.com/vercel-labs/agent-desktop)

For a missing npm-managed installation:

```bash
npm install -g agent-browser agent-desktop
```

Read any blocked postinstall notice. Approve only the named official package's script when needed; do not change global script policy. Existing tools should be updated through their original package manager. Fetch the installed embedded skills again after an update.

`agent-browser install` downloads its isolated automation browser when no suitable browser is installed. It does not attach to the user's Personal profile. Read the installed browser guide before choosing a connection path.

## OS permissions

On macOS, start with `agent-desktop permissions`. For denied Accessibility access, run `agent-desktop permissions --guide`. The user grants access to the app launching the CLI, such as ChatGPT, T3 Code, or a terminal. If macOS lists the binary separately, the guide may also require it.

Open **System Settings > Privacy & Security > Accessibility**. Do not confuse this app permission list with the top-level Accessibility category for assistive features. On macOS versions using **Device Control and Data Access**, follow the installed platform guide's name.

Let the user complete Touch ID, passwords, and permission approval. Then rerun `permissions` and verify a read-only snapshot. Screen Recording is needed for screenshots. Automation is needed only when a requested command reports it missing. Never edit the TCC database or disable OS protections.

For Windows or Linux, read `agent-desktop skills get platform` and use its actual session and permission requirements.

## Harness discovery

The authored source lives at `~/dotfiles/.claude/skills/computer-use/`. The dotfiles link script exposes it through `~/.agents/skills/computer-use/` and mirrors it into `~/.claude/skills/computer-use/`.

Run the scoped linker after adding or moving this skill:

```bash
bash ~/dotfiles/scripts/skills/link-dotfiles-skills.sh computer-use
```

Claude Code reads its mirrored root. Codex and other compatible agents read the shared root. In T3 Code, discovery depends on the selected provider and its skill support. Do not invent a T3-specific skill directory or claim every harness scans the same path.

If automatic discovery is unavailable, tell the agent to read `~/.agents/skills/computer-use/SKILL.md` and follow its relative reference files. Start a fresh chat if the harness caches its skill catalog. Shell-only harnesses can use semantic control but cannot complete screenshot-dependent work without an image tool.
