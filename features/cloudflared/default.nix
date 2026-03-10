{
    config,
    lib,
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        cloudflared
    ];

    sops.secrets."cloudflared/tunnels/edge-vm/credentialFile" = {
        mode = "0400";
    };

    sops.secrets."cloudflared/certificateFile" = {
        mode = "0400";
    };

    services.cloudflared = {
        enable = true;
        certificateFile = config.sops.secrets."cloudflared/certificateFile".path;
        tunnels = {
            "75d17e99-8073-4a2a-978a-ed25ca5f73fc" = {
                credentialsFile = config.sops.secrets."cloudflared/tunnels/edge-vm/credentialFile".path;
                default = "http_status:404";
                ingress = {
                    "stupid-1.bushilo.com" = {
                        service = "tcp://localhost:25565";
                    };
                };
            };
        };
    };

}
