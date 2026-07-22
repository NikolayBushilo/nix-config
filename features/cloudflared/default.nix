{
    config,
    lib,
    pkgs,
    ...
}: {
    environment.systemPackages = with pkgs; [
        cloudflared
    ];

    sops.secrets."cloudflared/tunnels/admin/credentialFile" = {
        mode = "0400";
    };

    sops.secrets."cloudflared/certificateFile" = {
        mode = "0400";
    };

    services.cloudflared = {
        enable = true;
        certificateFile = config.sops.secrets."cloudflared/certificateFile".path;
        tunnels = {
            "f0538d8e-7733-4601-a364-952858dd0d48" = {
                credentialsFile = config.sops.secrets."cloudflared/tunnels/admin/credentialFile".path;
                default = "http_status:404";
                ingress = {
                    "ssh.bushilo.com" = {
                        service = "ssh://10.1.70.10:22";
                    };
                };
            };
        };
    };
}
