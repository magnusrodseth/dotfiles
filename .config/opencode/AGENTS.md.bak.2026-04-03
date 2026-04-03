# Oh-My-OpenCode Configuration Guide

This document describes the oh-my-opencode configuration for this setup.

## Provider Routing

| Provider | Auth | Routes |
|----------|------|--------|
| **Anthropic** | Personal subscription | All Claude models (opus, sonnet, haiku) |
| **GitHub Copilot** | `opencode auth login` | GPT, Gemini, and Grok models |

## Quick Reference

| Task Type | Delegate To | Model |
|-----------|-------------|-------|
| Frontend/UI work | `category="visual-engineering"` | `github-copilot/gemini-3-pro-preview` |
| Hard logic/architecture | `category="ultrabrain"` | `github-copilot/gpt-5.3-codex` (high reasoning) |
| Autonomous deep work | `category="deep"` | `github-copilot/gpt-5.3-codex` (medium reasoning) |
| Creative/unconventional | `category="artistry"` | `github-copilot/gemini-3-pro-preview` |
| Trivial tasks | `category="quick"` | `anthropic/claude-haiku-4-5` |
| Documentation/writing | `category="writing"` | `github-copilot/gemini-3-flash-preview` |
| General low-effort | `category="unspecified-low"` | `anthropic/claude-sonnet-4-6` |
| General high-effort | `category="unspecified-high"` | `anthropic/claude-opus-4-6` (max) |
| Codebase search | `explore` agent | `github-copilot/gpt-5-mini` |
| External docs/examples | `librarian` agent | `github-copilot/gemini-3-flash-preview` |
| Debugging/consultation | `oracle` agent | `github-copilot/gpt-5.3-codex` |

## Agents

### Orchestration (Claude Opus via Anthropic)

| Agent | Model | Purpose |
|-------|-------|---------|
| **sisyphus** | `anthropic/claude-opus-4-6` | Main orchestrator - coordinates all work |
| **sisyphus-junior** | Varies by category | Executes delegated tasks from categories |
| **prometheus** | `anthropic/claude-opus-4-6` | Work planning methodology |
| **metis** | `anthropic/claude-opus-4-6` | Pre-planning analysis, identifies hidden requirements |

### Execution

| Agent | Model | Purpose |
|-------|-------|---------|
| **build** | `anthropic/claude-opus-4-6` | Primary code builder |
| **plan** | `anthropic/claude-opus-4-6` | Planning tasks |
| **general** | `anthropic/claude-opus-4-6` | General-purpose tasks |
| **hephaestus** | `github-copilot/gpt-5.3-codex` | Autonomous deep worker (goal-oriented, GPT-native) |

### Review (GPT via GitHub Copilot)

| Agent | Model | Purpose |
|-------|-------|---------|
| **momus** | `github-copilot/gpt-5.2` | Ruthless plan reviewer, catches gaps before execution |
| **oracle** | `github-copilot/gpt-5.3-codex` | High-IQ architecture consultation, debugging |

### Research

| Agent | Model | Purpose |
|-------|-------|---------|
| **explore** | `github-copilot/gpt-5-mini` | Fast codebase grep - patterns, implementations, file structures |
| **librarian** | `github-copilot/gemini-3-flash-preview` | External research - official docs, GitHub examples, remote repos |
| **atlas** | `anthropic/claude-sonnet-4-6` | Todo orchestration and execution |

### Specialized

| Agent | Model | Purpose |
|-------|-------|---------|
| **multimodal-looker** | `github-copilot/gemini-3-flash-preview` | PDF/image analysis |
| **document-writer** | `github-copilot/gemini-3-pro-preview` | Norwegian technical blog writing |

## Categories

Categories are used with `task(category="...")` to route work to optimal models.

### When to Use Each Category

#### `visual-engineering` (`github-copilot/gemini-3-pro-preview`)
- Frontend development
- UI/UX implementation
- Styling and animations
- React/Vue/Svelte components

#### `ultrabrain` (`github-copilot/gpt-5.3-codex`, reasoning: high)
- Complex algorithms
- Architecture decisions
- Hard debugging problems
- Multi-system design

#### `deep` (`github-copilot/gpt-5.3-codex`, reasoning: medium)
- Goal-oriented autonomous work
- Problems requiring thorough research before action
- End-to-end feature implementation

#### `artistry` (`github-copilot/gemini-3-pro-preview`)
- Creative problem-solving
- Unconventional approaches
- Novel solutions beyond standard patterns

#### `quick` (`anthropic/claude-haiku-4-5`)
- Single file changes
- Typo fixes
- Simple modifications
- Trivial tasks

#### `unspecified-low` (`anthropic/claude-sonnet-4-6`)
- Low-effort tasks that don't fit other categories

#### `unspecified-high` (`anthropic/claude-opus-4-6`, variant: max)
- High-effort tasks that don't fit other categories

#### `writing` (`github-copilot/gemini-3-flash-preview`)
- Documentation
- Technical writing
- Prose content

## Delegation Patterns

### Basic Delegation

```typescript
task(
  category="quick",
  load_skills=[],
  prompt="Fix the typo in README.md",
  run_in_background=false
)
```

### With Skills

```typescript
task(
  category="visual-engineering",
  load_skills=["frontend-ui-ux", "playwright"],
  prompt="Create a responsive navbar with dark mode toggle",
  run_in_background=false
)
```

### Background Tasks (Parallel)

```typescript
// Fire multiple explore/librarian agents in parallel
task(
  subagent_type="explore",
  load_skills=[],
  prompt="Find authentication patterns in this codebase",
  run_in_background=true
)
task(
  subagent_type="librarian", 
  load_skills=[],
  prompt="Find Next.js middleware examples for auth",
  run_in_background=true
)
```

### Session Continuation

Always continue sessions for follow-up work:

```typescript
task(
  session_id="ses_abc123",  // From previous task output
  prompt="Fix: the type error on line 42",
  load_skills=[]
)
```

## Background Task Concurrency

| Provider | Max Parallel |
|----------|--------------|
| Default | 5 |
| Anthropic | 3 |
| GitHub Copilot | 5 |

## MCPs Enabled

- **context7** - Official library documentation lookup
- **playwright** - Browser automation (in opencode.json)
- **websearch** - Web search via Exa AI
- **grep_app** - GitHub code search

### Using Context7

```typescript
// First resolve library ID
mcp_context7_resolve-library-id(
  libraryName="react",
  query="useState hook usage"
)

// Then query docs
mcp_context7_query-docs(
  libraryId="/websites/react_dev",
  query="How to use useState hook"
)
```

## Cost Optimization Strategy

| Tier | Provider | Models | Use For |
|------|----------|--------|---------|
| **Expensive** | Anthropic | `claude-opus-4-6` | Orchestration, planning, deep work |
| **Mid-tier** | Anthropic | `claude-sonnet-4-6` | Atlas, general delegation |
| **Cheap** | Anthropic | `claude-haiku-4-5` | Quick tasks |
| **Deep reasoning** | GH Copilot | `gpt-5.3-codex`, `gpt-5.2` | Oracle, hephaestus, ultrabrain, deep, momus |
| **Fast utility** | GH Copilot | `gpt-5-mini` | Explore (codebase grep) |
| **Visual/Creative** | GH Copilot | `gemini-3-pro-preview` | Frontend, artistry, document-writer |
| **Light tasks** | GH Copilot | `gemini-3-flash-preview` | Writing, multimodal-looker, librarian |

## Key Learnings

1. **Gemini models need `-preview` suffix** - Use `gemini-3-flash-preview` and `gemini-3-pro-preview`, NOT `gemini-3-flash` or `gemini-3-pro`. OpenCode resolves model IDs from models.dev, not GitHub display names.

2. **Categories must be configured** - They don't use built-in defaults unless explicitly set in `oh-my-opencode.json`

3. **Explore/Librarian are grep-like** - Fire liberally in parallel, they're cheap

4. **Oracle uses GPT for principle-driven reasoning** - Not Claude. GPT-5.3-codex excels at architecture consultation.

5. **Session IDs are critical** - Always continue sessions for follow-ups to preserve context

6. **Skills must be passed** - Use `load_skills=["skill-name"]` to inject specialized knowledge

7. **`gpt-5.3-codex` works via GH Copilot** - Even though it's not yet in models.dev, it's listed on GitHub's supported models page and works in practice

## Model ID Reference (GitHub Copilot)

Exact model IDs confirmed working or available via `github-copilot/` provider:

| Model ID | Status |
|----------|--------|
| `gpt-5-mini` | ✅ Verified |
| `gpt-5.2` | ✅ Verified |
| `gpt-5.3-codex` | ✅ Verified (not yet in models.dev) |
| `gpt-5.2-codex` | Available |
| `gpt-5.1-codex` | Available |
| `gpt-5.1-codex-max` | Available |
| `gemini-3-flash-preview` | Available (⚠️ `-preview` required) |
| `gemini-3-pro-preview` | Available (⚠️ `-preview` required) |
| `gemini-3.1-pro-preview` | Available (⚠️ `-preview` required) |
| `gemini-2.5-pro` | Available |
| `grok-code-fast-1` | Available (in models.dev, failed in practice — using gpt-5-mini instead) |

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/opencode/oh-my-opencode.json` | Agent/category configuration |
| `~/.config/opencode/opencode.json` | MCP servers, providers, plugins |
| `.opencode/oh-my-opencode.json` | Project-level overrides |
