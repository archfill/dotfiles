{
  description = "chill-rf macOS dotfiles (nix-darwin + home-manager)";

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
      system = "aarch64-darwin";
    in {
      # nix-darwin + home-manager 統合構成 (推奨)
      # 切替: sudo darwin-rebuild switch --flake ./nix#archfill-to-Mac-mini
      darwinConfigurations."archfill-to-Mac-mini" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.chill-rf = ./home.nix;
          }
        ];
      };

      # 旧: home-manager 単体構成 (移行期間中の保険、P3 で削除予定)
      homeConfigurations."chill-rf" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
