#!/usr/bin/env python3
"""Verify app skill provenance, loss prevention, and shared discovery."""

import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT_DIR = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("app_skills", SCRIPT_DIR / "link-app-skills.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class AppSkillsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.home = self.root / "home"
        self.source = self.root / "app/skill.md"
        self.source.parent.mkdir()
        self.source.write_text("---\nname: app-cli\ndescription: App CLI\n---\nVersion one\n")
        self.manifest = self.root / "app-skills.json"
        self.manifest.write_text(json.dumps({
            "app-cli": {"source": str(self.source), "mirrors": [".pi/agent/skills"]}
        }))
        self.canonical = self.home / ".agents/skills/app-cli"
        self.claude = self.home / ".claude/skills/app-cli"
        self.pi = self.home / ".pi/agent/skills/app-cli"

    def link(self, only=""):
        with contextlib.redirect_stdout(io.StringIO()):
            module.link_skills(self.home, self.manifest, only)

    def test_shared_files_follow_app_updates_and_repeat_safely(self):
        self.link()
        self.link()
        self.assertEqual((self.canonical / "SKILL.md").resolve(), self.source)
        self.assertEqual(self.claude.resolve(), self.canonical)
        self.assertEqual(self.pi.resolve(), self.canonical)
        self.source.write_text("Version two\n")
        for path in [self.canonical, self.claude, self.pi]:
            self.assertEqual((path / "SKILL.md").read_text(), "Version two\n")

    def test_matching_copies_are_replaced_by_links(self):
        for path in [self.canonical, self.claude, self.pi]:
            path.mkdir(parents=True)
            shutil.copy2(self.source, path / "SKILL.md")
        self.link()
        self.assertTrue((self.canonical / "SKILL.md").is_symlink())
        self.assertTrue(self.claude.is_symlink())
        self.assertTrue(self.pi.is_symlink())

    def test_stowed_mirror_uses_its_physical_parent(self):
        stowed = self.home / "dotfiles/.pi"
        stowed.mkdir(parents=True)
        (self.home / ".pi").symlink_to(stowed)
        self.link()
        self.assertEqual(self.pi.resolve(), self.canonical)
        self.assertEqual(self.pi.readlink(), Path("../../../../.agents/skills/app-cli"))

    def test_local_edits_prevent_all_replacements_for_that_skill(self):
        self.claude.mkdir(parents=True)
        (self.claude / "SKILL.md").write_text("Local edits\n")
        with self.assertRaisesRegex(ValueError, "local changes"):
            self.link()
        self.assertFalse(self.canonical.exists())
        self.assertEqual((self.claude / "SKILL.md").read_text(), "Local edits\n")

    def test_uninstalled_app_is_optional_but_missing_live_source_fails(self):
        self.source.unlink()
        self.link()
        self.assertFalse(self.canonical.exists())
        self.canonical.mkdir(parents=True)
        with self.assertRaisesRegex(ValueError, "app source missing"):
            self.link()

    def test_selection_preserves_other_skills(self):
        self.link("some-other-skill")
        self.assertFalse(self.canonical.exists())

    def test_integrity_rejects_a_copy_with_declared_app_provenance(self):
        self.link()
        repo = self.home / "dotfiles"
        scripts = repo / "scripts/skills"
        scripts.mkdir(parents=True)
        (repo / ".claude/skills").mkdir(parents=True)
        shutil.copy2(SCRIPT_DIR / "check-skill-integrity.sh", scripts)
        shutil.copy2(self.manifest, scripts / "app-skills.json")
        (scripts / "skill-lock.json").write_text('{"skills": {}}\n')
        env = {**os.environ, "HOME": str(self.home)}
        command = ["bash", str(scripts / "check-skill-integrity.sh")]
        result = subprocess.run(command, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        (self.canonical / "SKILL.md").unlink()
        shutil.copy2(self.source, self.canonical / "SKILL.md")
        result = subprocess.run(command, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("App skill source/link mismatch", result.stderr)

    def test_validator_accepts_removed_links_but_rejects_dangling_links(self):
        repo = self.home / "dotfiles"
        scripts = repo / "scripts/skills"
        scripts.mkdir(parents=True)
        (repo / ".claude/skills").mkdir(parents=True)
        shutil.copy2(SCRIPT_DIR / "validate-skills.sh", scripts)
        subprocess.run(["git", "init", "-q", str(repo)], check=True, capture_output=True)
        link = repo / ".pi/agent/skills/retired-skill"
        link.parent.mkdir(parents=True)
        link.symlink_to("../missing")
        subprocess.run(["git", "-C", str(repo), "add", str(link)], check=True,
                       capture_output=True)
        link.unlink()
        command = ["bash", str(scripts / "validate-skills.sh")]
        result = subprocess.run(command, cwd=repo, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        link.symlink_to("../missing")
        result = subprocess.run(command, cwd=repo, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken symlink", result.stderr)


if __name__ == "__main__":
    unittest.main()
