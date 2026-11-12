# Inspect installed game data

## Locate and identify

`python3 scripts/blueprint.py inspect` finds the usual macOS Steam installation and user data. Use `--factorio` and `--user-data` overrides for another location.

The current log records the game version, read-data path, write-data path, and loaded mod versions. Read only those lines. `mods/mod-list.json` records enabled mods. Do not select a mod archive by lexicographic filename order: version 2.0.9 sorts after 2.0.19 as text. Let the game resolve installed versions, or compare numeric version components.

List and read Lua directly from ZIP archives with Python's `zipfile`, without extracting copyrighted game assets into the skill:

```python
from pathlib import Path
from zipfile import ZipFile

with ZipFile(archive_path) as archive:
    matches = [p for p in archive.namelist() if p.endswith('/prototypes/recipes/growing.lua')]
    print(archive.read(matches[0]).decode())
```

## Follow the prototype changes

Read the entity, recipe, item, technology, startup settings, and compatibility code involved. Follow `data.lua`, `data-updates.lua`, and `data-final-fixes.lua` imports when an initial definition disagrees with behavior.

Record:

- Internal entity, item, fluid, recipe, and category names.
- Recipe ingredients, result ranges, crafting time, and unlocks.
- Crafting speed, footprint, collision/selection boxes, energy source, and consumption.
- Inserter pickup/drop positions and belt lane behavior.
- Pipe port positions and direction, fluid categories, and water requirements.
- Pole coverage and wire distance.

K2 examples that caused real failures:

- An older source mirror used `sand` and `glass`; the installed release used `kr-sand` and `kr-glass`.
- K2 converted smelting furnaces to assembling machines during final updates. Their blueprint needed an explicit glass recipe.
- The crusher retained furnace behavior and selected sand from stone. Do not assume all crafting entities select recipes the same way.
- Boiler output, coal fuel value, offshore pump electricity, and mining ratios differed from vanilla guides.

Prefer the final loaded prototypes over partial Lua parsing. When necessary, run `--dump-data` through an isolated config and inspect the resulting JSON. Do not dump into the live game's write-data directory.

## Sources

- [Blueprint string format](https://wiki.factorio.com/Blueprint_string_format)
- [Factorio runtime API](https://lua-api.factorio.com/latest/)
- [Krastorio 2 source and release information](https://mods.factorio.com/mod/Krastorio2)

Use documentation matching the installed game version. The latest API may describe another major or minor release.
