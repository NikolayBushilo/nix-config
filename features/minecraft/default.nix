{
    inputs,
    config,
    lib,
    ...
}: {
    imports = [
        inputs.nix-minecraft.nixosModules.minecraft-servers
        ./servers/Vanilla
    ];

    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
        enable = true;
        eula = true;
    };

}
