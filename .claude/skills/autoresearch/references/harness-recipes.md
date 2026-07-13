# Harness recipes

How to build the frozen referee for common domains, and how to keep it
honest. Read before phase 3.

## The referee contract

Whatever the domain, the referee is one command that:

1. Exercises the artifact under a **fixed budget** (time, iterations, or
   request count), so every experiment is directly comparable no matter what
   changed.
2. Prints exactly one machine-parseable metric line: `metric: <value>`.
   Secondary numbers (memory, cost) may follow on their own lines.
3. Exits non-zero on crash or rule violation, so an empty grep means failure.
4. Is reproducible enough that the noise floor (spread across 2-3 unchanged
   runs) is well below the effect size worth keeping.

## Recipes by domain

| Domain | Mutable artifact | Metric | Referee sketch |
|---|---|---|---|
| Failing test suite | source code | tests passed | run suite, parse pass count from the runner's summary line |
| Runtime performance | hot-path code | p50/p99 latency, ops/s | fixed-iteration benchmark, warmup excluded, pinned inputs |
| Web performance | components, CSS, bundler config | Lighthouse score, CWV | headless Lighthouse against a local build, fixed throttling |
| Bundle size | imports, config | bytes gzipped | build + measure the artifact file |
| Prompt engineering | system prompt | eval-set score | fixed eval set scored by a pinned judge (model + prompt + temperature 0); judge is part of the frozen zone |
| SQL / queries | queries, indexes | execution time, rows scanned | EXPLAIN ANALYZE on a pinned dataset snapshot |
| ML training | training script | val loss / bpb | fixed wall-clock training, held-out eval shard (the original autoresearch) |
| API cost | routing, caching rules | cost per quality-unit | replay a pinned request log, sum cost, gate on quality floor |

## Noise handling

- Measure the noise floor first: 2-3 referee runs on the unchanged artifact.
  A keep requires improvement greater than this spread, not just any delta.
- Stochastic metrics (LLM judge, network timing): pin seeds and temperature
  where possible; otherwise average N runs and freeze N into the protocol.
- Timing metrics: pin the machine state you can (close other loads, fixed
  iteration counts, warmup runs excluded from measurement).

## Anti-Goodhart checklist

The metric must survive an agent optimizing hard against it.

- **Proxy metrics need held-out data.** When the metric is the true goal
  (tests passed, bundle bytes), a visible eval is fine. When it is a proxy
  for something bigger (val loss for generalization, judge score for
  quality), evaluate on inputs the loop cannot read or memorize.
- **Referee files are read-only to the loop.** The structural boundary, not
  a polite request: eval script, eval data, judge prompt, rule checks all
  live in the frozen zone.
- **Metric invariant to superficial reformulation.** The original uses
  bits-per-byte so vocabulary changes can't game it. Ask: what trivial
  restructuring would move my metric without real improvement? Normalize it
  away.
- **Excluded elements score zero.** Padding, special tokens, skipped tests:
  anything outside the measured set must contribute nothing, or the loop
  will farm it.
- **Workaround iteration is a signal, not a strategy.** If the loop keeps
  finding new ways to pass a check rather than improving the artifact, the
  shortcut and the detector are playing the same game on opposite sides.
  Stop, accept the extra complexity, and build the structurally correct
  solution. It is the only one that holds.
