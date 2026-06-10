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
  ];
}
