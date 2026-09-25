{ config, pkgs, ... }:

let
  asimov = pkgs.callPackage ../../pkgs/asimov { };
in

# archfill-to-Mac-Studio-M4-Max の home-manager エントリ。
# home.username / home.homeDirectory は nix-darwin の users.users から
# home-manager が自動設定する (flake.nix の mkDarwinHost で宣言)。
{
  imports = [
    ../../modules/common.nix
    ../../modules/home-darwin.nix
  ];

  home.packages = [
    # Time Machine から外付けの git リポジトリ内のビルド成果物
    # (node_modules / target / .venv 等) を除外する。
    asimov

    # ─── ローカル LLM ─────────────────────────────────────────────
    # llama.cpp (Metal 有効)。llama-server / llama-cli 等を提供する。
    # サーバーは常駐させず必要時に手動起動する。
    pkgs.llama-cpp
    # mlx-lm は Nix では入れない: nixpkgs の mlx は Metal なし (MLX_BUILD_METAL=false,
    # Metal コンパイラが非 OSS のため) で CPU 専用になる。Metal 付きの PyPI wheel を
    # `uv tool install mlx-lm` で入れる (更新は `uv tool upgrade mlx-lm`)。
  ];

  # モデル置き場は外付け (外付け常時接続が前提。未マウント時に書き込むと
  # /Volumes 配下に実ディレクトリが作られる)。llama.cpp の `-hf` も
  # LLAMA_CACHE 未設定時は $HF_HOME/hub (HF Hub キャッシュ形式) に保存するため共用する。
  # 手動で置く GGUF は /Volumes/Storage/archfill/Models/gguf を `-m` で指定する。
  home.sessionVariables = {
    HF_HOME = "/Volumes/Storage/archfill/Models/huggingface";
  };

  xdg.configFile."asimov/config".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/asimov/config";

  # upstream の com.stevegrunwell.asimov と衝突しない Label で 24h ごとに実行する。
  # mdfind / tmutil / BSD stat 等の macOS 標準コマンドを使うため PATH を明示する
  # (パッケージ側は `asimov doctor` の誤検知を避けるため wrapProgram で包まない)。
  launchd.agents."asimov" = {
    enable = true;
    config = {
      Label = "com.archfill.asimov";
      ProgramArguments = [
        "${asimov}/bin/asimov"
        "--quiet"
      ];
      EnvironmentVariables = {
        PATH = "/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      StartInterval = 86400;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/asimov.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/asimov.err.log";
    };
  };
}
