# Strata (Qwen3.8-Flash-Next) のローカル LLM サーバーを常駐させる systemd システムサービスと、切替ダッシュボード。
#
# 起動の中身（引数・環境変数・Tailscale IP の待機・API キー）は github.com/archfill/localllm の
# ops/strata/run-server.sh、ダッシュボードは同リポジトリの ops/strata-switch にある。ここは unit と polkit の定義だけを持つ。
# リポジトリは /home/archfill/git/strata に置く前提。元の例とその説明は hosts/archfill-nixos/nixos-strata.nix.example。
#
# - strata-gyro_m: 起動時に自動で立ち上がる（既定、2026-10-20 から）。strata-iq3_s / strata-iq2_xs: 手動（wantedBy なし）。3 つは互いに conflicts。
# - strata-switch: モデル切替ダッシュボード。Tailscale IP:8081。自動起動しない（2026-10-20 から。使うときは `sudo systemctl start strata-switch`）。事前に `bash ops/strata-switch/build.sh` で build/strata-switch を作る。
#   systemctl の start/stop は下の polkit ルール（strata-gyro_m / strata-iq2_xs / strata-iq3_s の start・stop のみ）で許可する。
# - 確認: `systemctl status strata-gyro_m` / `systemctl status strata-switch` / `journalctl -u strata-gyro_m -f`。
# - 前提: /mnt/models のマウントは ./hardware.nix、API キーは /mnt/models/qwen-work/strata.env（STRATA_API_KEY=...、権限600、git 管理外）。
{ config, lib, pkgs, ... }:

let
  repo = "/home/archfill/git/strata";
  sizes = [ "iq2_xs" "iq3_s" "gyro_m" ];
  limits = { iq2_xs = "60G"; iq3_s = "61G"; gyro_m = "57G"; };
  mkService = size: {
    description = "Strata Qwen3.8-Flash-Next ${size} (OpenAI/Anthropic API on Tailscale)";
    wantedBy = lib.optional (size == "gyro_m") "multi-user.target";
    conflicts = map (s: "strata-${s}.service") (lib.filter (s: s != size) sizes);
    after = [ "network-online.target" "tailscaled.service" ];
    wants = [ "network-online.target" "tailscaled.service" ];
    unitConfig.RequiresMountsFor = [ "/mnt/models" repo ];
    # run-server.sh が使うコマンド（ip, grep, sleep, cat）
    path = [ pkgs.iproute2 pkgs.coreutils pkgs.gnugrep ];
    serviceConfig = {
      User = "archfill";
      Group = "users";
      EnvironmentFile = "/mnt/models/qwen-work/strata.env";   # STRATA_API_KEY=... の1行（git 管理外、権限600）
      ExecStart = "${pkgs.bash}/bin/bash ${repo}/ops/strata/run-server.sh ${size}";
      MemoryMax = limits.${size};
      MemorySwapMax = 0;
      # デスクトップと同居しスワップが無いため、メモリ逼迫時の OOM キラーの優先度。有効化は判断次第（既定は 0）。
      # Strata は 45〜59GB と最大のプロセスなので、既定でもまず狙われやすい。
      #   -500: Strata を守る（代わりにブラウザなどデスクトップ側が落ちる）
      #   +500: Strata を先に落とす（デスクトップを守る）
      # OOMScoreAdjust = -500;
      Restart = "on-failure";
      RestartSec = 30;
      TimeoutStartSec = 900;
      TimeoutStopSec = 60;
      # StandardOutput / StandardError は既定（journald）
    };
  };
in
{
  systemd.services = lib.listToAttrs (map
    (size: lib.nameValuePair "strata-${size}" (mkService size))
    sizes) // {
    # モデル切替ダッシュボード（ops/strata-switch）。Tailscale IP:8081 で待ち受ける。
    strata-switch = {
      description = "Strata model switch dashboard";
      # 自動起動しない（Gyro-M を常用し、切替はほとんど使わないため。2026-10-20）
      after = [ "network-online.target" "tailscaled.service" ];
      wants = [ "network-online.target" "tailscaled.service" ];
      unitConfig = {
        RequiresMountsFor = [ "/mnt/models" repo ];
        StartLimitIntervalSec = 0;   # IP が付くまで bind 失敗を無制限に再試行する
      };
      path = [ pkgs.systemd ];   # systemctl
      serviceConfig = {
        User = "archfill";
        Group = "users";
        EnvironmentFile = "/mnt/models/qwen-work/strata.env";   # STRATA_API_KEY（切替 API の認証にも使う）
        ExecStart = "${repo}/build/strata-switch";
        Restart = "on-failure";   # Tailscale IP が付く前の bind 失敗はここで再試行して待つ
        RestartSec = 5;
        MemoryMax = "256M";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
        ProtectKernelTunables = true;
      };
    };
    # Gemma 4 E4B（llama.cpp の llama-server、GTX 1660 Ti）。Tailscale IP:8082。Strata とは別プロバイダーで同時に動く。
    # 起動の中身は同リポジトリの ops/llama-cpp/run-server.sh と hosts/archfill-nixos/llama-cpp/gemma.env。
    # 事前に ops/llama-cpp/README.md の手順で build/engine/llama-server-pascal-ptx を作る。API キーは /mnt/models/qwen-work/api-key。
    llama-gemma = {
      description = "llama.cpp Gemma 4 E4B on GTX 1660 Ti (OpenAI/Anthropic API on Tailscale)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "tailscaled.service" ];
      wants = [ "network-online.target" "tailscaled.service" ];
      unitConfig.RequiresMountsFor = [ "/mnt/models" repo ];
      # run-server.sh が使うコマンド（ip, grep, sleep, cat, uname）
      path = [ pkgs.iproute2 pkgs.coreutils pkgs.gnugrep ];
      environment = {
        # Pascal 経路のビルドは PTX のみで、初回起動時にドライバが JIT する（約 35 秒）。結果を残して 2 回目以降を速くする
        CUDA_CACHE_PATH = "/home/archfill/.nv/ComputeCache";
        CUDA_CACHE_MAXSIZE = "1073741824";
      };
      serviceConfig = {
        User = "archfill";
        Group = "users";
        ExecStart = "${pkgs.bash}/bin/bash ${repo}/ops/llama-cpp/run-server.sh gemma";
        MemoryMax = "8G";
        MemorySwapMax = 0;
        Restart = "on-failure";   # 1660 Ti の VRAM は残り約 400MB（ctx 131072）。確保に失敗したら再試行する
        RestartSec = 30;
        TimeoutStopSec = 30;
      };
    };
  };

  # strata-switch（archfill）が sudo なしで strata-* を start/stop できるようにする。他の unit・verb は許可しない。
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "archfill" &&
          action.id == "org.freedesktop.systemd1.manage-units" &&
          /^strata-(iq2_xs|iq3_s|gyro_m)\.service$/.test(action.lookup("unit")) &&
          (action.lookup("verb") == "start" || action.lookup("verb") == "stop")) {
        return polkit.Result.YES;
      }
    });
  '';
}
