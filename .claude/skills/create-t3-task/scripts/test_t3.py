"""The launcher preserves literal prompts, explicit targeting and exit status."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


LAUNCHER = Path(__file__).with_name("t3.sh")


class LauncherTest(unittest.TestCase):
    def test_literal_arguments_and_multiline_stdin_reach_selected_cli(self):
        with tempfile.TemporaryDirectory() as directory:
            fake = Path(directory) / "T3 fake"
            fake.write_text(
                "#!/usr/bin/env python3\n"
                "import json,sys\n"
                "print(json.dumps({'args':sys.argv[1:],'stdin':sys.stdin.read()}))\n"
            )
            fake.chmod(0o700)
            prompt = 'Preserve æøå\nLiteral $(echo unexpected); `echo unexpected`\n'
            args = ["thread", "start", "/repo with spaces", "-", "--title", "Literal; title"]
            result = subprocess.run(
                ["bash", str(LAUNCHER), *args],
                env={**os.environ, "T3_CLI_BIN": str(fake)},
                input=prompt, text=True, capture_output=True, check=True,
            )
            self.assertEqual(json.loads(result.stdout), {"args": args, "stdin": prompt})

    def test_failure_is_propagated_without_fallback_or_retry(self):
        with tempfile.TemporaryDirectory() as directory:
            fake = Path(directory) / "t3"
            fake.write_text("#!/bin/sh\nprintf 'one attempt\\n' >&2\nexit 2\n")
            fake.chmod(0o700)
            result = subprocess.run(
                ["bash", str(LAUNCHER), "thread", "start"],
                env={**os.environ, "T3_CLI_BIN": str(fake)},
                text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 2)
            self.assertEqual(result.stderr, "one attempt\n")

    def test_missing_explicit_cli_does_not_fall_back_to_the_live_app(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                ["bash", str(LAUNCHER), "thread", "start"],
                env={**os.environ, "T3_CLI_BIN": str(Path(directory) / "missing")},
                text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 127)
            self.assertIn("not executable", result.stderr)


if __name__ == "__main__":
    unittest.main()
