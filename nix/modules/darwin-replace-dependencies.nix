{ lib, ... }:

# NixOS の system.replaceDependencies 相当を nix-darwin で使うためのオプション。
# 実際の差し替えは flake.nix の mkDarwinHost が extendModules で
# system.build.toplevel に掛ける (pkgs/replace-dependencies-darwin)。
{
  options.system.replaceDependencies.replacements = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        oldDependency = lib.mkOption { type = lib.types.package; };
        newDependency = lib.mkOption { type = lib.types.package; };
      };
    });
    default = [ ];
    description = ''
      再ビルドせずに system closure 内で差し替える依存の組。
      old と new はストアパスの名前の長さが同じであること。
    '';
  };
}
