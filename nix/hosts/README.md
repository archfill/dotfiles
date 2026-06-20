# NixOS hosts

このディレクトリは NixOS / standalone home-manager のホスト単位設定を置く。

## 実機 NixOS 追加手順

1. NixOS installer で実機へインストールする。
2. 実機で hardware 設定を生成する。

   ```bash
   sudo nixos-generate-config --show-hardware-config > /tmp/hardware.nix
   ```

3. この repo のテンプレートからホスト設定を作る。

   ```bash
   cp -r nix/hosts/_template/nixos nix/hosts/<host>
   cp /tmp/hardware.nix nix/hosts/<host>/hardware.nix
   ```

4. `nix/hosts/<host>/configuration.nix` の `networking.hostName` を実ホスト名へ変更する。
5. `nix/flake.nix` の `nixosConfigurations` に `<host>` を追加する。
6. 実機で switch する。

   ```bash
   sudo nixos-rebuild switch --flake ~/dotfiles/nix#<host>
   ```

   `nh` 導入後は次を使う。

   ```bash
   nh os switch ~/dotfiles/nix#<host>
   ```

## 方針

- `nix/modules/nixos-common.nix` は実機にも VM にも共通する NixOS 設定を置く。
- `hosts/<host>/hardware.nix` は必ず対象ホストで生成する。VM のものを実機へ流用しない。
- `hosts/<host>/configuration.nix` は hostname、bootloader、GPU などホスト固有設定だけに寄せる。
- passwordless sudo は VM 専用。実機では必要な期間だけ明示的に追加する。
