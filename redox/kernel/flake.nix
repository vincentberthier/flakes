# git add --intent-to-add -f flake.nix
# git update-index --assume-unchanged flake.nix
{
  description = "The Nix-flake for development on the Redox’s kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      supportedSystems = [
        "i686-linux"
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: (forSystem system f));
      forSystem =
        system: f:
        f rec {
          inherit system;
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ (import inputs.rust-overlay) ];
          };
          lib = pkgs.lib;
          rust-bin = pkgs.rust-bin.nightly."2025-01-12".default.override {
            extensions = [
              "rust-analyzer"
              "rust-src"
            ];
            targets = [ "x86_64-unknown-redox" ];
          };
        };
    in
    {
      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
      devShells = forAllSystems (
        {
          system,
          pkgs,
          rust-bin,
          ...
        }:
        let
          buildInputs = with pkgs; [
            # Compilation
            rust-bin
            nasm
          ];
        in
        {
          default = pkgs.mkShell {
            inherit buildInputs;

            packages = with pkgs; [

              # Utils
              cowsay
              lolcat

              # Formatting
              dprint
              taplo

              # Cargo utilities
              bacon
              cargo-expand # for macro expension
              cargo-nextest

            ];

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;
            shellHook = ''
              export PATH="$HOME/.cargo/bin:$PATH"
              echo "Redox environment loaded" | cowsay | lolcat
            '';
          };
        }
      );
    };
}
