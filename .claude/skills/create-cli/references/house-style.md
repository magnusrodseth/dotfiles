# House Style: Agent-Ready Personal CLIs

Extracted from the two exemplar repos, which share an identical skeleton
stamped over two domains. When building (not just designing) a CLI, treat
that skeleton as the scaffold and fill in the domain.

- `~/dev/personal/sparebank1-cli` (crate `sparebank1-cli`, bin `sb1`): OAuth loopback login, read + mutating commands (transfers)
- `~/dev/personal/skatteetaten-cli` (crate `skatteetaten-cli`, bin `skt`): CDP cookie-capture login, read-only by design

The auth model is a per-domain override. Everything else below is shared.

## Stack and packaging

1. Rust, clap v4 derive (features `["derive", "env", "wrap_help"]`), single
   binary. `edition 2021`, `rust-version 1.80`. Crate named `<thing>-cli`,
   short 2-3 char binary name via `[[bin]]`. Release profile: `strip = true`,
   `lto = true`, `codegen-units = 1`.
2. Three install paths, prebuilt-first: `curl .../install.sh | bash` into
   `~/.local/bin`, then `cargo install <crate>`, then `--path .`. The
   installer is portable bash (`set -euo pipefail`, `die()` helper, uname
   detection, `<PREFIX>_VERSION` / `<PREFIX>_INSTALL_DIR` overrides,
   download to tempfile before untar, PATH hint at the end). It never calls
   the GitHub API (anonymous rate limit breaks busy agents); it uses the
   `releases/latest/download/<asset>` redirect.

## Interface

3. Global `--json` on the root (`global = true`), threaded through handlers
   as an `OutputMode { Table, Json }` enum. Tables are for humans
   (comfy-table, locale-formatted money like `kr 1 234,56`); JSON never
   rounds or localizes.
4. Global `--mask` for screenshots: redacts sensitive cells in table output
   only, never in `--json`/CSV, so automation stays unredacted.
5. stdout is data, stderr is errors + prompts + progress. `main` prints the
   full error chain to stderr and exits non-zero.
6. Root `#[derive(Parser)] Cli` with globals + `#[command(subcommand)]`;
   flat `enum Command`, nesting only where the domain needs it. Doc comments
   ARE the help text. One `match` dispatch in `commands::run`.
7. Fuzzy, forgiving resolvers for user-supplied identifiers (exact key,
   number, exact name, unique partial; ambiguous is a hard error),
   implemented as pure unit-tested functions.

## Secrets and config

8. Secret storage behind `<PREFIX>_STORE` with three backends: `keychain`
   (default; native per-OS keyring crates, zero system libraries), `op`
   (1Password CLI shell-out), `file` (explicit opt-in, `0600`,
   `~/.config/<crate>/`, XDG-aware). Unknown or unset falls back to
   keychain, never silently to plaintext. `status`/`login` print the active
   backend and all alternatives.
9. Bootstrap credentials from flag, then env, then git-ignored `.env`
   (minimal hand-rolled dotenv parser), then persist to the store so `.env`
   can be deleted. `.gitignore` blocks `.env*` (keep `.env.example`) and
   any session/token files.

## Errors, safety, etiquette

10. Two-layer errors: a `thiserror` enum for branchable cases
    (`NotAuthenticated`, `SessionExpired`, `RateLimited { retry_after }`,
    `Api { status, message }`, `AuthFlow`, plus `#[from]` transport errors)
    and `anyhow` for glue. Error messages state the fix, not just the fault.
11. Irreversible actions print a summary and confirm (`Proceed? [y/N]`,
    default No), skippable only with explicit `-y`. Scope-restrict mutations
    (e.g. transfers only between the user's own accounts). Read-only tools
    have zero mutating commands as a design invariant.
12. Good API citizen: honest versioned `User-Agent` with repo URL, one
    request per call, no retry or polling loops, honor `Retry-After` on 429,
    never bypass rate limits. Provider terms live in `terms.rs` + `TERMS.md`.

## Agent pairing (what makes it agent-ready)

13. Ship agent skills in-repo under `skills/` (SKILL.md with `name`,
    `description`, `compatibility` frontmatter), installable via
    `npx skills add <owner>/<repo>`. Always include a `<tool>-shared`
    runtime-contract skill read first: install, login, storage-backend
    table, output/flags contract, a command-map table (command, purpose,
    owning skill), and API etiquette.
14. `AGENTS.md` at repo root is the agent landing page: what the tool is,
    how to install it, the once-only user setup the agent cannot do, how to
    install the skills, and an explicit "Operating rules for agents" list
    (use `--json` when parsing; confirm before mutations; never pass `-y`
    unless told this session; check `status` and relogin on auth errors;
    do not retry in loops).
15. Optional but proven: a `<tool>-context` skill that interviews the user
    once and writes a private git-ignored `~/.config/<crate>/context.md`
    for the meaning layer the API cannot know. Keep raw API captures in
    `docs/api/` as the source of truth when responses drift.

## Layout, tests, CI

- Fixed `src/` spine: `main.rs` (thin), `cli.rs`, `commands/` (dispatch +
  one file per group), `client.rs`, `auth.rs`, `secrets.rs`, `error.rs`,
  `format.rs`, `models.rs`, `util.rs`, `terms.rs`.
- Tests co-located as `#[cfg(test)] mod tests`; pure logic factored out so
  it tests without network; no live-credential tests.
- CI: `cargo fmt --check`, `clippy --all-targets -D warnings`, `test`,
  release build. Release: tag `vX.Y.Z` triggers a 4-target matrix
  (darwin/linux x86_64/aarch64) of tarballs plus an idempotent crates.io
  publish. SemVer; conventional-ish commits (`feat:`, `docs:`, `ci:`,
  `skills:`, `Release vX.Y.Z`).
- Root files: `README.md` (banner, agent-ready tagline, natural-language
  agent prompts, install, setup, secret-storage table, usage, commands-to-
  API mapping table, development, releasing), `AGENTS.md`, `TERMS.md`,
  `LICENSE` (MIT), `.env.example`, `install.sh`.

## Fill-ins when stamping the skeleton

Crate + bin name, `<PREFIX>_` env-var prefix, domain command tree, auth
module (the one true divergence point), provider terms, skills content.
Copy `secrets.rs`, `install.sh`, `error.rs`, and the CI/release workflows
from an exemplar repo and adapt names.
