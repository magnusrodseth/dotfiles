#!/usr/bin/env python3
"""Link declared app-bundled skills into the shared root and agent mirrors."""

import json
import os
from pathlib import Path
import re
import sys


def link_skills(home, manifest, only=""):
    entries = json.loads(manifest.read_text())
    for name, entry in entries.items():
        if only and name != only:
            continue
        if not re.fullmatch(r"[a-z0-9]([a-z0-9-]*[a-z0-9])?", name):
            raise ValueError(f"Invalid app skill name: {name}")
        source = Path(entry["source"])
        canonical = home / ".agents/skills" / name
        if not source.is_file():
            if canonical.exists() or canonical.is_symlink():
                raise ValueError(f"{name}: app source missing: {source}")
            print(f"Skipped {name}: app not installed")
            continue
        if canonical.is_symlink():
            raise ValueError(f"{canonical}: expected an app skill directory")

        # Validate every replacement before touching any path for this skill.
        mirrors = [home / ".claude/skills" / name]
        for root in entry.get("mirrors", []):
            path = Path(root)
            if path.is_absolute() or ".." in path.parts:
                raise ValueError(f"Invalid mirror root: {root}")
            mirrors.append(home / path / name)
        for path in [canonical, *mirrors]:
            if path.is_symlink() or not path.exists():
                continue
            if not path.is_dir():
                raise ValueError(f"{path}: expected a skill directory")
            files = list(path.iterdir())
            skill = path / "SKILL.md"
            if (len(files) != 1 or files[0].name != "SKILL.md"
                    or not skill.is_file() or skill.read_bytes() != source.read_bytes()):
                raise ValueError(f"{path}: local changes; preserve them before linking")

        canonical.mkdir(parents=True, exist_ok=True)
        skill = canonical / "SKILL.md"
        if not skill.is_symlink() or skill.readlink() != source:
            skill.unlink(missing_ok=True)
            skill.symlink_to(source)
        for mirror in mirrors:
            if mirror.is_symlink() and mirror.resolve() == canonical.resolve():
                continue
            if mirror.is_symlink():
                mirror.unlink()
            elif mirror.exists():
                (mirror / "SKILL.md").unlink()
                mirror.rmdir()
            mirror.parent.mkdir(parents=True, exist_ok=True)
            # Stow may make the parent a symlink into dotfiles. Relative links
            # resolve from that physical directory, which is one level deeper.
            mirror.symlink_to(os.path.relpath(canonical.resolve(), mirror.parent.resolve()))
        print(f"Linked app skill: {name}")


if __name__ == "__main__":
    if len(sys.argv) > 2:
        sys.exit("Usage: link-app-skills.py [skill-name]")
    try:
        link_skills(Path.home(), Path(__file__).with_name("app-skills.json"),
                    sys.argv[1] if len(sys.argv) == 2 else "")
    except (OSError, ValueError, KeyError) as error:
        sys.exit(f"App skill linking failed: {error}")
