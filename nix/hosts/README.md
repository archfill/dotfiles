# NixOS hosts

このディレクトリは NixOS / standalone home-manager のホスト単位設定を置く。

## Arch / Ubuntu / WSL を Nix で補う方針

非 NixOS Linux では、OS installer / pacman / apt が担う範囲を最小限にし、日常的に使う user 環境は standalone home-manager に寄せる。

OS 側に残すもの:

- Nix 本体
- `git` / `curl` など dotfiles を取得して Nix を起動するための最小ツール
- kernel / GPU driver / display manager / Docker daemon / systemd service など system 領域

Nix home-manager で管理するもの:

- shell / editor / tmux / git / lazygit / gh / ghq など CLI ツール
- Node.js / Python / Go / Rust / Java など開発ランタイム
- dotfiles の symlink
- Linux 共通の Hyprland 関連 user config

用意済み standalone home-manager 出力:

```bash
home-manager switch --flake ~/dotfiles/nix#archfill@arch-desktop
home-manager switch --flake ~/dotfiles/nix#archfill@ubuntu-desktop
home-manager switch --flake ~/dotfiles/nix#archfill@wsl-ubuntu
```

`make rebuild` から明示する場合:

```bash
make rebuild NIX_ATTR='archfill@arch-desktop'
make rebuild NIX_ATTR='archfill@ubuntu-desktop'
make rebuild NIX_ATTR='archfill@wsl-ubuntu'
```

ホスト名と flake attr が一致している環境では `make rebuild` だけでもよい。

`make init` も同じ attr を受け取る。Linux ではデフォルトで Nix/Home Manager を適用し、旧 `apt` / `pacman` / 個別 app installer は実行しない。

```bash
make init NIX_ATTR='archfill@arch-desktop'
make init NIX_ATTR='archfill@ubuntu-desktop'
make init NIX_ATTR='archfill@wsl-ubuntu'
```

Nix 未導入の Linux で最低限の OS bootstrap が必要な場合だけ明示する。
この導線は curl / git / zsh などを入れ、Nix 導入手順を表示する。

```bash
make init DOTFILES_INSTALL_MODE=legacy
```

Hyprland 周辺の user 環境は Nix / Home Manager で管理する。Arch / Ubuntu / WSL でも OS 基盤パッケージ以外は standalone home-manager 出力で反映する。

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
