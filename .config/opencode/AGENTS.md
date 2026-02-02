# Oh-My-OpenCode Configuration Guide

This document describes the oh-my-opencode configuration for this setup.

## Quick Reference

| Task Type | Delegate To | Model |
|-----------|-------------|-------|
| Frontend/UI work | `category="visual-engineering"` | gemini-3-pro |
| Hard logic/architecture | `category="ultrabrain"` | opus + thinking |
| Autonomous deep work | `category="deep"` | opus + thinking |
| Creative/unconventional | `category="artistry"` | gemini-3-pro |
| Trivial tasks | `category="quick"` | gemini-3-flash |
| Documentation/writing | `category="writing"` | gemini-3-flash |
| Codebase search | `explore` agent | sonnet |
| External docs/examples | `librarian` agent | sonnet |
| Debugging/consultation | `oracle` agent | opus + thinking |

## Agents

### Orchestration (Opus)

| Agent | Purpose |
|-------|---------|
| **sisyphus** | Main orchestrator - coordinates all work |
| **sisyphus-junior** | Executes delegated tasks from categories |
| **prometheus** | Work planning methodology |
| **metis** | Pre-planning analysis, identifies hidden requirements |
| **momus** | Plan review, catches gaps before execution |

### Execution (Opus)

| Agent | Purpose |
|-------|---------|
| **build** | Primary code builder |
| **plan** | Planning tasks |
| **general** | General-purpose tasks |
| **hephaestus** | Autonomous deep worker (goal-oriented) |

### Research (Sonnet)

| Agent | Purpose |
|-------|---------|
| **explore** | Codebase grep - finds patterns, implementations, file structures |
| **librarian** | External research - official docs, GitHub examples, remote repos |

### Specialized

| Agent | Model | Purpose |
|-------|-------|---------|
| **oracle** | opus + thinking (200k) | High-IQ debugging, architecture consultation |
| **multimodal-looker** | gemini-3-flash | PDF/image analysis |
| **document-writer** | gemini-3-pro | Norwegian technical blog writing |

## Categories

Categories are used with `delegate_task(category="...")` to route work to optimal models.

### When to Use Each Category

#### `visual-engineering` (gemini-3-pro)
- Frontend development
- UI/UX implementation
- Styling and animations
- React/Vue/Svelte components

#### `ultrabrain` (opus + max + thinking 200k)
- Complex algorithms
- Architecture decisions
- Hard debugging problems
- Multi-system design

#### `deep` (opus + max + thinking 200k)
- Goal-oriented autonomous work
- Problems requiring thorough research before action
- End-to-end feature implementation

#### `artistry` (gemini-3-pro + high)
- Creative problem-solving
- Unconventional approaches
- Novel solutions beyond standard patterns

#### `quick` (gemini-3-flash)
- Single file changes
- Typo fixes
- Simple modifications
- Trivial tasks

#### `unspecified-low` (sonnet)
- Low-effort tasks that don't fit other categories

#### `unspecified-high` (opus + max)
- High-effort tasks that don't fit other categories

#### `writing` (gemini-3-flash)
- Documentation
- Technical writing
- Prose content

## Delegation Patterns

### Basic Delegation

```typescript
delegate_task(
  category="quick",
  load_skills=[],
  prompt="Fix the typo in README.md",
  run_in_background=false
)
```

### With Skills

```typescript
delegate_task(
  category="visual-engineering",
  load_skills=["frontend-ui-ux", "playwright"],
  prompt="Create a responsive navbar with dark mode toggle",
  run_in_background=false
)
```

### Background Tasks (Parallel)

```typescript
// Fire multiple explore/librarian agents in parallel
delegate_task(
  subagent_type="explore",
  load_skills=[],
  prompt="Find authentication patterns in this codebase",
  run_in_background=true
)
delegate_task(
  subagent_type="librarian", 
  load_skills=[],
  prompt="Find Next.js middleware examples for auth",
  run_in_background=true
)
```

### Session Continuation

Always continue sessions for follow-up work:

```typescript
delegate_task(
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
| Google | 8 |

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

| Tier | Models | Use For |
|------|--------|---------|
| **Expensive** | opus | Orchestration, planning, debugging, deep work |
| **Mid-tier** | sonnet | Explore, librarian (frequent but need quality) |
| **Cheap** | gemini-3-flash | Quick tasks, writing, multimodal |
| **Specialized** | gemini-3-pro | UI/UX work, creative tasks |

## Key Learnings

1. **Categories must be configured** - They don't use built-in defaults unless explicitly set in `oh-my-opencode.json`

2. **Explore/Librarian are grep-like** - Fire liberally in parallel, they're cheap (sonnet)

3. **Oracle has thinking enabled** - Use for hard problems, architecture consultation

4. **Gemini models marked unstable** - Auto-converted to background mode for monitoring

5. **Session IDs are critical** - Always continue sessions for follow-ups to preserve context

6. **Skills must be passed** - Use `load_skills=["skill-name"]` to inject specialized knowledge

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/opencode/oh-my-opencode.json` | Agent/category configuration |
| `~/.config/opencode/opencode.json` | MCP servers, providers, plugins |
| `.opencode/oh-my-opencode.json` | Project-level overrides |
