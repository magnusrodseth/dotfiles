# PROTOCOL.md template

Write this file at the target repo root during phase 2, filled from the
grilling session. Every value must be concrete; a "TBD" blocks the loop.
The human owns this file: the loop reads it, only the human edits it.

```md
# Autoresearch protocol: <run-tag>

## Objective

- Metric: <name>, <lower|higher> is better
- Measured by: `<eval command>` (prints `<metric>: <value>`)
- Baseline: <value> (noise floor: +/- <spread>, from N unchanged runs)

## Stopping condition

<one or more of:>
- Target: metric reaches <value>
- Budget: <N> experiments or <T> hours wall-clock
- Plateau: no keep in the last <K> experiments
- Until interrupted (only if the user said so explicitly)

## Mutable artifact

<paths the loop may edit, e.g. `src/translator/**`>

## Frozen zone (referee)

<eval script, test data, dependencies, configs that only the human may touch>

## Constraints

- <resource ceilings: memory, cost, external rate limits>
- <hard rules: APIs that must not break, checks that must stay green>
- Simplicity criterion: <how much complexity a marginal gain is worth;
  deleting code for equal results is a win>

## Eval budget

<fixed time per experiment; kill and journal as crash at 2x>

## Idea seeds

- <starting directions that came out of the grilling session>
```
