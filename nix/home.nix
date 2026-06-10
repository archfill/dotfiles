{ pkgs, inputs, ... }:

let
  # ─── Neovim バージョン切替フラグ ────────────────────────────────
  # true  → neovim-nightly-overlay の nightly ビルド
  # false → nixpkgs unstable の stable 版
  useNeovimNightly = false;

  neovimNightly =
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

  neovimPackage =
    if useNeovimNightly
    then neovimNightly
    else pkgs.neovim;
in
{
  home.username = "chill-rf";
  home.homeDirectory = "/Users/chill-rf";

  # 初回 install 時点の home-manager リリース版。以降は変更しない。
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # ── home-manager 管理パッケージ ───────────────────────────────
  # 既存 dotfiles の設定ファイルとは独立してバイナリのみを Nix で提供する
  # ツール群。programs.<name> モジュールを使うと init.* が自動生成されて
  # 既存 .config/ と競合する場合があるため、当面は home.packages 直入れに
  # 寄せて運用する。
  home.packages = with pkgs; [
    # Editor
    neovimPackage    # programs.neovim を使わず wrapped neovim を直接提供

    # Search / files
    ripgrep
    fd
    bat
    eza              # ls 代替 (Rust)

    # Data
    jq
    yq-go            # Go 版 yq (brew 'yq' と挙動互換)

    # Git
    lazygit
    delta            # git-delta

    # GitHub
    gh               # GitHub CLI

    # Formatter / Linter (system 配置で nvim Mason と分離)
    stylua           # Lua formatter

    # Repo / misc
    ghq
    fastfetch
    yazi

    # System monitor
    bottom           # top/htop モダン版 (Rust)。コマンド名は btm

    # Network
    wget

    # Shells / runtime
    bash             # dotfiles スクリプトが bash 4+ (mapfile / declare -g) を要求

    # Prompt
    starship         # 設定は ~/.config/starship.toml をそのまま使用

    # Fuzzy finder
    fzf              # ~/.fzf.zsh から share/fzf/ の completion/key-bindings を source

    # Terminal multiplexer
    tmux             # 設定は ~/.config/tmux/ (tpm + conf 分割) をそのまま使用

    # zsh plugin manager
    sheldon          # plugins.toml は ~/.config/sheldon/ をそのまま使用

    # Polyglot version manager / task runner
    # proto + moon を捨てて mise に統合。
    # グローバル設定は ~/.config/mise/config.toml をそのまま使用、
    # 各プロジェクトの mise.toml と組み合わせて運用する。
    mise

    # Deno runtime
    # nvim の denops.vim + vim-skk/skkeleton (SKK 日本語入力) で必須。
    # `deno` バイナリが PATH にあれば denops が動く。
    # ~/.deno/ の DENO_INSTALL 等は使わないので dotfiles 側にも設定なし。
    deno

    # Bun runtime
    # claude-mem の Stop hook (`$SHELL -lc`) など non-interactive な
    # login shell で bun を解決する必要があるため、mise ではなく Nix で
    # グローバル提供する。プロジェクト固有のバージョン (例: yui の
    # mise.toml の bun = "1.3.x") は mise が override する設計。
    bun

    # ─── Language runtimes (グローバル固定、Nix で管理) ─────────────
    # 方針:
    #   - グローバルバージョンは Nix で再現性最強の固定
    #   - プロジェクト毎の override は各リポジトリの mise.toml で
    #     (yui は java 17 / node 22 / python 3.13 等を local 固定)
    #   - mise はバージョンマネージャとして「プロジェクト override」
    #     用途に特化、グローバル管理から退場
    openjdk17    # Java 17 LTS (Flutter Android ビルド、yui バックエンド等)
    nodejs_22    # Node.js 22 LTS
    python313    # Python 3.13
    go           # Go (最新版、go.mod がプロジェクト毎の互換性を担う)

    # ─── Rust toolchain ──────────────────────────────────────────────
    # 案 A (pkgs.cargo + pkgs.rustc) を採用。rustup を捨てて Nix で
    # stable を 1 本提供する。rustup の ~/.rustup (1.2GB) を解放し、
    # ~/.cargo/bin の rustup-managed バイナリも削除する。
    # 注意: rustup target add / component add は使えなくなる。aarch64-
    # darwin だけで運用しているため影響なし。複数 toolchain や別 target
    # が必要になった場合は rust-overlay / fenix を後日検討する。
    cargo
    rustc
    rustfmt      # nixpkgs では rustc に同梱されないため別途追加
    clippy       # 同上

    # ─── Build / task runners ────────────────────────────────────────
    just         # Makefile より読みやすいコマンドランナー (Rust 製)

    # ─── Package managers (language-specific) ────────────────────────
    uv           # Python 高速パッケージマネージャ (mise.toml の uv 指定は
                 # プロジェクト毎の固定として引き続き機能する)
    pnpm         # Node.js パッケージマネージャ (nodejs_22 と組合せて運用)

    # ─── Database clients ────────────────────────────────────────────
    # AI agent (Claude Code / Codex) からのワンライナー DB 操作で
    # 使うため。サーバ機能は使わずクライアントツール一式
    # (psql / pg_dump / pg_restore / mysql / mysqldump 等) のみ活用。
    # 実プロジェクトの DB は yui / claude-mem 等すべて docker compose
    # で起動するため、ホスト側にサーバ本体は不要。
    # brew の postgresql@18 と libpq、mysql-client を全て退場させ、
    # Nix で統一する設計。
    postgresql_18   # psql / pg_dump / pg_restore / pg_basebackup 等
    mysql84         # mysql / mysqldump / mysqladmin / mysqlbinlog 等
                    # (mysql80 は 2026-04-30 で EOL、8.4 LTS に統一)

    # ─── Infra / configuration management ───────────────────────────
    ansible         # ~/git/infra-configs/proxmox/ansible で Proxmox
                    # 周辺ホスト (pve / pve-docker / pve-forgejo /
                    # pve-traefik) を管理。brew 版 (~517MB) から Nix へ。
    tenv            # Terraform / OpenTofu / Terragrunt のバージョン
                    # マネージャ。各プロジェクトの .terraform-version で
                    # 個別固定して運用。dotfiles の .config/zsh/zshrc/
                    # tools.zsh で TENV_AUTO_INSTALL=true / TENV_VALIDATION
                    # =signature を設定済み。

    # ─── Cloud SDK / CLI ─────────────────────────────────────────────
    awscli2         # AWS CLI v2。業務インフラ (v2g-poc-infra 等) で
                    # 利用。SSO / SSO+role / 通常 access key 全て対応。
  ];

  # JAVA_HOME を Nix の openjdk17 に向ける。
  # dotfiles の sdk.zsh は mise where java から JAVA_HOME を取る実装
  # だが、本セッション変数が先に設定されるため Nix 経由で常に解決される。
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.openjdk17}";
  };
}
