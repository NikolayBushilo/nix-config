{
    pkgs,
    config,
    lib,
    ...
}: let
  cfg = config.services.minecraft-servers.servers.Vanilla;
in {
    networking.firewall = {
        allowedTCPPorts = [cfg.serverProperties.server-port];
        allowedUDPPorts = [cfg.serverProperties.server-port 24454];
    }; 

    services.minecraft-servers.servers.Vanilla = rec {
        enable = true;
        autoStart = true;
        enableReload = true;
        package = pkgs.fabricServers.fabric-1_21_11.override { loaderVersion = "0.18.4"; };
        jvmOpts = "-Xms6G -Xmx12G";
        whitelist = import ../../whitelist.nix;
        serverProperties = {
            level-type = "minecraft:normal";
            difficulty = 3;
            spawn-protection = 1;
            server-port = 25565;
            online-mode = true;
            enforce-secure-profile = false;
            motd = "\\u00A7a\\u00A7lVanilla Minecraft Server\\u00A7r\\u00A7r";
            max-tick-time = 60000; # 1 minute
            level-seed = "6312920777666901627";
            max-players = 3;
        };

        symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" ( builtins.attrValues {
                Fabric-API = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/i5tSkVBH/fabric-api-0.141.3%2B1.21.11.jar";
                    sha512 = "c20c017e23d6d2774690d0dd774cec84c16bfac5461da2d9345a1cd95eee495b1954333c421e3d1c66186284d24a433f6b0cced8021f62e0bfa617d2384d0471";
                };
                NoChatReports = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/rhykGstm/NoChatReports-FABRIC-1.21.11-v2.18.0.jar";
                    sha512 = "d2c35cc8d624616f441665aff67c0e366e4101dba243bad25ed3518170942c1a3c1a477b28805cd1a36c44513693b1c55e76bea627d3fced13927a3d67022ccc"; 
                };
                FerriteCore = pkgs.fetchurl { 
                    url = "https://cdn.modrinth.com/data/uXXizFIs/versions/Ii0gP3D8/ferritecore-8.2.0-fabric.jar"; 
                    sha512 = "3210926a82eb32efd9bcebabe2f6c053daf5c4337eebc6d5bacba96d283510afbde646e7e195751de795ec70a2ea44fef77cb54bf22c8e57bb832d6217418869";
                };
                Lithium = pkgs.fetchurl { 
                    url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/qvNsoO3l/lithium-fabric-0.21.3%2Bmc1.21.11.jar"; 
                    sha512 = "2883739303f0bb602d3797cc601ed86ce6833e5ec313ddce675f3d6af3ee6a40b9b0a06dafe39d308d919669325e95c0aafd08d78c97acd976efde899c7810fd"; 
                };
                # Noisium = pkgs.fetchurl {
                #     url = "https://cdn.modrinth.com/data/KuNKN7d2/versions/V9mMIy0f/noisium-fabric-2.7.0%2Bmc1.21.6.jar";
                #     sha512 = "80cc286f3a51b2d12304ef6a44f84c11d67cedec1a02fbaf59e2e816d9b5f0abd17cc6b5a0ca5880935e9dadfea3b951b790ee1e54300c009bc419c1c7451785";
                # };
                # ModernFix = pkgs.fetchurl {
                #     url = "https://cdn.modrinth.com/data/nmDcB62a/versions/ZGxQddYr/modernfix-fabric-5.20.3%2Bmc1.21.4.jar";
                #     sha512 = "ae49114c92a048c9ce79e197fc4df028e186cf13546e710f72247382fa8076f0b70d6aa3224951f4a36c886ca236f099a011f20b021a2b0d1a75c631da4d7d52";
                # };
                ServerCore = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/4WWQxlQP/versions/zg8VIycZ/servercore-fabric-1.5.15%2B1.21.11.jar";
                    sha512 = "964392769e53f9764466e26044552f60e91137f487b49d98a85bd4dc03ab8e965f0c69bc1a43e96ef5737cd8f1a9bb75cc0a0c09dd30bab6786d8ab4bbea6e01";
                };
                Krypton = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/O9LmWYR7/krypton-0.2.10.jar";
                    sha512 = "4dcd7228d1890ddfc78c99ff284b45f9cf40aae77ef6359308e26d06fa0d938365255696af4cc12d524c46c4886cdcd19268c165a2bf0a2835202fe857da5cab";
                };
                SimpleVoiceChat = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pFTZ8sqQ/voicechat-fabric-1.21.11-2.6.12.jar";
                    sha512 = "afc78e3d8ca463fb783b00ec3d4cb938ff9249f088d077f8cd75f6c846419e0fe4916061f57a0b188a5c28565c934623c52113f476e69e82aecabaffc8e8fdcc";
                };
                XaeroMinimap = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/1bokaNcj/versions/avSqR3vF/xaerominimap-fabric-1.21.11-25.3.10.jar";
                    sha512 = "8790be4aa5af58acf4080f88204c6a0558d99780687d9c54d1827960dd6b49a23da9e3e14e680cb4636f58495c19f317d2f445460990b132e05056d1cedccc3b";
                };
                XaeroWorldmap = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/NcUtCpym/versions/CkZVhVE0/xaeroworldmap-fabric-1.21.11-1.40.11.jar";
                    sha512 = "3eb12225c10825d4887c2e915b2a331be09b6eac4a75ccc320767542c92633d11bc6a8a63cb2b28bbf062c102e4ec50000d3082892e00328044d6225b1836f65";
                };
                Chunky = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/fALzjamp/versions/1CpEkmcD/Chunky-Fabric-1.4.55.jar";
                    sha512 = "3be0e049e3dea6256b395ccb1f7dccc9c6b23cb7b1f6a717a7cd1ca55f9dbda489679df32868c72664ebb28ca05f2c366590d1e1a11f0dc5f69f947903bad833";
                };
                c2m = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/VSNURh3q/versions/olrVZpJd/c2me-fabric-mc1.21.11-0.3.6.0.0.jar";
                    sha512 = "c9b11100572fb71c3080ff11b011467624e8013b9942aade09a5c77eb62b3289667bad70501ddea8f35deb0a5d26884b79f76d4ed112d32342471ca7384b788a";
                };
                jei = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/N7YozqFm/jei-1.21.11-fabric-27.4.0.15.jar";
                    sha512 = "b5d0153a1f312f124fa7fd9ff7dd8ec4f572bea9e2a42025d8fd2b4f1e5714f246c635476afb4e27d4bbe83d69b693af6de7db2616eef761366ba6927e459b6a";
                };
                DistantHorizons = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/uCdwusMi/versions/GT3Bm3GN/DistantHorizons-2.4.5-b-1.21.11-fabric-neoforge.jar";
                    sha512 = "a9f673fac1f6f554b7394168cbe726f1a15eb2bbef1b65b3c9979853af8de70bf13a457c88ebdc30b955a071d519e86c631cdbf1dd39cdab7c73b9c2d7f165e1";
                };
                RightClickHarvest = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/Cnejf5xM/versions/MJkjKHul/rightclickharvest-fabric-4.6.1%2B1.21.11.jar";
                    sha512 = "7a5937969f0f1659cde27448d67779ceefe30744b7c95313c56271be3abf14def9217776d7abe473269f006f234edc83017062de78fc6ccf4eddf17f201ee829";
                };
                Architectury-api = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/lhGA9TYQ/versions/uNdfrcQ8/architectury-19.0.1-fabric.jar";
                    sha512 = "7ca532844a0ed3d35e8515e13d1e84f8eadfceaae93281b79ad6b4dac253f4634e3dfcc7592f9543871dec117e1a3092c196ba5eae33735162de223be19dc4ad";
                };
                JamLib-lib = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/IYY9Siz8/versions/SUWZN0xp/jamlib-fabric-1.3.5%2B1.21.11.jar";
                    sha512 = "1355fafed11fc271e25c94d79b3c9ef71cdd4243175052d2e5a806eac86728e2d5fed9b964404a257dae2e70c9b8490019fb43c34577605971c8ac0f22c0a551";
                };
















            });
        };
    };

}
