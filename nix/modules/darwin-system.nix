{ config, pkgs, ... }:

# 全 macOS ホスト共通の nix-darwin system 設定。
# ホストごとの差分は nix/hosts/<host>/darwin.nix、ユーザー定義
# (users.users / system.primaryUser) は flake.nix の mkDarwinHost で宣言する。
let
  primaryUser = config.system.primaryUser;
  primaryHome = config.users.users.${primaryUser}.home;

  # com.apple.symbolichotkeys のエントリ。parameters は
  # [文字コード(65535=なし) キーコード 修飾キーのビットマスク]
  hotkey = enabled: parameters: {
    inherit enabled;
    value = {
      type = "standard";
      inherit parameters;
    };
  };
  ctrl = 262144;
in
{
  # ─── Determinate Nix を使用しているため nix-darwin の nix 管理は無効 ───
  # Determinate Installer は独自で /nix daemon を管理しているため
  # nix-darwin に介入させない (nix.enable = false が必須)
  nix.enable = false;

  # ─── プラットフォーム ─────────────────────────────────────────────
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Google 公式 CLI は Nixpkgs 上で unfree 扱いのため、対象だけ許可
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.getName pkg == "android-cli"
    || pkgs.lib.getName pkg == "antigravity-cli";

  # ─── state version (nix-darwin 自体のスキーマバージョン) ────────────
  # 変更時はマニュアルを必ず確認すること。気軽に上げない。
  system.stateVersion = 6;

  # ─── Homebrew (nix-darwin 経由で宣言的に管理) ────────────────────
  # 役割分担: 実体管理は brew、宣言は Nix。
  # - CLI ツール / 言語ランタイムは Nix (home-manager) 側で管理
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

    # Homebrew 6.0+ は非公式 tap を trust しないと読み込めず、activation が
    # 中断する。brew bundle cleanup は trust ストアを Brewfile の宣言で
    # 上書きするため、非公式 tap は必ず trusted = true で宣言する。
    taps = [
      { name = "macpaw/taps"; trusted = true; }
    ];

    # CLI は Nix (home-manager) で管理するため brew の formula は使わない
    # (旧 coreutils / curl / readline / zlib / displayplacer は削除済み)。
    brews = [ ];

    # 全 macOS ホスト共通。周辺機器用などホスト固有のものは hosts/<host>/darwin.nix。
    # 既存 Mac で brew 以外から入れたアプリを追加すると "already an App" で
    # activation が失敗するため、先に --adopt / --force で brew 管理に取り込む
    # (docs/macos-setup.md 参照)。
    casks = [
      # 新規セットアップ時に手動導入するもの (docs/macos-setup.md 参照)。
      # いずれも auto_updates true のため更新はアプリ自身に任せる。
      "1password"
      "google-chrome"
      "tailscale-app"
      "claude"
      # ターミナル / エディタ / 開発
      "wezterm"
      "ghostty"
      "zed"
      "android-platform-tools"
      "android-studio"
      "1password-cli"
      "orbstack"
      "xcodes-app"
      "beekeeper-studio"
      # AI
      "chatgpt"
      "antigravity"
      # ランチャー / ウィンドウ管理 / 常駐ユーティリティ
      "alfred"
      "rectangle"
      "hammerspoon"        # macOS 自動化 (設定パスは MJConfigFile で宣言)
      "bettertouchtool"
      "keepingyouawake"    # スリープの一時停止 (常時稼働ホストは power で宣言)
      # ブラウザ / コミュニケーション
      "brave-browser"
      "discord"
      "element"
      # 生産性 / メディア / ストレージ
      "obsidian"
      "spotify"
      "google-drive"
      "nextcloud"
      "cleanmymac"
      # リモート / オーディオ
      "chrome-remote-desktop-host"  # 他端末からこの Mac を操作する (初回設定は手動)
      "loopback"
      # その他
      "macpaw/taps/cleanmymac-cli"
      # 除外したもの:
      # - alacritty: cask が Gatekeeper 非対応で disabled (2026-09-01)。
      #   設定 (.config/alacritty) は Linux / Windows と共有するため残す
      # - aquaskk / karabiner-elements: 日本語入力はことえり、キー配置は
      #   キーボード (ZMK) 側で行うため不要
      # - jordanbaird-ice / amical / neardrop: 使わなくなったため
    ];
  };

  # ─── macOS システム設定 (nix-darwin system.defaults) ─────────────────
  # 宣言した設定は darwin-rebuild switch のたびに強制上書きされる。
  # 基準: 新マシンで毎回手動設定するのが面倒 / 常に固定したい値のみ入れる。
  # 「気分で変えたい」ものは入れない。macOS の初期値からの変更は最小限にし、
  # 変える場合は理由をコメントに残す。
  # 宣言から外しても値は初期値に戻らない (手動で戻す必要がある)。
  system.defaults = {

    CustomUserPreferences = {
      # Hammerspoon は login item として /nix の mount 前に起動することがある。
      # Home Manager の /nix/store symlink を経由せず、Data volume 上の
      # dotfiles を直接読むことで起動順への依存をなくす。
      "org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "${primaryHome}/dotfiles/.hammerspoon/init.lua";
      };

      # ─── Rectangle ────────────────────────────────────────────────
      # 初期値からの変更点のみ宣言する。Hyper (⌃⌥⇧⌘、キーボードの ZMK キーマップで
      # 送出) + キーに割り当てる。3 分割などは初期値のまま。
      # Hammerspoon の Hyper + 矢印 (enablePositioning) は無効にして Rectangle に任せている。
      # Hammerspoon が使う Hyper + E/C/F/W/O/I/R/G/N/P/H/J/K/L とは重ねない。
      # GUI で変更しても次の switch で戻るため、変更はここで行う。
      "com.knollsoft.Rectangle" = let
        hyper = keyCode: { inherit keyCode; modifierFlags = 1966080; };
      in {
        alternateDefaultShortcuts = true;
        subsequentExecutionMode = 1;
        windowSnapping = 2;
        # 半分: Hyper + 矢印
        leftHalf = hyper 123;
        rightHalf = hyper 124;
        bottomHalf = hyper 125;
        topHalf = hyper 126;
        # ウルトラワイド用の 70/30 は Hammerspoon で Hyper + A/S/Z/X に割り当て
        # (Rectangle は 70/30 を左右どちらにも作れないため。.hammerspoon/config.lua 参照)
      };

      # ─── BetterTouchTool ──────────────────────────────────────────
      # 修飾キー + ドラッグでウィンドウのどこをつかんでも移動・リサイズする
      # (ウルトラワイドでタイトルバーを探さずに済むため)。
      # 移動: ⌃⌘ + ドラッグ / リサイズ: ⌃⇧⌘ + ドラッグ。
      # ⌥ は Finder のコピー等と衝突するため使わない。反映は BTT の再起動後。
      # Hammerspoon の eventtap では ⌃ + クリックを受け取れないため BTT で行う。
      # 3 本指タップの中クリックは .config/bettertouchtool のプリセット。
      "com.hegenberg.BetterTouchTool" = {
        controlMove = true;
        cmdMove = true;
        controlResize = true;
        shiftResize = true;
        cmdResize = true;
      };

      # ─── キーボードショートカット ──────────────────────────────────
      # AppleSymbolicHotKeys は丸ごと上書きされる。ここに無い項目は macOS の
      # 初期値になる。反映は postActivation の activateSettings -u で行う。
      "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
        # Spotlight (⌘Space) / Finder 検索 (⌘⌥Space): Alfred に譲る
        "64" = hotkey false [ 65535 49 1048576 ];
        "65" = hotkey false [ 65535 49 1572864 ];
        # 入力ソース切り替え (⌃Space / ⌃⌥Space): 誤爆防止 (切替は英数/かなキー)。
        # ⌃Space は Neovim の補完 / tmux の copy-mode とも衝突する
        "60" = hotkey false [ 32 49 262144 ];
        "61" = hotkey false [ 32 49 786432 ];
        # 左右の操作スペースへ移動 (⌃← ⌃→ ⌃⇧← ⌃⇧→):
        # zsh の単語移動と WezTerm のタブ切り替えを奪うため無効化
        "79" = hotkey false [ 65535 123 8650752 ];
        "80" = hotkey false [ 65535 123 8781824 ];
        "81" = hotkey false [ 65535 124 8650752 ];
        "82" = hotkey false [ 65535 124 8781824 ];
        # デスクトップを表示 (F11 / ⇧F11):
        # WezTerm のフルスクリーンと Neovim のデバッガ (step into) を奪うため無効化
        "36" = hotkey false [ 65535 103 0 ];
        "37" = hotkey false [ 65535 103 131072 ];
        # デスクトップ 1〜10 へ切り替え (⌃1〜⌃0)。mru-spaces = false とセット
        "118" = hotkey true [ 65535 18 ctrl ];
        "119" = hotkey true [ 65535 19 ctrl ];
        "120" = hotkey true [ 65535 20 ctrl ];
        "121" = hotkey true [ 65535 21 ctrl ];
        "122" = hotkey true [ 65535 23 ctrl ];
        "123" = hotkey true [ 65535 22 ctrl ];
        "124" = hotkey true [ 65535 26 ctrl ];
        "125" = hotkey true [ 65535 28 ctrl ];
        "126" = hotkey true [ 65535 25 ctrl ];
        "127" = hotkey true [ 65535 29 ctrl ];
      };
    };

    # ─── グローバルドメイン ──────────────────────────────────────────
    NSGlobalDomain = {
      # キーリピート高速化 (システム設定のスライダー範囲内)
      # 値が小さいほど速い。macOS デフォルト: KeyRepeat=6, InitialKeyRepeat=68
      KeyRepeat = 2;
      InitialKeyRepeat = 25;

      # 長押しアクセント候補ポップアップを無効化 → キーリピート有効 (vim 必須)
      ApplePressAndHoldEnabled = false;

      # ─── 開発者向け: テキスト自動変換を全オフ ──────────────────
      # ON のままだとコードや CLI コマンドを貼り付けた際に
      # " → " (スマートクォート) や -- → — (スマートダッシュ) に化けてバグの元になる。
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled  = false;
      NSAutomaticCapitalizationEnabled    = false;
      NSAutomaticPeriodSubstitutionEnabled = false;

      # トラックパッド: 強めのクリック (調べる等) を無効化、軌跡の速さは最速
      "com.apple.trackpad.forceClick" = false;
      "com.apple.trackpad.scaling" = 3.0;

      # アイコンとウィジェットのスタイルを「デフォルト (自動)」に固定
      # (反映にはログアウトが必要)
      AppleIconAppearanceTheme = "RegularAutomatic";
    };

    # ─── マウス ───────────────────────────────────────────────────────
    # 軌跡の速さは最速 (ウルトラワイドで横移動が長いため)
    ".GlobalPreferences"."com.apple.mouse.scaling" = 3.0;

    # ─── Finder ───────────────────────────────────────────────────────
    finder = {
      AppleShowAllExtensions = true;      # 拡張子を常に表示
      ShowPathbar            = true;      # ウィンドウ下部にパスバー
      ShowStatusBar          = true;      # ウィンドウ下部にステータスバー
      FXPreferredViewStyle   = "clmv";    # カラム表示 (clmv/icnv/Nlsv/glyv)
    };

    # ─── トラックパッド ────────────────────────────────────────────────
    trackpad = {
      Clicking = true;                        # タップでクリック
      ActuationStrength = 0;                  # 静音クリック
      TrackpadTwoFingerDoubleTapGesture = false; # スマートズーム (右クリックとの誤爆防止)

      # 3 本指ドラッグ。GUI で ON にすると macOS が自動で 3 本指ジェスチャを
      # 無効化 (4 本指へ移動) するが、defaults では自動調整されないため明示する
      TrackpadThreeFingerDrag = true;
      TrackpadThreeFingerTapGesture = 0;          # 調べる (3 本指タップ)
      TrackpadThreeFingerHorizSwipeGesture = 0;   # 操作スペース切替 → 4 本指
      TrackpadThreeFingerVertSwipeGesture = 0;    # Mission Control → 4 本指
    };

    # ─── Dock ─────────────────────────────────────────────────────────
    dock = {
      autohide = true;
      # 操作スペースを最近の使用順に並べ替えない (⌃1〜⌃0 で番号固定で使う)
      mru-spaces = false;
      # Exposé のアプリごとのグループ化は初期値 (OFF) を明示
      # (旧 AeroSpace 用設定の名残を解消するため)
      expose-group-apps = false;
    };

    # ─── 操作スペース ─────────────────────────────────────────────────
    # 「ディスプレイごとに個別の操作スペース」を初期値 (ON) で明示
    # (spans-displays = false が ON。旧 AeroSpace 用設定の名残を解消するため)
    spaces.spans-displays = false;

    # ─── ウィンドウのタイル配置 ───────────────────────────────────────
    # Rectangle のドラッグ配置と衝突するため macOS 標準のドラッグ配置を無効化
    # (🌐+⌃+矢印 のキーボードショートカットは引き続き使える)
    WindowManager = {
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
    };

    # ─── メニューバーの時計 ───────────────────────────────────────────
    menuExtraClock.Show24Hour = true;
  };

  # symbolichotkeys などの変更をログアウトせずに反映する
  system.activationScripts.postActivation.text = ''
    launchctl asuser "$(id -u -- ${primaryUser})" sudo --user=${primaryUser} -- \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
