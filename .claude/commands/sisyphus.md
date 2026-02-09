# /sisyphus

Analyze the request: $ARGUMENTS

## Workflow

1. **Context Management**: Use `context-management:context-manager` to persist context across the workflow and manage long-running conversation state.

2. **Codebase Exploration**: Use `feature-dev:code-explorer` to analyze relevant files, trace execution paths, understand architecture layers and patterns, and identify key files.

3. **Architecture Design**: Use `feature-dev:code-architect` to design an implementation plan based on existing patterns and conventions. Should provide specific files to create/modify, component designs, and build sequence.

4. **Iterative Implementation**: Use `ralph-loop:ralph-loop` to implement code iteratively until all tests pass.

5. **Quality Review** (optional): Use `feature-dev:code-reviewer` to find bugs, quality issues, and violations of project conventions.

## Rules

- Do not ask for permission for Bash commands like `ls`, `grep`, or `make api-test`.
- Report status when 100% complete or if blocked.
