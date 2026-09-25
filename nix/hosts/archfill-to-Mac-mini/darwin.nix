{ ... }:

# archfill-to-Mac-mini の nix-darwin system 設定。
# 共通設定は modules/darwin-system.nix、ユーザー定義は flake.nix の
# mkDarwinHost で宣言する。ホスト固有の差分 (追加 cask 等) はここに書く。
{
  imports = [
    ../../modules/darwin-system.nix
  ];

  # 常時稼働 (SSH / Tailscale 経由で利用) のためスリープしない。
  # 他ホストは macOS の初期値のまま (必要時は KeepingYouAwake で一時的に止める)
  power.sleep.computer = "never";
  power.restartAfterPowerFailure = true;
}
