{
  description = "chill-rf multi-host dotfiles (nix-darwin / NixOS / standalone home-manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rovehelm = {
      url = "git+ssh://git@github.com/archfill/rovehelm.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
    let
      # ─── ヘルパー ────────────────────────────────────────────────────
      # nix-darwin ホスト (macOS): システム + home-manager を一括宣言
      mkDarwinHost = { system, hostModule, homeModule, username }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${username} = homeModule;
            }
          ];
        };

      # standalone home-manager (Arch / Ubuntu / WSL 用、user 環境のみ管理)
      mkHomeConfig = { system, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          inherit modules;
        };

      # NixOS ホスト (システム + home-manager モジュール)
      mkNixosHost = { system, hostModule, homeModule, username }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.${username} = homeModule;
            }
          ];
        };
    in {
      # ─── 自前 packages (nixpkgs の追従が遅れるものを prebuilt で最新化) ─
      # codex と cursor-agent は公式の prebuilt native binary を固定し、
      # nixpkgs の更新待ちや CLI 自身による in-place update を避ける。
      packages = nixpkgs.lib.genAttrs
        [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ]
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfreePredicate = pkg:
                nixpkgs.lib.getName pkg == "cursor-agent";
            };
          in {
            codex = pkgs.callPackage ./pkgs/codex { };
            cursor-agent = pkgs.callPackage ./pkgs/cursor-agent { };
          });

      # ─── macOS (nix-darwin + home-manager) ─────────────────────────
      # 切替: sudo darwin-rebuild switch --flake ./nix#archfill-to-Mac-mini
      darwinConfigurations."archfill-to-Mac-mini" = mkDarwinHost {
        system = "aarch64-darwin";
        hostModule = ./darwin.nix;
        homeModule = ./home.nix;
        username = "chill-rf";
      };

      # ─── Linux: standalone home-manager (Arch / Ubuntu / WSL) ─────
      # 非 NixOS Linux では system 領域 (kernel / GPU driver / display
      # manager / daemon 類) は各ディストロで管理し、開発ツール・dotfiles
      # symlink・shell/editor 環境を Nix home-manager へ寄せる。
      # 切替: home-manager switch --flake ./nix#archfill@<host>
      homeConfigurations = {
        "archfill@arch-desktop" = mkHomeConfig {
          system = "x86_64-linux";
          modules = [
            ./hosts/arch-desktop/home.nix
          ];
        };

        "archfill@ubuntu-desktop" = mkHomeConfig {
          system = "x86_64-linux";
          modules = [
            ./hosts/ubuntu-desktop/home.nix
          ];
        };

        "archfill@wsl-ubuntu" = mkHomeConfig {
          system = "x86_64-linux";
          modules = [
            ./hosts/wsl-ubuntu/home.nix
          ];
        };
      };

      # ─── NixOS (システム + home-manager) ──────────────────────────
      nixosConfigurations = {
        "nixos-vm" = mkNixosHost {
          system = "x86_64-linux";
          hostModule = ./hosts/nixos-vm/configuration.nix;
          homeModule = ./hosts/nixos-vm/home.nix;
          username = "archfill";
        };

        "archfill-nixos" = mkNixosHost {
          system = "x86_64-linux";
          hostModule = ./hosts/archfill-nixos/configuration.nix;
          homeModule = ./hosts/archfill-nixos/home.nix;
          username = "archfill";
        };

        # 実機追加時:
        # 1. cp -r ./hosts/_template/nixos ./hosts/<host>
        # 2. 実機で生成した hardware.nix を ./hosts/<host>/hardware.nix に配置
        # 3. configuration.nix の networking.hostName を <host> に変更
        # 4. 下の例を有効化
        #
        # "<host>" = mkNixosHost {
        #   system = "x86_64-linux";
        #   hostModule = ./hosts/<host>/configuration.nix;
        #   homeModule = ./hosts/<host>/home.nix;
        #   username = "archfill";
        # };
      };
    };
}
