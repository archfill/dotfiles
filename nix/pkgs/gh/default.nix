{ lib
, bash
, coreutils
, gh
, gnused
, runCommand
, symlinkJoin
, writeShellScript
}:

let
  normalizeScript = builtins.readFile ./normalize-gitconfig.sh;

  wrapper = writeShellScript "gh-nix-credential-helper-wrapper" ''
    # Keep the fixup independent of the caller's PATH (Git may invoke helpers
    # from a reduced environment).
    PATH="${lib.makeBinPath [ coreutils gnused ]}:$PATH"
    real="${lib.getExe gh}"

    case "$1:$2" in
      auth:login | auth:setup-git)
        ;;
      *)
        exec "$real" "$@"
        ;;
    esac

    "$real" "$@"
    status=$?

    if [ "$status" -eq 0 ]; then
      ${normalizeScript}
      normalize_gh_gitconfig "$HOME/.gitconfig"
      normalize_gh_gitconfig "$HOME/.config/git/config"
      if [ -n "$XDG_CONFIG_HOME" ]; then
        normalize_gh_gitconfig "$XDG_CONFIG_HOME/git/config"
      fi
    fi

    exit "$status"
  '';

  credentialHelperTest = runCommand "gh-credential-helper-test" {
    nativeBuildInputs = [ bash coreutils gnused ];
  } ''
    config="$TMPDIR/gitconfig"
    cat > "$config" <<'EOF'
[credential "https://github.com"]
    helper =
    helper = !/nix/store/test-gh-2.98.0/bin/.gh-wrapped auth git-credential
[credential "https://gist.github.com"]
    helper =
    helper = !/nix/store/test-gh-2.98.0/bin/gh auth git-credential
[credential "https://example.com"]
    helper = !/nix/store/test-other/bin/other auth git-credential
EOF

    cat > "$TMPDIR/test-normalize.sh" <<'SCRIPT'
${normalizeScript}
normalize_gh_gitconfig "$1"
normalize_gh_gitconfig "$1"
SCRIPT
    ${bash}/bin/bash "$TMPDIR/test-normalize.sh" "$config"

    test "$(grep -Fc 'helper = !gh auth git-credential' "$config")" -eq 2
    ! grep -Fq '/nix/store/test-gh-2.98.0' "$config"
    grep -Fq 'helper = !/nix/store/test-other/bin/other auth git-credential' "$config"
    touch "$out"
  '';
in

symlinkJoin {
  name = "gh-with-nix-credential-helper-${gh.version}";
  paths = [ gh ];

  postBuild = ''
    rm -f "$out/bin/gh"
    install -Dm755 ${wrapper} "$out/bin/gh"
  '';

  passthru.tests.credential-helper = credentialHelperTest;

  meta = gh.meta // {
    description = "GitHub CLI with Nix-safe Git credential helper normalization";
    mainProgram = "gh";
  };
}
