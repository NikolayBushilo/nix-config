{
    description = "Minimal C++ template (Nix + CMake + Presets)";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };
    outputs = { self, nixpkgs, flake-utils}: 
        flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs {inherit system; };
        in {
            devShells = {
                default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                        cmake
                        clang
                        ninja
                        git
                    ];

                    nativeBuildInputs = with pkgs; [
                    ];

                    shellHook = ''
                        export CC=clang
                        export CXX=clang++
                    '';
                };
            };

            packages.default = 
                pkgs.callPackage ./default.nix {};
        });
}
