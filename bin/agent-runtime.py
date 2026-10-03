#!/usr/bin/env python3
"""既存ユーザーによる CLI の手動配備。sudo / darwin switch は実行しない。"""

import argparse
import fcntl
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import tempfile


DIRECTORY = Path("/opt/agent-runtime")
FLAKE = Path(__file__).resolve().parent.parent / "nix"
COMMANDS = ("claude", "codex", "pi", "devin")
STORE_PATH = re.compile(r"/nix/store/[a-z0-9]{32}-agent-runtime")


def run(args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def check_directory(directory):
    """所有者、symlink、他ユーザーの書き込み権限を確認する。"""
    uid = os.getuid()
    for path in (directory, *directory.parents):
        info = path.lstat()
        if not stat.S_ISDIR(info.st_mode):
            raise ValueError(f"Directory must not be a symlink: {path}")
        if info.st_uid not in (0, uid) or info.st_mode & 0o022:
            raise ValueError(f"Unsafe owner or writable permissions: {path}")
    if directory.stat().st_uid != uid:
        raise ValueError("Runtime directory must be owned by the current user")


def check_store_path(value):
    if not STORE_PATH.fullmatch(value):
        raise ValueError("Expected an exact /nix/store/<hash>-agent-runtime path")
    path = Path(value)
    if not path.is_dir() or path.is_symlink():
        raise ValueError(f"Missing or invalid runtime: {value}")
    return path


def smoke(path):
    # 既存ユーザーの token / CLI 設定を smoke test に渡さない。
    with tempfile.TemporaryDirectory(prefix="agent-runtime-check-") as home:
        env = {
            "HOME": home,
            "XDG_CONFIG_HOME": f"{home}/.config",
            "XDG_CACHE_HOME": f"{home}/.cache",
            "PATH": f"{path}/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "DISABLE_AUTOUPDATER": "1",
            "TERM": "dumb",
        }
        for command in COMMANDS:
            executable = path / "bin" / command
            try:
                executable_mode = executable.stat().st_mode
            except OSError as error:
                raise ValueError(f"Missing executable: {executable}") from error
            if not stat.S_ISREG(executable_mode) or not executable_mode & 0o111:
                raise ValueError(f"Not executable: {executable}")
            run([str(executable), "--version"], env=env, timeout=45)


def candidate_path(directory):
    link = directory / "candidate"
    if not link.is_symlink():
        raise ValueError("No candidate. Run prepare first")
    return check_store_path(str(link.resolve(strict=True)))


def prepare(directory):
    # pending は smoke 中も closure を GC から保護する out-link。
    # prepare 失敗時は candidate / current profile を変更しない。
    pending = directory / "pending"
    try:
        run([
            "nix", "build", f"path:{FLAKE}#agent-runtime",
            "--no-update-lock-file", "--out-link", str(pending),
        ])
        path = check_store_path(str(pending.resolve(strict=True)))
        smoke(path)
        run([
            "nix-store", "--realise", str(path), "--add-root",
            str(directory / "candidate"), "--indirect",
        ])
        print(f"Candidate: {path}")
        print(f"After review and stopping all agent tasks: make agent-apply STORE_PATH={path}")
    finally:
        if pending.is_symlink():
            pending.unlink()


def apply(directory, approved):
    path = check_store_path(approved)
    if path != candidate_path(directory):
        raise ValueError("Approved path differs from candidate; review the new candidate")
    smoke(path)
    run(["nix-env", "--profile", str(directory / "profile"), "--set", str(path)])
    print(f"Applied: {path}. Start fresh agent processes; running processes are not upgraded.")


def rollback(directory, generation):
    if not re.fullmatch(r"[1-9][0-9]*", generation):
        raise ValueError("Expected a positive generation number from agent-status")
    target = directory / f"profile-{generation}-link"
    if not target.is_symlink():
        raise ValueError("Generation does not exist")
    path = check_store_path(str(target.resolve(strict=True)))
    smoke(path)
    run([
        "nix-env", "--profile", str(directory / "profile"),
        "--switch-generation", generation,
    ])
    print(f"Restored generation {generation}. Restart agent processes.")


def status(directory):
    for name in ("candidate", "profile"):
        link = directory / name
        print(f"{name}: {link.resolve() if link.is_symlink() else '(not deployed)'}")
    if (directory / "profile").is_symlink():
        run(["nix-env", "--profile", str(directory / "profile"), "--list-generations"])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("prepare", "apply", "rollback", "status"))
    parser.add_argument("approval", nargs="?")
    args = parser.parse_args()
    if args.action in ("apply", "rollback") and not args.approval:
        parser.error("apply requires STORE_PATH; rollback requires GENERATION")
    if args.action in ("prepare", "status") and args.approval:
        parser.error("unexpected argument")
    if sys.platform != "darwin" or os.getuid() == 0:
        raise ValueError("Run as the macOS profile owner, without sudo")
    check_directory(DIRECTORY)
    # 全操作を排他化。失敗・タイムアウト時も close で lock を解放する。
    fd = os.open(DIRECTORY / ".lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as exc:
            raise ValueError("Another deployment is running") from exc
        if args.action == "prepare":
            prepare(DIRECTORY)
        elif args.action == "apply":
            apply(DIRECTORY, args.approval)
        elif args.action == "rollback":
            rollback(DIRECTORY, args.approval)
        else:
            status(DIRECTORY)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"agent-runtime: {error}", file=sys.stderr)
        sys.exit(1)
