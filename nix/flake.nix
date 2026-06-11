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
      # mkNixosHost = { system, hostModule, homeModule, username }:
      #   nixpkgs.lib.nixosSystem {
      #     inherit system;
      #     specialArgs = { inherit inputs; };
      #     modules = [
      #       hostModule
      #       home-manager.nixosModules.home-manager
      #       {
      #         home-manager.useGlobalPkgs = true;
      #         home-manager.useUserPackages = true;
      #         home-manager.extraSpecialArgs = { inherit inputs; };
      #         home-manager.users.${username} = homeModule;
      #       }
      #     ];
      #   };
    in {
      # ─── macOS (nix-darwin + home-manager) ─────────────────────────
      # 切替: sudo darwin-rebuild switch --flake ./nix#archfill-to-Mac-mini
      darwinConfigurations."archfill-to-Mac-mini" = mkDarwinHost {
        system = "aarch64-darwin";
        hostModule = ./darwin.nix;
        homeModule = ./home.nix;
        username = "chill-rf";
      };

      # ─── Linux: standalone home-manager (Arch / Ubuntu / WSL) ─────
      # ホスト追加方法 (例):
      #   1. nix/hosts/<host>.nix を作成
      #      { config, pkgs, ... }: {
      #        home.username = "archfill";
      #        home.homeDirectory = "/home/archfill";
      #        home.stateVersion = "25.05";
      #        # ホスト固有設定 (Hyprland / WSL 連携 / etc.)
      #      }
      #   2. 下の attrset に modules を追加してコメント解除
      #   3. home-manager switch --flake ./nix#archfill@<host>
      homeConfigurations = {
        # "archfill@arch-desktop" = mkHomeConfig {
        #   system = "x86_64-linux";
        #   modules = [
        #     ./modules/common.nix
        #     ./modules/linux.nix
        #     ./hosts/arch-desktop.nix
        #   ];
        # };
        #
        # "archfill@wsl-ubuntu" = mkHomeConfig {
        #   system = "x86_64-linux";
        #   modules = [
        #     ./modules/common.nix
        #     ./modules/linux.nix
        #     ./hosts/wsl-ubuntu.nix
        #   ];
        # };
      };

      # ─── NixOS (システム + home-manager) ──────────────────────────
      # nixosConfigurations = {
      #   "nixos-desktop" = mkNixosHost {
      #     system = "x86_64-linux";
      #     hostModule = ./hosts/nixos-desktop/configuration.nix;
      #     homeModule = ./hosts/nixos-desktop/home.nix;
      #     username = "archfill";
      #   };
      # };
    };
}
