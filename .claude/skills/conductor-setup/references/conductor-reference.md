# Conductor Reference

## What is Conductor?

macOS app for running multiple Claude Code instances concurrently, each with an isolated codebase copy (workspace). Workspaces branch from a repo and can be created from branches, PRs, or Linear issues.

## conductor.json Schema

```json
{
  "scripts": {
    "setup": "string — runs when creating a workspace (zsh)",
    "run": "string — runs via the Run button in UI (zsh)",
    "archive": "string — runs when archiving a workspace (zsh)"
  },
  "runScriptMode": "concurrent | nonconcurrent"
}
```

- **setup**: Runs after git files are copied into workspace. Use for dependency installation and env file symlinking. Workspace directory is the working directory.
- **run**: Starts dev servers, test runners, etc. Bound to the Run button (bottom-right).
- **archive**: Cleanup before workspace deletion.
- **runScriptMode**: `nonconcurrent` kills previous run before starting new one (useful for dev servers that bind a port).

## Environment Variables

| Variable | Description |
|----------|-------------|
| `$CONDUCTOR_ROOT_PATH` | Persistent repo root directory (where you place untracked files like .env) |
| `$CONDUCTOR_PORT` | Unique port assigned to each workspace |
| `$CONDUCTOR_WORKSPACE_NAME` | Current workspace identifier |

## .env File Strategy

.env files are gitignored and not copied into workspaces. Two approaches:

### Approach 1: Symlink from CONDUCTOR_ROOT_PATH (recommended)
1. Place .env files in the repo root directory (the actual repo on disk — this IS `$CONDUCTOR_ROOT_PATH`)
2. Setup script symlinks them: `ln -sf "$CONDUCTOR_ROOT_PATH/.env" .env`

### Approach 2: Copy from CONDUCTOR_ROOT_PATH
1. Place .env in repo root via Repository Settings > "Open In"
2. Setup script copies: `cp "$CONDUCTOR_ROOT_PATH/.env" .env`

Symlinks are preferred — changes to the source .env are reflected in all workspaces instantly.

## Workspace Locations

```
~/conductor/
├── repos/              # Persistent repo roots (CONDUCTOR_ROOT_PATH points here)
├── workspaces/<repo>/  # Active workspace directories
└── archived-contexts/  # Archived workspace data
```

## Common Run Script Patterns

### Node.js / Next.js
```json
"run": "npm run dev -- --port $CONDUCTOR_PORT"
```

Or if the dev script is in a subdirectory:
```json
"run": "npm --prefix web run dev -- --port $CONDUCTOR_PORT"
```

### Python
```json
"run": "python3 -m http.server --port $CONDUCTOR_PORT"
```

### Django
```json
"run": "python manage.py runserver 0.0.0.0:$CONDUCTOR_PORT"
```

### Rails
```json
"run": "bin/rails server -p $CONDUCTOR_PORT"
```

### Elixir / Phoenix
```json
"run": "mix phx.server"
```
(Phoenix reads PORT env which Conductor sets)

## Common Setup Script Patterns

### npm project
```json
"setup": "zsh scripts/conductor-setup.sh && npm install"
```

### pnpm monorepo
```json
"setup": "zsh scripts/conductor-setup.sh && pnpm install"
```

### Python project
```json
"setup": "zsh scripts/conductor-setup.sh && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
```

## Notes

- Personal scripts in Repository Settings override conductor.json entirely
- Team members must clear their individual script configs for the shared file to take effect
- Scripts execute using zsh
