{ pkgs, ... }:

{
  # ─── Determinate Nix を使用しているため nix-darwin の nix 管理は無効 ───
  # Determinate Installer は独自で /nix daemon を管理しているため
  # nix-darwin に介入させない (nix.enable = false が必須)
  nix.enable = false;

  # ─── プラットフォーム ─────────────────────────────────────────────
  nixpkgs.hostPlatform = "aarch64-darwin";

  # ─── ユーザー定義 ─────────────────────────────────────────────────
  users.users.chill-rf = {
    name = "chill-rf";
    home = "/Users/chill-rf";
  };

  # nix-darwin の一部オプション (homebrew.onActivation 等) で primaryUser を要求
  system.primaryUser = "chill-rf";

  # ─── state version (nix-darwin 自体のスキーマバージョン) ────────────
  # 変更時はマニュアルを必ず確認すること。気軽に上げない。
  system.stateVersion = 6;

  # ─── Homebrew (nix-darwin 経由で宣言的に管理) ────────────────────
  # 役割分担: 実体管理は brew、宣言は Nix。
  # - CLI ツール / 言語ランタイムは Nix (home.nix) 側で管理
  # - macOS 固有の GUI cask 配布チャネルとして brew を維持し、
  #   nix-darwin から install/uninstall を declarative に呼ぶ
  # - P2 段階では cleanup なし (宣言と実態のドリフト発生は許容)
  # - P3 で onActivation.cleanup = "uninstall" を有効化し完全宣言化
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;       # brew update を毎回叩かない (重いため)
      upgrade = true;           # 既存 brew/cask の自動 upgrade は実行
      cleanup = "uninstall";    # 宣言外の brew/cask を自動 uninstall
                                # (config は残す。"zap" にすれば config も削除)
      extraFlags = [
        # 近年の Homebrew は brew bundle install --cleanup 実行に
        # --force / --force-cleanup / $HOMEBREW_ASK のいずれかを要求する。
        # 非対話の activation script では --force-cleanup を渡して同意する。
        "--force-cleanup"
      ];
    };

    # ⚠️ Mac App Store アプリの宣言は絶対に追加しないこと:
    # Homebrew PR #22395 (2026-05) で brew bundle cleanup が破壊的に変わり、
    # Brewfile に mas 行が 1 つでもあると Brewfile に載っていない MAS アプリ
    # (App Store で手動 install 済み、MDM 配布、Apple Configurator 経由
    # 含む) を全て削除する。具体的には homebrew.masApps を絶対に設定しないこと。
    # 参考: https://github.com/Homebrew/brew/issues/22450

    taps = [
      "grishka/grishka"
      "jakehilborn/jakehilborn"
    ];

    brews = [
      "coreutils"
      "curl"
      "readline"
      "zlib"
      "jakehilborn/jakehilborn/displayplacer"
    ];

    casks = [
      # 常用 GUI (cask_apps 相当)
      "wezterm"
      "ghostty"
      "aquaskk"
      "android-platform-tools"
      "1password-cli"
      "jordanbaird-ice"
      "rectangle"
      "orbstack"
      # オプション GUI (optional_casks 相当)
      "xcodes-app"
      "nextcloud"
      "alacritty"
      "amical"
      "zed"
      "grishka/grishka/neardrop"
    ];
  };
}
