---
name: vault
description: Extract insights from conversations and store them in your Obsidian vault. Use when you want to capture learnings, how-to guides, brags, decisions, or any knowledge from the current chat into your second brain. Triggers on "save to vault", "store this in obsidian", "capture this learning", "add to vault", "remember this in obsidian", or any request to persist knowledge to the Obsidian vault.
---

# Vault Knowledge Capture

Extract valuable insights from conversations and store them in the user's Obsidian vault.

Can be invoked from ANY project on the machine.

## Configuration

Resolve the vault location first, then use `$VAULT` everywhere below:

```bash
if [ -d "$HOME/dev/personal/vault" ]; then
    VAULT="$HOME/dev/personal/vault"          # local machine (any cwd)
else
    VAULT="${CLAUDE_PROJECT_DIR:-$PWD}"       # cloud session: the repo IS the vault
fi
```

Expand `$HOME` to the user's actual home directory. The fallback matters in Claude Code cloud/web sessions, where the vault is cloned to a sandbox path and `$HOME/dev/personal/vault` does not exist. On a local machine the first branch always wins, so behaviour there is unchanged.

## Workflow

1. Read `$VAULT/CLAUDE.md` for current vault rules
2. Analyze conversation for knowledge to capture
3. Classify content type: learning | how-to-guide | brag | decision | note | resource | person | project | meeting
4. Read relevant template from `$VAULT/Templates/{Type}.md`
5. Search vault for existing related notes to link to (glob/grep `$VAULT`)
6. Write note to `$VAULT/{folder}/{Note Name}.md`

## Content Type to Folder

| Type | Path |
|------|------|
| learning | `$VAULT/Learning/` |
| how-to-guide | `$VAULT/Reference/` |
| brag | `$VAULT/Personal/` |
| decision | `$VAULT/Personal/` |
| note | `$VAULT/Notes/` |
| resource | `$VAULT/Reference/` |
| person | `$VAULT/Personal/People/` |
| project | `$VAULT/Projects/` |
| meeting | `$VAULT/Meetings/` |

## Required Reading Before Acting

Read these in order before creating any note:

1. `$VAULT/CLAUDE.md` (always)
2. Relevant skills based on task:
   - `$VAULT/.claude/skills/vault-management/SKILL.md`
   - `$VAULT/.claude/skills/obsidian-markdown/SKILL.md`
   - `$VAULT/.claude/skills/dataview/SKILL.md`
   - `$VAULT/.claude/skills/templater/SKILL.md`
   - `$VAULT/.claude/skills/mermaid/SKILL.md`
   - `$VAULT/.claude/skills/excalidraw/SKILL.md`
   - `$VAULT/.claude/skills/advanced-tables/SKILL.md`
   - `$VAULT/.claude/skills/json-canvas/SKILL.md`
   - `$VAULT/.claude/skills/obsidian-bases/SKILL.md`
   - `$VAULT/.claude/skills/omnisearch/SKILL.md`
   - `$VAULT/.claude/skills/obsidian-git/SKILL.md`

## Rules

- Use `[[wiki links]]` for internal references, never markdown links
- Always include YAML frontmatter
- Date format: display `DD.MM.YYYY`, filenames `YYYY-MM-DD`
- File naming: `Human Readable Name.md` (title case with spaces)
- One idea per note (atomic notes)
- Link liberally to build the knowledge graph
- Search vault before creating duplicates
- Always read the source files first; they contain the current truth
