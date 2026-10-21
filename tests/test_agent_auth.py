"""Use synthetic tokens only; never access the real Keychain or 1Password."""

from contextlib import redirect_stdout
import importlib.util
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin/agent-auth.py"
SPEC = importlib.util.spec_from_file_location("agent_auth", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
auth = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(auth)
FAKE_TOKEN = "synthetic-service-account-token"


class AuthTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name).resolve()
        self.refs = self.directory / "env.refs"

    def test_unlock_uses_terminal_prompt_without_password_arguments(self):
        with patch.object(auth.sys.stdin, "isatty", return_value=True), \
                patch.object(auth.sys.stderr, "isatty", return_value=True), \
                patch.object(auth.subprocess, "run", return_value=SimpleNamespace(returncode=0)) as run, \
                redirect_stdout(io.StringIO()):
            auth.unlock_keychain(self.directory)
        run.assert_called_once_with([
            "/usr/bin/security", "unlock-keychain",
            str(self.directory / "Library/Keychains/login.keychain-db"),
        ], check=False)

    def test_unlock_without_terminal_never_starts_security(self):
        for stdin, stderr in ((False, False), (True, False), (False, True)):
            with patch.object(auth.sys.stdin, "isatty", return_value=stdin), \
                    patch.object(auth.sys.stderr, "isatty", return_value=stderr), \
                    patch.object(auth.subprocess, "run") as run, \
                    self.assertRaisesRegex(ValueError, "ssh -t"):
                auth.unlock_keychain(self.directory)
            run.assert_not_called()

    def test_unlock_failure_is_reported(self):
        with patch.object(auth.sys.stdin, "isatty", return_value=True), \
                patch.object(auth.sys.stderr, "isatty", return_value=True), \
                patch.object(auth.subprocess, "run", return_value=SimpleNamespace(returncode=1)), \
                self.assertRaisesRegex(ValueError, "unlock failed"):
            auth.unlock_keychain(self.directory)

    def test_unlock_does_not_require_op_or_read_the_token(self):
        with patch.object(auth.sys, "argv", ["agent-auth", "unlock"]), \
                patch.object(auth.sys, "platform", "darwin"), \
                patch.object(auth.os, "getuid", return_value=501), \
                patch.object(auth.pwd, "getpwuid", return_value=SimpleNamespace(pw_dir=str(self.directory))), \
                patch.object(auth, "find_op") as op, \
                patch.object(auth, "read_token") as token, \
                patch.object(auth, "unlock_keychain") as unlock:
            auth.main()
        unlock.assert_called_once_with(self.directory)
        op.assert_not_called()
        token.assert_not_called()

    def test_auto_mode_injects_for_configured_direct_execution(self):
        config = self.directory / '.config/agent-auth/env.refs'
        config.parent.mkdir(parents=True)
        config.write_text('KEY=op://Agents/item/token\n')
        with patch.dict(os.environ, {}, clear=True), \
                patch.object(auth.sys, 'argv', ['agent-auth', 'auto', '--', '/runtime/pi', '-p', 'two words']), \
                patch.object(auth.sys, 'platform', 'darwin'), patch.object(auth.os, 'getuid', return_value=501), \
                patch.object(auth.pwd, 'getpwuid', return_value=SimpleNamespace(pw_dir=str(self.directory), pw_name='archfill')), \
                patch.object(auth, 'find_op', return_value='/fake/op'), \
                patch.object(auth, 'read_token', return_value=FAKE_TOKEN), \
                patch.object(auth, 'run_harness') as run:
            auth.main()
        run.assert_called_once_with('/fake/op', FAKE_TOKEN, {'KEY': 'op://Agents/item/token'},
                                    ['/runtime/pi', '-p', 'two words'])

    def test_auto_mode_discovery_and_nested_auth_do_not_read_keychain(self):
        config = self.directory / '.config/agent-auth/env.refs'
        config.parent.mkdir(parents=True)
        config.write_text('KEY=op://Agents/item/token\n')
        for tail, active in ((['--version'], ''), (['--help'], ''), (['-p', 'two words'], '1')):
            with patch.dict(os.environ, {'AGENT_AUTH_ACTIVE': active}, clear=True), \
                    patch.object(auth.sys, 'argv', ['agent-auth', 'auto', '--', '/runtime/pi', *tail]), \
                    patch.object(auth.sys, 'platform', 'darwin'), patch.object(auth.os, 'getuid', return_value=501), \
                    patch.object(auth.pwd, 'getpwuid', return_value=SimpleNamespace(pw_dir=str(self.directory), pw_name='archfill')), \
                    patch.object(auth, 'find_op') as op, patch.object(auth, 'read_token') as read, \
                    patch.object(auth.os, 'execvp') as execute:
                auth.main()
            execute.assert_called_once_with('/runtime/pi', ['/runtime/pi', *tail])
            read.assert_not_called()
            op.assert_not_called()

    def test_auto_mode_without_refs_preserves_native_auth(self):
        with patch.dict(os.environ, {}, clear=True), \
                patch.object(auth.sys, 'argv', ['agent-auth', 'auto', '--', '/runtime/pi', '-p', 'test']), \
                patch.object(auth.sys, 'platform', 'darwin'), patch.object(auth.os, 'getuid', return_value=501), \
                patch.object(auth.pwd, 'getpwuid', return_value=SimpleNamespace(pw_dir=str(self.directory), pw_name='archfill')), \
                patch.object(auth, 'read_token') as read, patch.object(auth.os, 'execvp') as execute:
            auth.main()
        execute.assert_called_once_with('/runtime/pi', ['/runtime/pi', '-p', 'test'])
        read.assert_not_called()

    def test_auto_mode_invalid_refs_does_not_fall_back_to_native_auth(self):
        config = self.directory / '.config/agent-auth/env.refs'
        config.parent.mkdir(parents=True)
        config.write_text('KEY=plaintext\n')
        with patch.dict(os.environ, {}, clear=True), \
                patch.object(auth.sys, 'argv', ['agent-auth', 'auto', '--', '/runtime/pi']), \
                patch.object(auth.sys, 'platform', 'darwin'), patch.object(auth.os, 'getuid', return_value=501), \
                patch.object(auth.pwd, 'getpwuid', return_value=SimpleNamespace(pw_dir=str(self.directory), pw_name='archfill')), \
                patch.object(auth, 'read_token') as read, patch.object(auth.os, 'execvp') as execute, \
                self.assertRaises(ValueError):
            auth.main()
        read.assert_not_called()
        execute.assert_not_called()

    def test_op_uses_homebrew_path_not_project_path(self):
        import stat
        mode = SimpleNamespace(st_mode=stat.S_IFREG | 0o755)
        with patch.dict(os.environ, {"PATH": "/untrusted/project/bin"}), \
                patch.object(Path, "stat", return_value=mode):
            self.assertEqual(auth.find_op(), "/opt/homebrew/bin/op")
        with patch.object(Path, "stat", side_effect=FileNotFoundError()), self.assertRaises(ValueError):
            auth.find_op()

    def test_literal_references_are_parsed_without_shell_evaluation(self):
        self.refs.write_text("# comment\nGITHUB_PAT=op://Agents/GitHub MCP/token\nYUI_MCP_TOKEN=op://Agents/YUI/token\n")
        self.assertEqual(auth.load_refs(self.refs), {
            "GITHUB_PAT": "op://Agents/GitHub MCP/token",
            "YUI_MCP_TOKEN": "op://Agents/YUI/token",
        })

    def test_invalid_reserved_plaintext_or_empty_refs_rejected(self):
        for text in ("", "# comments only", "KEY=plaintext", "missing-assignment",
                     "BAD-NAME=op://a/b/c", "KEY=op://a/b", "KEY=op://a//c", "KEY=op://a/b/",
                     "KEY=op://$VAULT/b/c", "KEY=op://a/b/c\x00x",
                     "KEY='op://a/b/c'", "OP_SERVICE_ACCOUNT_TOKEN=op://a/b/c",
                     "OP_CONNECT_TOKEN=op://a/b/c", "PATH=op://a/b/c", "HOME=op://a/b/c",
                     "BASH_ENV=op://a/b/c", "AGENT_AUTH_ACTIVE=op://a/b/c", "PYTHONPATH=op://a/b/c", "DYLD_INSERT_LIBRARIES=op://a/b/c",
                     "KEY=op://a/b/c\nKEY=op://a/b/d"):
            with self.subTest(text=text):
                self.refs.write_text(text)
                with self.assertRaises(ValueError):
                    auth.load_refs(self.refs)

    def test_missing_refs_error_is_static(self):
        with self.assertRaisesRegex(ValueError, "Cannot read env.refs"):
            auth.load_refs(self.refs)

    def test_invalid_utf8_or_pipe_is_rejected_without_reading_secrets(self):
        self.refs.write_bytes(b"\xff")
        with self.assertRaisesRegex(ValueError, "Cannot read env.refs"):
            auth.load_refs(self.refs)
        import stat
        mode = SimpleNamespace(st_mode=stat.S_IFIFO | 0o600)
        with patch.object(Path, "stat", return_value=mode), \
                patch.object(Path, "read_text") as read, self.assertRaisesRegex(ValueError, "regular"):
            auth.load_refs(self.refs)
        read.assert_not_called()

    def test_keychain_read_uses_fixed_service_current_account_and_timeout(self):
        response = SimpleNamespace(returncode=0, stdout=FAKE_TOKEN + "\n", stderr="")
        with patch.object(auth.subprocess, "run", return_value=response) as run:
            token = auth.read_token(self.directory, "archfill")
        self.assertEqual(token, FAKE_TOKEN)
        run.assert_called_once_with([
            "/usr/bin/security", "find-generic-password", "-a", "archfill",
            "-s", auth.SERVICE, "-w", str(self.directory / "Library/Keychains/login.keychain-db"),
        ], capture_output=True, text=True, timeout=30, check=False)

    def test_keychain_failure_never_discloses_raw_output(self):
        response = SimpleNamespace(returncode=44, stdout=FAKE_TOKEN, stderr=FAKE_TOKEN)
        with patch.object(auth.subprocess, "run", return_value=response):
            with self.assertRaises(ValueError) as error:
                auth.read_token(self.directory, "archfill")
        self.assertNotIn(FAKE_TOKEN, str(error.exception))

    def test_empty_invalid_or_timed_out_keychain_is_rejected(self):
        for token in ("", "a b", "a\nb"):
            response = SimpleNamespace(returncode=0, stdout=token, stderr="")
            with patch.object(auth.subprocess, "run", return_value=response), self.assertRaises(ValueError):
                auth.read_token(self.directory, "archfill")
        with patch.object(auth.subprocess, "run", side_effect=subprocess.TimeoutExpired("security", 30)):
            with self.assertRaises(ValueError):
                auth.read_token(self.directory, "archfill")

    def test_op_environment_does_not_modify_parent_or_use_other_auth(self):
        parent = {
            "PATH": "/usr/bin:/bin", "KEEP": "value", "OP_CONNECT_TOKEN": "old",
            "OP_CONNECT_HOST": "host", "OP_SESSION": "old-session", "OP_SESSION_personal": "old",
            "OP_SERVICE_ACCOUNT_TOKEN": "old-token", "OTHER_REF": "op://Personal/other/token",
        }
        with patch.dict(os.environ, parent, clear=True):
            result = auth.op_environment(FAKE_TOKEN, {"GITHUB_PAT": "op://Agents/GitHub/token"})
            self.assertEqual(dict(os.environ), parent)
        self.assertEqual(result, {
            "PATH": "/usr/bin:/bin", "KEEP": "value", "OP_SERVICE_ACCOUNT_TOKEN": FAKE_TOKEN,
            "GITHUB_PAT": "op://Agents/GitHub/token",
        })

    def run_harness_with(self, reads, refs=None, which="/usr/bin/pi", parent=None):
        refs = refs or {"KEY": "op://Agents/item/token", "OTHER": "op://Agents/other/key"}
        parent = parent or {"PATH": "/usr/bin", "KEEP": "v", "OP_CONNECT_TOKEN": "old",
                            "OP_SERVICE_ACCOUNT_TOKEN": "old-token", "AMBIENT": "op://Personal/x/y"}
        with patch.dict(os.environ, parent, clear=True), \
                patch.object(auth.subprocess, "run", side_effect=reads) as run, \
                patch.object(auth.shutil, "which", return_value=which), \
                patch.object(auth.os, "execve") as execute:
            try:
                auth.run_harness("/opt/homebrew/bin/op", FAKE_TOKEN, refs, ["pi", "--help"])
            finally:
                self.reads, self.execute = run, execute

    def test_run_reads_each_ref_and_execs_without_service_token(self):
        reads = [SimpleNamespace(returncode=0, stdout="resolved-1", stderr=""),
                 SimpleNamespace(returncode=0, stdout="resolved-2", stderr="")]
        self.run_harness_with(reads)
        calls = self.reads.call_args_list
        self.assertEqual([c.args[0] for c in calls], [
            ["/opt/homebrew/bin/op", "read", "--no-newline", "op://Agents/item/token"],
            ["/opt/homebrew/bin/op", "read", "--no-newline", "op://Agents/other/key"],
        ])
        for call in calls:
            self.assertEqual(call.kwargs["env"][auth.TOKEN_VAR], FAKE_TOKEN)
            self.assertNotIn("OP_CONNECT_TOKEN", call.kwargs["env"])
            self.assertEqual(call.kwargs["timeout"], 60)
            self.assertTrue(call.kwargs["capture_output"])
        program, args, env = self.execute.call_args.args
        self.assertEqual(program, "/usr/bin/pi")
        self.assertEqual(args, ["pi", "--help"])
        self.assertEqual((env["KEY"], env["OTHER"]), ("resolved-1", "resolved-2"))
        self.assertEqual(env["KEEP"], "v")
        self.assertNotIn(auth.TOKEN_VAR, env)
        self.assertFalse(any(name.startswith("OP_") for name in env))
        self.assertNotIn("AMBIENT", env)
        self.assertEqual(env["AGENT_AUTH_ACTIVE"], "1")
        self.assertNotIn(FAKE_TOKEN, args)

    def test_run_failed_read_never_execs_and_hides_values(self):
        failures = (
            [SimpleNamespace(returncode=0, stdout="resolved-1", stderr=""),
             SimpleNamespace(returncode=1, stdout=FAKE_TOKEN, stderr=FAKE_TOKEN)],
            [SimpleNamespace(returncode=0, stdout="resolved-1", stderr=""), subprocess.TimeoutExpired("op", 60)],
            [SimpleNamespace(returncode=0, stdout="", stderr="")],
        )
        for reads in failures:
            with self.subTest(reads=reads):
                with self.assertRaises(ValueError) as error:
                    self.run_harness_with(reads)
                self.execute.assert_not_called()
                for secret in (FAKE_TOKEN, "resolved-1"):
                    self.assertNotIn(secret, str(error.exception))

    def test_run_missing_command_never_execs(self):
        reads = [SimpleNamespace(returncode=0, stdout="a", stderr=""),
                 SimpleNamespace(returncode=0, stdout="b", stderr="")]
        with self.assertRaises(ValueError):
            self.run_harness_with(reads, which=None)
        self.execute.assert_not_called()

    def test_check_suppresses_raw_success_and_failure_output(self):
        for code in (0, 1):
            response = SimpleNamespace(returncode=code, stdout=FAKE_TOKEN, stderr=FAKE_TOKEN)
            output = io.StringIO()
            with patch.object(auth.subprocess, "run", return_value=response), redirect_stdout(output):
                if code:
                    with self.assertRaises(ValueError) as error:
                        auth.check_auth("/fake/op", FAKE_TOKEN)
                    self.assertNotIn(FAKE_TOKEN, str(error.exception))
                else:
                    auth.check_auth("/fake/op", FAKE_TOKEN)
            self.assertNotIn(FAKE_TOKEN, output.getvalue())

    def test_check_timeout_is_static(self):
        with patch.object(auth.subprocess, "run", side_effect=subprocess.TimeoutExpired("op", 30)):
            with self.assertRaisesRegex(ValueError, "could not complete"):
                auth.check_auth("/fake/op", FAKE_TOKEN)

    def test_missing_command_or_invalid_refs_never_reads_keychain(self):
        self.refs.write_text("TOKEN=plaintext")
        for args in (["run"], ["run", "--env-file", str(self.refs), "--", "pi"]):
            with patch.object(auth.sys, "argv", ["agent-auth", *args]), \
                    patch.object(auth.sys, "platform", "darwin"), \
                    patch.object(auth.os, "getuid", return_value=501), \
                    patch.object(auth.pwd, "getpwuid", return_value=SimpleNamespace(pw_dir=str(self.directory), pw_name="archfill")), \
                    patch.object(auth, "find_op", return_value="/fake/op"), \
                    patch.object(auth, "read_token") as read, self.assertRaises(ValueError):
                auth.main()
            read.assert_not_called()

    def test_keychain_failure_never_starts_harness(self):
        self.refs.write_text("KEY=op://Agents/item/token")
        with patch.object(auth.sys, "argv", ["agent-auth", "run", "--env-file", str(self.refs), "--", "pi"]), \
                patch.object(auth.sys, "platform", "darwin"), \
                patch.object(auth.os, "getuid", return_value=501), \
                patch.object(auth.pwd, "getpwuid", return_value=SimpleNamespace(pw_dir=str(self.directory), pw_name="archfill")), \
                patch.object(auth, "find_op", return_value="/fake/op"), \
                patch.object(auth, "read_token", side_effect=ValueError("locked")), \
                patch.object(auth, "run_harness") as run, self.assertRaises(ValueError):
            auth.main()
        run.assert_not_called()

    def test_root_and_non_macos_are_rejected_before_keychain(self):
        for platform, uid in (("darwin", 0), ("linux", 501)):
            with patch.object(auth.sys, "argv", ["agent-auth", "check"]), \
                    patch.object(auth.sys, "platform", platform), \
                    patch.object(auth.os, "getuid", return_value=uid), \
                    patch.object(auth, "read_token") as read, self.assertRaises(ValueError):
                auth.main()
            read.assert_not_called()

    def test_process_boundary_injects_secret_but_not_service_token(self):
        fake_op = self.directory / "op"
        fake_op.write_text(f"""#!{sys.executable}
import os, sys
assert sys.argv[1:] == ['read', '--no-newline', 'op://Agents/item/token']
assert os.environ['OP_SERVICE_ACCOUNT_TOKEN'] == {FAKE_TOKEN!r}
assert 'OP_CONNECT_TOKEN' not in os.environ
assert 'UNRELATED_REF' not in os.environ
if os.environ.get('FAKE_FAIL'):
    sys.exit(7)
sys.stdout.write('synthetic-resolved-secret')
""")
        fake_op.chmod(0o755)
        output = self.directory / "started"
        harness = self.directory / "harness.py"
        harness.write_text("""import os, pathlib, sys
assert 'OP_SERVICE_ACCOUNT_TOKEN' not in os.environ
assert os.environ['AGENT_AUTH_ACTIVE'] == '1'
assert 'OP_CONNECT_TOKEN' not in os.environ
assert 'UNRELATED_REF' not in os.environ
assert os.environ['HARNESS_SECRET'] == 'synthetic-resolved-secret'
pathlib.Path(sys.argv[1]).write_text('started')
sys.exit(9)
""")
        launcher = self.directory / "launcher.py"
        launcher.write_text(f"""import importlib.util, sys
spec = importlib.util.spec_from_file_location('auth', {str(SCRIPT)!r})
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
try:
    module.run_harness({str(fake_op)!r}, {FAKE_TOKEN!r},
        {{'HARNESS_SECRET': 'op://Agents/item/token'}},
        [sys.executable, {str(harness)!r}, {str(output)!r}])
except ValueError as error:
    print(f'agent-auth: {{error}}', file=sys.stderr)
    sys.exit(1)
""")
        env = dict(os.environ, OP_CONNECT_TOKEN="old-connect", UNRELATED_REF="op://Personal/unrelated/token")
        env.pop("FAKE_FAIL", None)
        result = subprocess.run([sys.executable, str(launcher)], env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 9, result.stderr)
        self.assertTrue(output.exists())
        self.assertNotIn(FAKE_TOKEN, result.stdout + result.stderr)
        output.unlink()
        result = subprocess.run([sys.executable, str(launcher)], env=dict(env, FAKE_FAIL="1"), capture_output=True, text=True)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Could not read the secret for HARNESS_SECRET", result.stderr)
        self.assertNotIn(FAKE_TOKEN, result.stdout + result.stderr)
        self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
