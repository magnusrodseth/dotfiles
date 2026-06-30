# What to look for, by intent

The needle is contextual. Find the row matching the north-star question, look where the
answer usually hides, then confirm it with the "idiomatic when" signal before trusting it.
Most runs need one row.

| Intent | Where the answer usually lives | Idiomatic when |
|---|---|---|
| **Use a library's public API** (how do I call X) | Exported entry points (`index.*`, `src/index.*`, package `exports`), `examples/`, the test suite, public type definitions | The same call shape appears in the docs/README *and* the tests |
| **Replicate a pattern across X↔Y** (e.g. share state between two frameworks) | The seam where the two meet: adapter/integration packages, `examples/` apps that combine them, `*-react`/`*-vue`/binding subpackages | It is the project's own documented/example way to bridge them, not hand-rolled glue in one app |
| **Org infra / self-service / security** (e.g. Gjensidige platform) | Terraform modules (`modules/`, `*.tf` variables + outputs), platform pipelines (`.github/`, `.gitlab-ci`, `Azure-Pipelines`), policy folders, module READMEs, naming/tagging conventions | The same module/policy is consumed across ≥2 stacks or repos — reuse proves it's the sanctioned path |
| **Debug an integration** (why does the call to X fail) | Where the client is constructed and configured, error handling / retry / timeout code, the test that reproduces the real call | You've found the actual constructed request, not a wrapper or a mock |
| **Evaluate a dependency** (should we adopt X) | README + public API surface, the implementation behind it (read it, not the marketing), maintenance signals: recent commits, open issues, release cadence, how it's tested | You judged the real code and its upkeep, not the pitch |
| **Match house style** (write code that fits) | `CONTRIBUTING`, lint/format config, the nearest existing sibling of the file you'll add, tests as executable spec | ≥2 existing examples agree on the convention |

## Tactics that cut across rows

- **Grep for the concept, not the guess.** `rg -i "<domain term from the question>"` lands
  faster than browsing folders. Follow the imports from the first real hit.
- **Tests are the spec.** A test that exercises the thing you care about shows the intended
  usage and the edge cases, with no prose drift.
- **Read commit history at the hit** (`git -C <dir> log -p -L` or `git log --oneline -- <file>`)
  when "current vs legacy" is unclear — the newest change usually wins.
- **Entry points first** for an unfamiliar repo: `package.json`/`Cargo.toml`/`main.tf`
  scripts, the `bin`/`cmd` dir, the top of the README's usage section.
