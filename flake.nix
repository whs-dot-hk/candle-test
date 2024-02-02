{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      with pkgs; {
        devShell = with pkgs;
          mkShell.override {stdenv = gcc11Stdenv;} {
            nativeBuildInputs = [cudatoolkit];
            CUDA_COMPUTE_CAP = 86;
            CUDA_PATH = cudatoolkit;
            LD_LIBRARY_PATH = "/run/opengl-driver/lib";
          };
      });
}
