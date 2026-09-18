{ pkgs, inputs, config, ... }:

let
  # ─── Neovim バージョン切替フラグ ────────────────────────────────
  # true  → neovim-nightly-overlay の nightly ビルド
  # false → nixpkgs unstable の stable 版
  useNeovimNightly = false;

  neovimNightly =
    inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

  neovimPackage =
    if useNeovimNightly
    then neovimNightly
    else pkgs.neovim;

  pipxPackage = pkgs.pipx.overridePythonAttrs (_: {
    doCheck = false;
  });

in
{
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
    git              # Apple Git (Xcode CLT) は十分新しいが、Nix で
                     # クロスプラットフォーム統一管理。git-lfs / git-credential
                     # も同梱
    lazygit
    delta            # git-delta
    git-filter-repo  # public repo 化前の履歴クリーニング用
    gitleaks         # secret scan

    # GitHub
    # gh auth login/setup-git が書く Nix store の絶対パスを PATH 参照へ正規化する wrapper
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.gh

    # ─── Nix 運用補助 ────────────────────────────────────────────────
    # nh (nix-helper): macOS / NixOS / standalone home-manager を統一 CLI 化。
    # `nh darwin switch` / `nh os switch` / `nh home switch` で全 OS 共通の
    # rebuild インタフェース、`nh clean all` で古い generation を整理、
    # `nh ... -u` で flake update + switch を 1 コマンド実行できる。
    nh

    # Formatter / Linter (system 配置で nvim Mason と分離)
    stylua           # Lua formatter

    # Repo / misc
    ghq
    fastfetch
    lazydocker
    yazi

    # System monitor
    bottom           # top/htop モダン版 (Rust)。コマンド名は btm

    # Network
    wget

    # Shells / runtime
    bash             # dotfiles スクリプトが bash 4+ (mapfile / declare -g) を要求

    # Fuzzy finder
    fzf              # ~/.fzf.zsh から share/fzf/ の completion/key-bindings を source

    # Terminal multiplexer
    tmux             # 設定は ~/.config/tmux/ (tpm + conf 分割) をそのまま使用

    # zsh plugin manager: sheldon は programs.sheldon モジュールで管理

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
    #     (yui は node 24 / python 3.13 等を local 固定)
    #   - mise はバージョンマネージャとして「プロジェクト override」
    #     用途に特化、グローバル管理から退場
    openjdk17    # Java 17 LTS (Flutter Android ビルド、yui バックエンド等)

    # Android
    android-cli   # Google 公式 Android CLI (`android`)
    nodejs_22    # Node.js 22 LTS (mise project toolのfallback)
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
    gcc          # Rust crates のリンク時に必要な cc を提供
    gnumake      # GNU Make 4.x (macOS /usr/bin/make は GPL ライセンス
                 # 問題で 3.81 から更新されない。.RECIPEPREFIX / $(file) 等
                 # 4.x 機能を使う Makefile のため必須)
    just         # Makefile より読みやすいコマンドランナー (Rust 製)

    # ─── Package managers (language-specific) ────────────────────────
    uv           # Python 高速パッケージマネージャ (mise.toml の uv 指定は
                 # プロジェクト毎の固定として引き続き機能する)
    pipxPackage  # Python CLI apps を分離 venv で導入する補助ツール
    pnpm         # Node.js パッケージマネージャ (mise project toolのfallback)

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
    stripe-cli      # Stripe CLI (~/.config/stripe/config.toml で設定
                    # 済み、業務で利用)
    firebase-tools  # Firebase CLI。Hosting / Functions / Firestore 等を管理。

    # ─── Mobile / Flutter ────────────────────────────────────────────
    fvm             # Flutter Version Management (Dart 製)。プロジェクト
                    # ごとの Flutter SDK バージョン固定に利用。brew tap
                    # (leoafarias/fvm) から Nix へ移管。

    # ─── AI coding agents ────────────────────────────────────────────
    # Google Antigravity CLI。nixpkgs の固定済み prebuilt binary を利用し、
    # `agy` コマンドを提供する。認証情報は初回起動時に設定する。
    antigravity-cli

    # OpenAI 公式 Codex CLI。nixpkgs の codex は Rust ソースビルド (依存が
    # 重く libwebrtc/librusty_v8 を抱える) で更新 PR のラグが常態化するため、
    # 自前 packages.codex (GitHub release の prebuilt native binary) で最新を
    # 追従。バージョン更新は `make nix-update` または `make codex-update`。
    # npm install -g は /nix/store の immutable と衝突するため不採用。
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.codex

    # Cursor Ultra の利用枠をターミナルから使う公式 Cursor Agent CLI。
    # 公式 installer と同じ bundle を Nix に固定し、`agent` と
    # `cursor-agent` の両コマンドを提供する。更新は
    # `make cursor-agent-update` または `make nix-update` で行う。
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.cursor-agent

    # Cursor Origin (Cursor の git forge) 用 CLI。repo / PR / ruleset 等の
    # hosting 操作を担い、AI agent である cursor-agent とは別物。公式
    # installer と同じ bundle を Nix に固定し、自己更新 (`origin update`)
    # ではなく `make origin-update` で追従する。
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.origin

    # Pi coding agent harness (earendil-works)。GitHub release の Bun
    # prebuilt を固定。npm -g は不採用。更新は `make pi-update`。
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.pi

    # Cognition 公式 Devin CLI。static.devin.ai の versioned prebuilt
    # native binary を固定し、`devin` コマンドを提供。バックグラウンド
    # 自己更新は ~/.config/devin/config.json の auto_update: false で
    # 無効化 (Nix がバージョンを所有)。更新は `make devin-update` または
    # `make nix-update` で行う。
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.devin

    # ─── Fonts ───────────────────────────────────────────────────────
    # メインは Moralerspace Argon (GitHub Monaspace + IBM Plex Sans JP)
    # で日本語環境に Monaspace 由来の Texture Healing と 3 軸 Variable
    # Font を持ち込む構成。yuru7 ファミリーフォントは全部 nixpkgs 提供
    # 済みなので brew cask の font-* は完全に退場できる。
    moralerspace              # メイン (Ghostty / WezTerm / Neovim)
    hackgen-font              # 移行期 fallback / 旧資産との互換
    nerd-fonts.jetbrains-mono # ASCII fallback / 他エディタ
    nerd-fonts.symbols-only   # Powerline / Nerd Font アイコン専用
    material-symbols          # Material icon glyphs used by the desktop shell
    nerd-fonts.caskaydia-cove # Terminal and desktop-shell monospace font
  ];

  # Nix で配置するフォントを ~/Library/Fonts にも認識させる
  # (macOS の場合、~/.nix-profile/share/fonts を `fc-cache` できれば
  # 不要だが、Ghostty 等は OS フォント登録経由で読むため、home-manager
  # の fonts.fontconfig を有効化する)
  fonts.fontconfig.enable = true;

  # JAVA_HOME を Nix の openjdk17 に向ける。
  # dotfiles の sdk.zsh は mise where java から JAVA_HOME を取る実装
  # だが、本セッション変数が先に設定されるため Nix 経由で常に解決される。
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.openjdk17}";
    OP_BIOMETRIC_UNLOCK_ENABLED = "true";
  };

  # ─── 設定ファイルの配置 (Impure / out-of-store symlink) ───────────
  # 大きな宣言的設定 (Neovim Lua / terminal emulator configs 等) は
  # programs.<name>.settings で Nix attrset に変換せず、元の TOML を維持
  # したまま mkOutOfStoreSymlink で配置だけ home-manager 管理に寄せる。
  # 利点: 公式 docs からのコピペが効く / 編集が即反映 (rebuild 不要) /
  #       Linux など home-manager 非使用環境とも同じファイルを共有できる。
  # NixOS コミュニティでも大設定 (Neovim Lua / WezTerm Lua 等) は
  # この Impure 方式が多数派。bin/link.sh の symlink から本宣言へ移管。
  # ─── sheldon (programs.sheldon でプラグイン Nix 宣言管理) ────────────
  # plugins.toml は programs.sheldon.settings から生成される。
  # sheldon lock によるプラグインダウンロードは引き続き必要。
  # xdg.configFile."sheldon" と home.packages の sheldon は本モジュールが代替。
  programs.sheldon = {
    enable = true;
    settings = {
      shell = "zsh";
      plugins = {
        zsh-fast-syntax-highlighting   = { github = "zdharma-continuum/fast-syntax-highlighting"; };
        zsh-autosuggestions            = { github = "zsh-users/zsh-autosuggestions"; };
        zsh-completions                = { github = "zsh-users/zsh-completions"; };
        zsh-history-substring-search   = { github = "zsh-users/zsh-history-substring-search"; };
        zsh-256color                   = { github = "chrissicool/zsh-256color"; };
        fzf-tab                        = { github = "Aloxaf/fzf-tab"; };
        zsh-you-should-use             = { github = "MichaelAquilina/zsh-you-should-use"; };
        zsh-abbr                       = { github = "olets/zsh-abbr"; };
        pure = {
          github = "sindresorhus/pure";
          tag = "v1.28.3";
          use = [ "async.zsh" "pure.zsh" ];
        };
      };
      templates = {
        defer = "{{ hooks?.pre | nl }}{% for plugin in plugins %}{{ plugin.raw }}{% endfor %}{{ hooks?.post | nl }}";
      };
    };
  };

  xdg.configFile."lazygit".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/lazygit";

  xdg.configFile."alacritty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/alacritty";

  xdg.configFile."wezterm".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/wezterm";

  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/ghostty";

  # ─── tmux (dotfiles 側で完全管理、プラグインのみ Nix 提供) ──────────
  # tmux.conf は dotfiles/.config/tmux/tmux.conf をそのまま使用。
  # TPM を廃止し、プラグインの run-file パスは Nix が nix-plugins.conf に生成。
  # tmux.conf は source-file ~/.config/tmux/nix-plugins.conf で読み込む。
  xdg.configFile."tmux/nix-plugins.conf".text = with pkgs.tmuxPlugins; ''
    run-file ${sensible.rtp}

    set -g @resurrect-processes 'false'
    set -g @resurrect-capture-pane-contents 'off'
    run-file ${resurrect.rtp}
    run-file ${continuum.rtp}

    set -g @yank_selection 'primary'
    set -g @yank_selection_mouse 'clipboard'
    set -g @yank_action 'copy-pipe-no-clear'
    run-file ${yank.rtp}

    set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
    set -g @fzf-url-history-limit '2000'
    run-file ${tmux-fzf.rtp}

    set -g @thumbs-key F
    set -g @thumbs-alphabet dvorak-homerow
    set -g @thumbs-reverse enabled
    set -g @thumbs-unique enabled
    run-file ${tmux-thumbs.rtp}
  '';

  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/tmux/tmux.conf";

  xdg.configFile."tmux/conf".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/tmux/conf";

  xdg.configFile."tmux/scripts".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/tmux/scripts";

  home.file.".tmux/bin".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.tmux/bin";

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/nvim";

  # git config を XDG 配置 (~/.config/git/config) で管理。
  # Git 1.7.12+ / libgit2 ともに対応済み。include.path の
  # ~/.gitconfig.local はそのまま維持 (bin/config.sh が書き込む)。
  # 移管前に既存 ~/.gitconfig (regular file) を削除すること:
  #   rm ~/.gitconfig && darwin-rebuild switch --flake ./nix#archfill-to-Mac-mini
  xdg.configFile."git/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/git/config";

  # aicommit2 (AI コミットメッセージ生成 CLI) は ~/.aicommit2 を読みに行く。
  # XDG 標準パスをサポートしないため、ホーム直下に symlink を置く。
  home.file.".aicommit2".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/aicommit2/config";

  # vim / gvim / IntelliJ IDEA vim plugin の設定をホーム直下に配置。
  # 設定は dotfiles 側で編集、Nix は symlink のみ宣言。
  home.file.".vimrc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.vimrc";

  home.file.".gvimrc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.gvimrc";

  home.file.".ideavimrc".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.ideavimrc";

  # Codex environment helper. Secret values are not stored in Nix. codex-env
  # prefers the mounted 1Password Environment and falls back to env.refs.
  xdg.configFile."codex/env.refs".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/codex/env.refs";

  # Devin CLI 設定。Nix がバージョンを所有するため、バックグラウンドの
  # 自己更新 (auto_update) を無効化しておく。更新は `make devin-update`。
  xdg.configFile."devin/config.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/devin/config.json";

  home.file.".local/bin/codex-env".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.local/bin/codex-env";

  home.file.".mmcp.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.mmcp.json";

  # zsh: ZDOTDIR=$HOME/.config/zsh 構成のまま dotfiles 管理を維持。
  # programs.zsh は ~/.zshrc を生成するため ZDOTDIR と競合する。
  # mkOutOfStoreSymlink で symlink のみ Nix 宣言、設定内容は dotfiles 側で編集。
  home.file.".zshenv".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.zshenv";

  xdg.configFile."zsh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/zsh";
}
