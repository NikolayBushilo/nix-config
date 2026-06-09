{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
    pname = "cpp-template";
    version = "0.1.0";

    src = ./.;

    nativeBuildInputs = with pkgs; [
        cmake
        ninja
        clang
    ];

    buildPhase = ''
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    '';

    installPhase = ''
    mkdir -p $out/bin
    cp build/cpp-template $out/bin/
    '';
}
