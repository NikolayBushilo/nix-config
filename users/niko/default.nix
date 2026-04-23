{
    pkgs,
    config,
    lib,
    ...
}: let
    ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
    users.mutableUsers = true;
    users.users.niko = {
        isNormalUser = true;
        shell = pkgs.zsh;
        #extraGroups = ifTheyExist [
        extraGroups = [
            "audio"
            "docker"
            "git"
            "i2c"
            "networkmanager"
            "plugdev"
            "podman"
            "video"
            "wheel"
            "lp"
            "scanner"
            "input"
        ];

    openssh.authorizedKeys.keyFiles = [
        ./id_ed25519_personal.pub
    ];
    hashedPasswordFile = config.sops.secrets.password.path;
    packages = [pkgs.home-manager];
    };

    sops.secrets.password = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
    };

    home-manager.users.niko = {

        programs.home-manager.enable = true;

        home.username = "niko";
        home.homeDirectory = "/home/niko";
        home.sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
        };

        
        xdg = {
            enable = true;

            userDirs = {
              enable = true;
              createDirectories = true;
            };

            mimeApps = {
                enable = true;
                defaultApplications = {
                "text/plain" = "nvim.desktop";
                "text/html" = "firefox.desktop";
                "x-scheme-handler/http" = "firefox.desktop";
                "x-scheme-handler/https" = "firefox.desktop";
                };
            };
        };

    };



}
