# Provenance and portability

This skill adapts the workflow in Anthropic's [code-modernization plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-modernization). It uses newly written instructions and does not redistribute upstream executable code.

The reviewed upstream revision is [ab024cdc](https://github.com/anthropics/claude-plugins-official/commit/ab024cdcfa7ca80be204acd4907656ba5a968589). The upstream [Apache 2.0 license](https://github.com/anthropics/claude-plugins-official/blob/ab024cdcfa7ca80be204acd4907656ba5a968589/plugins/code-modernization/LICENSE) is included in `LICENSE`.

## Source-to-skill mapping

| Upstream material | Portable adaptation |
|---|---|
| [Preflight](https://github.com/anthropics/claude-plugins-official/blob/ab024cdcfa7ca80be204acd4907656ba5a968589/plugins/code-modernization/commands/modernize-preflight.md) | Actual build readiness, source completeness, external consumers, and recorded unknowns |
| [Rule extraction](https://github.com/anthropics/claude-plugins-official/blob/ab024cdcfa7ca80be204acd4907656ba5a968589/plugins/code-modernization/commands/modernize-extract-rules.md) | Source-cited rule cards and bounded module coverage |
| [Uplift](https://github.com/anthropics/claude-plugins-official/blob/ab024cdcfa7ca80be204acd4907656ba5a968589/plugins/code-modernization/commands/modernize-uplift.md) | Applicable version deltas, measured source baseline, and dependency order |
| [Transform](https://github.com/anthropics/claude-plugins-official/blob/ab024cdcfa7ca80be204acd4907656ba5a968589/plugins/code-modernization/commands/modernize-transform.md) | Characterization, idiomatic target code, differential execution, and mutation sensitivity |
| [Verify](https://github.com/anthropics/claude-plugins-official/blob/ab024cdcfa7ca80be204acd4907656ba5a968589/plugins/code-modernization/commands/modernize-verify.md) | Fresh inputs, executed evidence, coverage gaps, and scoped verdicts |

## Changes from upstream

- One skill routes assessment, execution, resume, and verification through durable repository files.
- Sequential execution works without specialized agents or workflow APIs. Delegation follows explicit authorization and host limits.
- The host's tools replace plugin-root paths, Claude commands, question APIs, hooks, and custom panes.
- Existing user authority determines whether implementation may proceed. There is no repeated approval ceremony for already authorized work.
- Check commands and comparison harnesses come from the actual repository and selected stack. No generic upstream proof engine is bundled.
- Coverage determines fresh test inputs and scope claims. Fixed fleet sizes, model claims, token estimates, and universal test-count thresholds are omitted.

The skill is an instruction workflow. Its verdict procedure relies on executed repository checks and preserved evidence; it does not enforce gates through a plugin runtime.

## Example requests

- “Use code-modernization to assess this Ember repository. Propose a pilot; keep production code unchanged.”
- “Use code-modernization to migrate the approved utility batch to TypeScript and verify its behavior.”
- “Use code-modernization to upgrade the selected runtime version. Keep public contracts unchanged.”
- “Use code-modernization to resume this run from STATE.md.”
- “Use code-modernization to verify this migration diff. Report coverage gaps and behavioral differences.”
