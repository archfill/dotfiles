#!/usr/bin/env python3
"""Supply 1Password secrets to a harness without sharing its service account token."""

import argparse
import os
from pathlib import Path
import pwd
import re
import stat
import subprocess
import sys


SERVICE = "com.archfill.agent-auth.service-account"
TOKEN_VAR = "OP_SERVICE_ACCOUNT_TOKEN"
RESERVED = {
    "PATH", "HOME", "SHELL", "ENV", "BASH_ENV", "ZDOTDIR",
    "PYTHONPATH", "PYTHONHOME", "__PYVENV_LAUNCHER__",
}


def find_op():
    # A project-modified PATH must not select the program receiving the token.
    for value in ("/opt/homebrew/bin/op", "/usr/local/bin/op"):
        path = Path(value)
        try:
            mode = path.stat().st_mode
        except FileNotFoundError:
            continue
        except OSError as error:
            raise ValueError("Cannot inspect the Homebrew 1Password CLI installation") from error
        if stat.S_ISREG(mode) and mode & 0o111:
            return value
    raise ValueError("1Password CLI (op) is missing from the Homebrew installation")


def read_token(home, account):
    """Read only the specified login Keychain item; never print its output."""
    try:
        result = subprocess.run([
            "/usr/bin/security", "find-generic-password",
            "-a", account, "-s", SERVICE, "-w",
            str(home / "Library/Keychains/login.keychain-db"),
        ], capture_output=True, text=True, timeout=30, check=False)
    except (OSError, subprocess.TimeoutExpired) as error:
        raise ValueError("Cannot access login Keychain; unlock it and check item permissions") from error
    if result.returncode != 0:
        raise ValueError("Service account item unavailable; check login Keychain and access permissions")
    token = result.stdout.strip()
    if not token or any(char.isspace() for char in token):
        raise ValueError("Keychain item contains an empty or invalid service account token")
    return token


def load_refs(path):
    """Only literal op:// references are permitted, never plaintext credentials."""
    try:
        if not stat.S_ISREG(path.stat().st_mode):
            raise ValueError("env.refs must be a regular reference file, not a mounted pipe")
        content = path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise ValueError("Cannot read env.refs; configure a UTF-8 reference file for the service account vault") from error
    refs = {}
    for number, line in enumerate(content.splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise ValueError(f"Invalid reference assignment at line {number}")
        name, value = (part.strip() for part in line.split("=", 1))
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            raise ValueError(f"Invalid variable name at line {number}")
        if name in RESERVED or name.startswith(("OP_", "LD_", "DYLD_")):
            raise ValueError(f"Reserved variable at line {number}")
        if name in refs:
            raise ValueError(f"Duplicate variable at line {number}")
        parts = value[5:].split("/")
        if not value.startswith("op://") or len(parts) < 3 or not all(parts):
            raise ValueError(f"Expected a literal op://vault/item/field reference at line {number}")
        if any(part in value for part in ("$", "\"", "'")) or any(ord(char) < 32 for char in value):
            raise ValueError(f"Reference interpolation or quoting is not supported at line {number}")
        refs[name] = value
    if not refs:
        raise ValueError("No secret references configured in env.refs")
    return refs


def op_environment(token, refs):
    # Don't let Connect, desktop sessions or unrelated ambient references override
    # this scoped service account. Preserve ordinary inherited environment values.
    env = {
        name: value for name, value in os.environ.items()
        if not name.startswith("OP_") and not value.startswith("op://")
    }
    env.update(refs)
    env[TOKEN_VAR] = token
    return env


def check_auth(op, token):
    try:
        result = subprocess.run(
            [op, "whoami"], env=op_environment(token, {}),
            capture_output=True, text=True, timeout=30, check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        raise ValueError("Service account authentication check could not complete") from error
    if result.returncode != 0:
        # Raw CLI stderr / stdout may contain sensitive context. Don't echo it.
        raise ValueError("Service account authentication failed; check token, network and permissions")
    print("1Password service account authentication is ready")


def run_harness(op, token, refs, command):
    # op resolves references and retains its normal output masking. env removes
    # the bootstrap token before the harness (and its descendants) starts.
    args = [op, "run", "--", "/usr/bin/env", "-u", TOKEN_VAR, *command]
    os.execve(op, args, op_environment(token, refs))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    sub.add_parser("check", help="Check Keychain and service account authentication without showing secrets")
    launch = sub.add_parser("run", help="Inject configured secrets and start a harness")
    launch.add_argument("--env-file", type=Path, help="Reference-only env file (default: ~/.config/agent-auth/env.refs)")
    launch.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if sys.platform != "darwin" or os.getuid() == 0:
        raise ValueError("Run as the existing macOS user, without sudo")
    op = find_op()
    user = pwd.getpwuid(os.getuid())
    home = Path(user.pw_dir)
    refs = {}
    command = []
    if args.action == "run":
        command = args.command
        if command and command[0] == "--":
            command = command[1:]
        if not command:
            raise ValueError("Specify a harness command after run --")
        refs = load_refs(args.env_file or home / ".config/agent-auth/env.refs")
    token = read_token(home, user.pw_name)
    if args.action == "check":
        check_auth(op, token)
    else:
        run_harness(op, token, refs, command)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as error:
        print(f"agent-auth: {error}", file=sys.stderr)
        sys.exit(1)
