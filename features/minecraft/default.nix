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

    fileSystems."/srv/minecraft" = {
        device = "minecraft";
        fsType = "virtiofs";
        options = [
            "rw"
            "nodev"
            "nosuid"
        ];
    };

    services.minecraft-servers = {
        enable = true;
        eula = true;
    };

}
