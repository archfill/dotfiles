"""Check shell boundaries without Keychain access or starting an agent."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


HELPER = Path(__file__).resolve().parents[1] / '.config/zsh/lib/agent-cli.zsh'


@unittest.skipUnless(shutil.which('zsh'), 'zsh is required')
class AgentShellTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.local = self.home / '.local/bin'
        self.local.mkdir(parents=True)
        self.runtime = self.home / 'runtime/bin'
        self.runtime.mkdir(parents=True)
        self.env = dict(HOME=str(self.home), PATH='/usr/bin:/bin', ZDOTDIR=str(self.home))

    def shell(self, script, *args):
        return subprocess.run(['zsh', '-dfc', script, 'test', str(HELPER), *map(str, args)],
                              env=self.env, capture_output=True, text=True, timeout=10)

    def test_runtime_precedes_local_without_reordering_project_tools(self):
        result = self.shell('''
source "$1"
path=("$2" "$3" "$4" "$4" /usr/bin /bin)
setup_agent_runtime_path "$4"
first="$PATH"
setup_agent_runtime_path "$4"
[[ "$PATH" == "$first" ]] || exit 9
print -rl -- "${path[@]}"
''', self.home / 'project/bin', self.local, self.runtime)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [
            str(self.home / 'project/bin'), str(self.runtime), str(self.local), '/usr/bin', '/bin'])

    def test_absent_runtime_leaves_path_unchanged(self):
        result = self.shell('''
source "$1"
path=("$2" /usr/bin /bin)
first="$PATH"
setup_agent_runtime_path "$3"
[[ "$PATH" == "$first" ]]
''', self.local, self.home / 'missing')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_helper_does_not_wrap_pi_with_agent_auth(self):
        # Pi resolves its keys itself through `agent-auth read` in auth.json, so the
        # shared helper must not reintroduce environment injection even when
        # agent-auth and env.refs are present.
        refs = self.home / '.config/agent-auth/env.refs'
        refs.parent.mkdir(parents=True)
        refs.write_text('# synthetic references; never read by this test\n')
        executable = self.local / 'agent-auth'
        executable.write_text('#!/bin/sh\nexit 7\n')
        executable.chmod(0o755)
        result = self.shell('''
OSTYPE=darwin
path=("$2" /usr/bin /bin)
source "$1"
(( $+functions[pi] )) && exit 3
exit 0
''', self.local)
        self.assertEqual(result.returncode, 0, result.stderr)

if __name__ == '__main__':
    unittest.main()
