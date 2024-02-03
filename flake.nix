{
  inputs.crane.url = "github:ipetkov/crane";
  inputs.fenix.url = "github:nix-community/fenix/main";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {
    crane,
    fenix,
    flake-utils,
    nixpkgs,
    self,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      toolchain = with fenix.packages.${system};
        combine [
          default.cargo
          default.rustc
        ];

      craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;

      src = pkgs.lib.cleanSourceWith {
        src = ./.;
        filter = _: _: true;
      };
    in
      with pkgs; {
        devShell = mkShell.override {stdenv = gcc11Stdenv;} {
          nativeBuildInputs = [cudatoolkit];
          CUDA_COMPUTE_CAP = 86;
          CUDA_PATH = cudatoolkit;
          LD_LIBRARY_PATH = "/run/opengl-driver/lib";
        };
        packages.default = craneLib.buildPackage {
          stdenv = gcc11Stdenv;
          inherit src;
          nativeBuildInputs = [cudaPackages.autoAddOpenGLRunpathHook];
          buildInputs = [cudatoolkit];
          CUDA_COMPUTE_CAP = 86;
          CUDA_PATH = cudatoolkit;
        };
      });
}
