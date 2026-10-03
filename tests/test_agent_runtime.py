"""配備先を変更せず、承認・失敗・権限境界を検証する。"""

import importlib.util
import os
from pathlib import Path
import stat
import subprocess
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location(
    "agent_runtime", Path(__file__).resolve().parents[1] / "bin/agent-runtime.py"
)
assert SPEC is not None and SPEC.loader is not None
runtime = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runtime)


class DeploymentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name).resolve()
        self.store = self.directory / "store"
        self.store.mkdir()
        self.profile = self.directory / "profile"
        self.profile.symlink_to(self.store)
        self.candidate = self.directory / "candidate"
        self.candidate.symlink_to(self.store)

    def test_prepare_failure_preserves_profile_and_candidate(self):
        with patch.object(runtime, "run", side_effect=subprocess.CalledProcessError(1, "nix")):
            with self.assertRaises(subprocess.CalledProcessError):
                runtime.prepare(self.directory)
        self.assertEqual(self.profile.resolve(), self.store)
        self.assertEqual(self.candidate.resolve(), self.store)

    def test_failed_smoke_never_promotes_candidate(self):
        new_store = self.directory / "new-store"
        new_store.mkdir()

        def build(args):
            (self.directory / "pending").symlink_to(new_store)

        with patch.object(runtime, "run", side_effect=build) as commands, \
                patch.object(runtime, "check_store_path", return_value=new_store), \
                patch.object(runtime, "smoke", side_effect=subprocess.TimeoutExpired("claude", 45)):
            with self.assertRaises(subprocess.TimeoutExpired):
                runtime.prepare(self.directory)
        self.assertEqual(commands.call_count, 1)
        self.assertEqual(self.candidate.resolve(), self.store)
        self.assertEqual(self.profile.resolve(), self.store)
        self.assertFalse((self.directory / "pending").is_symlink())

    def test_prepare_checks_before_promoting_and_never_switches(self):
        events = []

        def command(args):
            events.append(args)
            if args[:2] == ["nix", "build"]:
                (self.directory / "pending").symlink_to(self.store)

        with patch.object(runtime, "run", side_effect=command), \
                patch.object(runtime, "check_store_path", return_value=self.store), \
                patch.object(runtime, "smoke", side_effect=lambda path: events.append("smoke")):
            runtime.prepare(self.directory)
        self.assertEqual(events[1], "smoke")
        self.assertEqual(events[2][0], "nix-store")
        self.assertIn("--no-update-lock-file", events[0])
        self.assertFalse((self.directory / "pending").is_symlink())
        self.assertEqual(self.profile.resolve(), self.store)

    def test_apply_requires_exact_current_candidate(self):
        with patch.object(runtime, "check_store_path", side_effect=[self.store, self.directory]), \
                patch.object(runtime, "run") as commands, patch.object(runtime, "smoke") as smoke:
            with self.assertRaisesRegex(ValueError, "differs"):
                runtime.apply(self.directory, str(self.store))
        commands.assert_not_called()
        smoke.assert_not_called()

    def test_apply_smoke_failure_never_switches(self):
        with patch.object(runtime, "check_store_path", return_value=self.store), \
                patch.object(runtime, "run") as commands, \
                patch.object(runtime, "smoke", side_effect=ValueError("bad CLI")):
            with self.assertRaises(ValueError):
                runtime.apply(self.directory, str(self.store))
        commands.assert_not_called()
        self.assertEqual(self.profile.resolve(), self.store)

    def test_apply_switches_explicit_profile_only_after_smoke(self):
        events = []
        with patch.object(runtime, "check_store_path", return_value=self.store), \
                patch.object(runtime, "smoke", side_effect=lambda path: events.append("smoke")), \
                patch.object(runtime, "run", side_effect=lambda args: events.append(args)):
            runtime.apply(self.directory, str(self.store))
        self.assertEqual(events, ["smoke", [
            "nix-env", "--profile", str(self.profile), "--set", str(self.store),
        ]])

    def test_missing_or_invalid_generation_never_switches(self):
        with patch.object(runtime, "run") as commands:
            for value in ("0", "-1", "1; sudo true", "999"):
                with self.subTest(value=value), self.assertRaises(ValueError):
                    runtime.rollback(self.directory, value)
        commands.assert_not_called()

    def test_rollback_uses_reviewed_generation(self):
        (self.directory / "profile-1-link").symlink_to(self.store)
        with patch.object(runtime, "check_store_path", return_value=self.store), \
                patch.object(runtime, "smoke") as smoke, patch.object(runtime, "run") as commands:
            runtime.rollback(self.directory, "1")
        smoke.assert_called_once_with(self.store)
        commands.assert_called_once_with([
            "nix-env", "--profile", str(self.profile), "--switch-generation", "1",
        ])

    def test_store_path_rejects_arbitrary_or_missing_directory(self):
        for value in (str(self.store), "/nix/store/../tmp", "--help", "/nix/store/" + "0" * 32 + "-agent-runtime"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                runtime.check_store_path(value)

    def test_smoke_has_clean_home_no_credentials_and_timeout(self):
        (self.store / "bin").mkdir()
        for name in runtime.COMMANDS:
            executable = self.store / "bin" / name
            executable.write_text("#!/bin/sh\nexit 0\n")
            executable.chmod(0o755)
        with patch.object(runtime, "run") as commands, \
                patch.dict(os.environ, {"ANTHROPIC_API_KEY": "secret", "OPENAI_API_KEY": "secret"}):
            runtime.smoke(self.store)
        self.assertEqual(commands.call_count, 4)
        for call in commands.call_args_list:
            self.assertEqual(call.kwargs["timeout"], 45)
            self.assertNotIn("ANTHROPIC_API_KEY", call.kwargs["env"])
            self.assertNotIn("OPENAI_API_KEY", call.kwargs["env"])
            self.assertFalse(Path(call.kwargs["env"]["HOME"]).exists())


class PermissionTests(unittest.TestCase):
    def test_unsafe_ancestor_owner_or_permissions_rejected(self):
        uid = os.getuid()
        directory = Path("/opt/agent-runtime")
        safe = SimpleNamespace(st_mode=stat.S_IFDIR | 0o755, st_uid=uid)
        for mode, owner in ((0o775, uid), (0o777, uid), (0o755, uid + 10000), (0o755, 0)):
            info = SimpleNamespace(st_mode=stat.S_IFDIR | mode, st_uid=owner)
            with self.subTest(mode=mode, owner=owner), \
                    patch.object(Path, "lstat", return_value=info), \
                    patch.object(Path, "stat", return_value=info):
                with self.assertRaises(ValueError):
                    runtime.check_directory(directory)
        with patch.object(Path, "lstat", return_value=safe), patch.object(Path, "stat", return_value=safe):
            runtime.check_directory(directory)

    def test_private_directory_allowed_for_same_user(self):
        info = SimpleNamespace(st_mode=stat.S_IFDIR | 0o700, st_uid=os.getuid())
        with patch.object(Path, "lstat", return_value=info), patch.object(Path, "stat", return_value=info):
            runtime.check_directory(Path("/opt/agent-runtime"))

    def test_owner_can_deploy_without_admin_membership(self):
        with patch.object(runtime.sys, "argv", ["agent-runtime.py", "prepare"]), \
                patch.object(runtime.sys, "platform", "darwin"), \
                patch.object(runtime.os, "getuid", return_value=501), \
                patch.object(runtime.os, "getgroups", return_value=[20]), \
                patch.object(runtime, "check_directory") as check, \
                tempfile.TemporaryDirectory() as directory, \
                patch.object(runtime, "DIRECTORY", Path(directory)), \
                patch.object(runtime, "prepare") as prepare:
            runtime.main()
        check.assert_called_once_with(Path(directory))
        prepare.assert_called_once_with(Path(directory))

    def test_symlink_directory_rejected(self):
        info = SimpleNamespace(st_mode=stat.S_IFLNK | 0o777, st_uid=os.getuid())
        with patch.object(Path, "lstat", return_value=info), self.assertRaises(ValueError):
            runtime.check_directory(Path("/opt/agent-runtime"))

    def test_root_cannot_deploy(self):
        with patch.object(runtime.sys, "argv", ["agent-runtime.py", "prepare"]), \
                patch.object(runtime.sys, "platform", "darwin"), \
                patch.object(runtime, "prepare") as prepare:
            with patch.object(runtime.os, "getuid", return_value=0), self.assertRaises(ValueError):
                runtime.main()
        prepare.assert_not_called()

    def test_parallel_deployment_rejected_before_prepare(self):
        with patch.object(runtime.sys, "argv", ["agent-runtime.py", "prepare"]), \
                patch.object(runtime.sys, "platform", "darwin"), \
                patch.object(runtime.os, "getuid", return_value=501), \
                patch.object(runtime, "check_directory"), \
                tempfile.TemporaryDirectory() as directory, \
                patch.object(runtime, "DIRECTORY", Path(directory)), \
                patch.object(runtime.fcntl, "flock", side_effect=BlockingIOError()), \
                patch.object(runtime, "prepare") as prepare:
            with self.assertRaisesRegex(ValueError, "Another deployment"):
                runtime.main()
        prepare.assert_not_called()


if __name__ == "__main__":
    unittest.main()
