# Isolated, bounded game validation

## Case manifest

Use the worked example to generate a manifest, then adapt its fixtures and acceptance criteria for the new production line:

```bash
python3 examples/greenhouses.py --output /tmp/greenhouse-artifacts --game-version 2.0.77
python3 scripts/blueprint.py simulate /tmp/greenhouse-artifacts/cases.json --report /tmp/greenhouse-artifacts/validation.json
```

Each case names a single blueprint JSON, warmup/sample ticks, external power fixture positions, supplied inputs, and collected outputs. Coordinates refer to the blueprint's original JSON coordinates. The harness accounts for the game's placement offset using the lexicographically first matching entity of the blueprint's first entity type.

Supported input fixtures:

- `belts`: entity position, item, lanes, and `every_ticks`; inserts one item per selected lane at the specified interval.
- `fluids`: entity name/position, fluid name, amount, and `every_ticks`; fills that entity's fluid inventory.

Outputs specify an item, a container entity type such as `wooden-chest`, and a minimum collected items/minute. The harness removes output from matching containers each second, so storage limits do not invalidate a sustained-capacity test. Use a separate test for backing up and recovery when relevant.

For labs, oil, power generation, trains, fluids with byproducts, or circuit logic, adapt the Lua harness or add a dedicated fixture. A generic item-output test cannot prove those systems work. State fixture assumptions explicitly.

## Isolation guarantees

The runner creates a fresh temporary directory containing:

- An isolated config with the discovered read-data directory and a fresh write-data path.
- Read-only references to installed mod ZIPs/directories, a copied mod list, and copied mod settings.
- A validator mod and a generated test map. All benchmark commands point to this map.

It never uses a player save. It does not edit the live config, mods, clipboard, or factory. Each child command has a timeout. Keep the temporary log path on failure and diagnose the actual error before retrying. Do not launch a normal GUI client over the user's running session.

## Assertions

The harness imports the string and requires the full expected ghost count. It revives every ghost, keeps all recipe unlocks available, and avoids research bonuses. It supplies test power separately from the delivered entities.

Inspect the report for:

1. Import, full entity placement, and a successful process exit.
2. Collected outputs above each declared minimum after warmup.
3. Recipe status, input shortages, blocked outputs, and electric network membership when diagnosis is needed.
4. Actual loaded game/mod versions in `create.log` and `benchmark.log`.

Batch recipes create short-window variance. Use a long enough sample or set a justified minimum. Do not mask a bottleneck by lowering the threshold. Distinguish nominal recipe capacity, measured collected output, and the live factory's available inputs.

## Known fixes from the first session

| Symptom | Evidence | Fix |
|---|---|---|
| Crusher output filled; downstream stayed empty | Poles had different network IDs | Include copper wires in blueprint JSON |
| Furnaces reported `no_recipe` | Final prototypes required recipe selection | Preset `kr-glass` on the furnaces |
| Expanded furnace row slowed | Shared yellow output inserter could not empty the belt | One output chest per furnace |
| An inserter stayed idle | Pole coverage missed its tile | Move the pole, then retest |

Never decode the numeric status from memory. Match the running game's `defines.entity_status` names.
