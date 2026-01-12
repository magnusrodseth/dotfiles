---
name: opencode-docs
description: OpenCode + OhMyOpenCode configuration reference - agents, tools, MCP, skills, commands, hooks, permissions, providers, and Sisyphus orchestration patterns
---

# OpenCode + OhMyOpenCode Reference

## Quick Reference

### Magic Words (OhMyOpenCode)
| Keyword | Effect |
|---------|--------|
| `ultrawork` / `ulw` | Maximum performance - parallel agents, background tasks, relentless execution |
| `search` / `find` | Maximized search with parallel explore + librarian |
| `analyze` / `investigate` | Deep analysis with multi-phase expert consultation |
| `ultrathink` | Extended thinking mode for complex reasoning |

### Config File Locations (Precedence: later overrides earlier)
```
1. Remote (.well-known/opencode)     - organizational defaults
2. ~/.config/opencode/opencode.json  - global user preferences
3. ./opencode.json                   - project-specific
4. .opencode/                        - agents, commands, plugins
```

### OhMyOpenCode Config Locations
```
1. ~/.config/opencode/oh-my-opencode.json  - global
2. .opencode/oh-my-opencode.json           - project
```

---

## Agents

### Built-in Primary Agents
| Agent | Purpose | Default Model |
|-------|---------|---------------|
| `build` | Full development with all tools | Configured model |
| `plan` | Analysis without changes (read-only) | Configured model |

### Built-in Subagents
| Agent | Purpose | Default Model |
|-------|---------|---------------|
| `general` | Multi-step research tasks | Parent's model |
| `explore` | Fast codebase exploration | Parent's model |

### OhMyOpenCode Agents
| Agent | Purpose | Model |
|-------|---------|-------|
| `Sisyphus` | Main orchestrator | claude-opus-4-5 |
| `oracle` | Architecture, debugging, strategy | gpt-5.2 |
| `librarian` | Docs, OSS examples, multi-repo | glm-4.7-free |
| `explore` | Fast codebase grep | grok-code/gemini-flash/haiku |
| `frontend-ui-ux-engineer` | UI/UX development | gemini-3-pro |
| `document-writer` | Technical writing | gemini-3-flash |
| `multimodal-looker` | PDF/image analysis | gemini-3-flash |

### Agent Definition Locations
```
~/.config/opencode/agent/*.md     - global agents
.opencode/agent/*.md              - project agents
~/.claude/agents/*.md             - Claude Code compat
.claude/agents/*.md               - Claude Code compat (project)
```

### Agent Markdown Format
```markdown
---
description: What this agent does
mode: subagent           # primary | subagent | all
model: provider/model-id
temperature: 0.3
tools:
  write: false
  bash: false
permission:
  edit: deny
  bash:
    "git *": allow
---

System prompt goes here.
```

### Agent JSON Config (opencode.json)
```json
{
  "agent": {
    "my-agent": {
      "description": "Required description",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4",
      "temperature": 0.3,
      "tools": { "write": false },
      "permission": { "edit": "deny" }
    }
  }
}
```

### OhMyOpenCode Agent Override (oh-my-opencode.json)
```json
{
  "agents": {
    "oracle": { "model": "openai/gpt-5.2" },
    "explore": { "model": "anthropic/claude-haiku-4-5" },
    "frontend-ui-ux-engineer": { "disable": true }
  },
  "disabled_agents": ["oracle", "frontend-ui-ux-engineer"]
}
```

---

## Tools

### Built-in Tools
| Tool | Purpose |
|------|---------|
| `bash` | Execute shell commands |
| `edit` | Modify files (exact string replacement) |
| `write` | Create/overwrite files |
| `read` | Read file contents |
| `grep` | Search file contents (regex) |
| `glob` | Find files by pattern |
| `list` | List directory contents |
| `webfetch` | Fetch web content |
| `skill` | Load skill definitions |
| `todowrite` / `todoread` | Task management |

### OhMyOpenCode Additional Tools
| Tool | Purpose |
|------|---------|
| `lsp_*` | LSP operations (hover, goto, rename, etc.) |
| `ast_grep_*` | AST-aware search/replace |
| `call_omo_agent` | Spawn explore/librarian agents |
| `sisyphus_task` | Category-based task delegation |
| `background_task` | Run agents in background |
| `background_output` | Get background task results |
| `background_cancel` | Cancel background tasks |
| `session_*` | Session history management |
| `look_at` | Multimodal file analysis |

### Tool Permissions
```json
{
  "permission": {
    "edit": "allow",        // allow | deny | ask
    "bash": "ask",
    "webfetch": "deny",
    "bash": {               // Per-command
      "*": "ask",
      "git status": "allow",
      "rm -rf": "deny"
    }
  }
}
```

### Disable Tools Globally
```json
{
  "tools": {
    "write": false,
    "mymcp_*": false
  }
}
```

---

## MCP Servers

### Config Location
```json
// opencode.json
{
  "mcp": {
    "server-name": { ... }
  }
}
```

### Local MCP
```json
{
  "mcp": {
    "my-local": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-server"],
      "environment": { "API_KEY": "{env:MY_API_KEY}" },
      "enabled": true,
      "timeout": 5000
    }
  }
}
```

### Remote MCP
```json
{
  "mcp": {
    "my-remote": {
      "type": "remote",
      "url": "https://mcp.example.com",
      "headers": { "Authorization": "Bearer {env:TOKEN}" },
      "oauth": {}
    }
  }
}
```

### OhMyOpenCode Built-in MCPs
| MCP | Purpose |
|-----|---------|
| `websearch` | Exa AI web search |
| `context7` | Official documentation lookup |
| `grep_app` | GitHub code search |

Disable via:
```json
// oh-my-opencode.json
{ "disabled_mcps": ["websearch", "context7"] }
```

### Claude Code MCP Compat Locations
```
~/.claude/.mcp.json
./.mcp.json
./.claude/.mcp.json
```

---

## Skills

### Skill Locations
```
~/.config/opencode/skill/<name>/SKILL.md  - global
.opencode/skill/<name>/SKILL.md           - project
~/.claude/skills/<name>/SKILL.md          - Claude Code compat
.claude/skills/<name>/SKILL.md            - Claude Code compat (project)
```

### Skill Format
```markdown
---
name: my-skill
description: What this skill does (1-1024 chars)
license: MIT
compatibility: opencode
mcp:                              # Optional embedded MCP
  playwright:
    command: npx
    args: ["-y", "@anthropic-ai/mcp-playwright"]
---

Instructions for the agent when this skill is loaded.
```

### OhMyOpenCode Built-in Skills
- `playwright` - Browser automation
- `git-master` - Git operations expert

Disable via:
```json
// oh-my-opencode.json
{ "disabled_skills": ["playwright"] }
```

---

## Commands

### Command Locations
```
~/.config/opencode/command/*.md   - global
.opencode/command/*.md            - project
~/.claude/commands/*.md           - Claude Code compat
.claude/commands/*.md             - Claude Code compat (project)
```

### Command Format
```markdown
---
description: What this command does
agent: build
model: anthropic/claude-sonnet-4
subtask: true
---

Template with $ARGUMENTS or $1, $2, etc.

Include files with @path/to/file.ts
Include shell output with !`command`
```

---

## Providers

### Authentication
```bash
opencode auth login       # Interactive provider selection
opencode auth list        # Show configured providers
```

### Provider Config
```json
{
  "provider": {
    "anthropic": {
      "options": {
        "baseURL": "https://api.anthropic.com/v1",
        "timeout": 600000
      }
    }
  },
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

### Model Format
`provider/model-id` - e.g., `anthropic/claude-opus-4-5`, `openai/gpt-5.2`

### Disable Providers
```json
{
  "disabled_providers": ["openai", "gemini"],
  "enabled_providers": ["anthropic"]  // Allowlist mode
}
```

---

## OhMyOpenCode Specifics

### Sisyphus Agent Config
```json
// oh-my-opencode.json
{
  "sisyphus_agent": {
    "disabled": false,
    "default_builder_enabled": false,
    "planner_enabled": true,
    "replace_plan": true
  }
}
```

### Background Task Concurrency
```json
{
  "background_task": {
    "defaultConcurrency": 5,
    "providerConcurrency": { "anthropic": 3 },
    "modelConcurrency": { "anthropic/claude-opus-4-5": 2 }
  }
}
```

### Categories (sisyphus_task)
```json
{
  "categories": {
    "visual": {
      "model": "google/gemini-3-pro-preview",
      "temperature": 0.7,
      "prompt_append": "Use shadcn/ui and Tailwind"
    },
    "business-logic": {
      "model": "openai/gpt-5.2",
      "temperature": 0.1
    }
  }
}
```

### Hooks
Disable via:
```json
{ "disabled_hooks": ["comment-checker", "agent-usage-reminder"] }
```

Key hooks:
- `todo-continuation-enforcer` - Forces completion of all TODOs
- `comment-checker` - Prevents excessive comments
- `context-window-monitor` - Warns at 70%+ usage
- `preemptive-compaction` - Compacts at 85% usage
- `keyword-detector` - Detects ultrawork/search/analyze
- `ralph-loop` - Continuous execution until done

### Ralph Loop
```
/ralph-loop "Build a REST API"   # Start loop
/cancel-ralph                     # Stop loop
```

---

## Hooks (Claude Code Compat)

### Hook Locations
```
~/.claude/settings.json
./.claude/settings.json
./.claude/settings.local.json
```

### Hook Events
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `UserPromptSubmit` - On prompt submit
- `Stop` - When session goes idle

### Hook Format
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "eslint --fix $FILE" }]
      }
    ]
  }
}
```

---

## Rules / Instructions

### AGENTS.md Locations
```
./AGENTS.md                       - project root
~/.config/opencode/AGENTS.md      - global
```
Both are combined. Project can have nested AGENTS.md per directory.

### Instructions Array
```json
{
  "instructions": ["CONTRIBUTING.md", "docs/*.md", ".cursor/rules/*.md"]
}
```

### Conditional Rules (.claude/rules/)
```markdown
---
globs: ["*.ts", "src/**/*.js"]
alwaysApply: false
---

- Use PascalCase for interfaces
- Use camelCase for functions
```

---

## Common Tasks

### Check Current Config
```bash
cat ~/.config/opencode/opencode.json
cat ~/.config/opencode/oh-my-opencode.json
cat ./opencode.json
cat ./.opencode/oh-my-opencode.json
```

### Add Custom Agent
1. Create `~/.config/opencode/agent/my-agent.md` or `.opencode/agent/my-agent.md`
2. Or add to `opencode.json` under `agent` key

### Disable OhMyOpenCode Feature
```json
// oh-my-opencode.json
{
  "disabled_hooks": ["feature-name"],
  "disabled_agents": ["agent-name"],
  "disabled_mcps": ["mcp-name"],
  "disabled_skills": ["skill-name"]
}
```

### Override Agent Model
```json
// oh-my-opencode.json
{
  "agents": {
    "oracle": { "model": "anthropic/claude-sonnet-4" }
  }
}
```

### Add Custom MCP
```json
// opencode.json
{
  "mcp": {
    "my-mcp": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-server"]
    }
  }
}
```

---

## Troubleshooting

### Config Not Loading
1. Check JSON syntax: `cat ~/.config/opencode/opencode.json | jq .`
2. Verify file location (precedence matters)
3. Check OpenCode version: `opencode --version` (need 1.0.150+)

### Agent Not Available
1. Check `disabled_agents` in oh-my-opencode.json
2. Verify agent file exists and has valid frontmatter
3. Check mode: `primary` vs `subagent`

### MCP Not Working
1. Check `enabled: true` in MCP config
2. Verify command exists: `which npx`
3. Check timeout (default 5000ms)
4. For OAuth: `opencode mcp auth <server-name>`

### Hooks Not Firing
1. Check `disabled_hooks` in oh-my-opencode.json
2. Verify hook event name matches
3. Check Claude Code settings.json location

### Provider Auth Issues
1. Run `opencode auth login` and re-authenticate
2. Check `~/.local/share/opencode/auth.json` exists
3. For Google: Consider opencode-antigravity-auth plugin

---

## Variable Substitution

### Environment Variables
```json
{ "apiKey": "{env:MY_API_KEY}" }
```

### File Contents
```json
{ "instructions": ["{file:./prompts/system.txt}"] }
```

---

## LSP Configuration

### Add LSP Server (oh-my-opencode.json)
```json
{
  "lsp": {
    "typescript-language-server": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx"],
      "priority": 10
    },
    "pylsp": { "disabled": true }
  }
}
```

---

## Claude Code Compatibility Toggles

```json
// oh-my-opencode.json
{
  "claude_code": {
    "mcp": false,       // Disable ~/.claude/.mcp.json loading
    "commands": false,  // Disable ~/.claude/commands/
    "skills": false,    // Disable ~/.claude/skills/
    "agents": false,    // Disable ~/.claude/agents/
    "hooks": false,     // Disable settings.json hooks
    "plugins": false    // Disable marketplace plugins
  }
}
```
