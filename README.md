# NixOS flake config
This is my personal flake for my NixOS systems;

Personal computing devices;
And home servers.

## Flake schema
```txt
nix-config/
├─ configurations/
├─ features/
├─ modules/
├─ overlays/
├─ pkgs/
├─ users/
├─ flake.nix
└─ flake.lock
```

To learn more about my setup visit the My Linux Environment.

## Home-Manager
It uses Home-Manager as a NixOS module for most configuration whilst supporting standalone home-manager as a backup.

```txt
nix-config/
├─ configurations/
│　├─ fw_13_niko/
│　│　├─ default.nix <- imports home-manager as a module
│　│　└─ hardware_configuration.nix
│　├─ ...
│　└─ standalone_guest.nix <- imports features directly
└─ ...
```

## Host configuration
A host (system) is managed and created in it's configuration file. It is a single file per host with the hostname as the folder name.

```txt
nix-config/
├─ configurations/
│　├─ laptop-fw13/
│　│　├─ default.nix <- Main file
│　│　└─ hardware_configuration.nix
│　├─ ms-01/
│　├─ vm-core/
│　├─ vm-edge/
│　└─ standalone_guest.nix
└─ ...
```

## User management
Users are declared independently from the host. The user file declares the system and home-manager user.

```txt
nix-config/
├─ users/
│　├─ niko/
│　│　├─ default.nix <- Defines system and home-manager user
│　│　├─ secrets.yaml
│　│　└─ ssh.pub
│　└─ ...
└─ ...
```

## Features
A system is primarily configured by importing features. They contain reusable system components and applications.

```txt
nix-config/
├─ features/
│　├─ groups/
│　│　├─ cli.nix
│　│　└─ wayland_desktop.nix <- imports multiple individual features.
│　├─ hyprland/
│　│　└─ default.nix
│　├─ fonts/
│　├─ waybar/ <- Individual features.
│　├─ motd.nix
│　└─ ...
└─ ...
```

Each user can thus add their configurations without duplicating everything.

```txt
Feature_A.nix
├─ NixOS component <- enable system wide configurations
└─ Home-manager component <- user configurations
```
Home-manager in a standalone mode can also import features. In that case, the NixOS part will simply be ignored during setup.

### Importing a collection of features
Groups allow to easily import features together.

For example, instead of importing:
- `features/hyprland`
- `features/waybar`

You could group them in `features/groups/wayland_desktop/default.nix` and only import:
- `features/groups/wayland_desktop.`

# Using this flake

## For a host system
You can use:

```sh
sudo nixos-rebuild switch --flake .#{host-name}
```
Please note that `.#{host-name}` can be ommited as the flake will use the current hostname to determine which configuration to build.

I keep my nix-config flake in `~/Sources/nix-config` and have a command called:

```sh
rebuild
```
which does the same thing.

## For a remote host system
TBD

## Standalone home-manager
```sh
home-manager switch --flake .#{name-of-standalone}
```

## Updating the system
Just run the following command in nix-config/ to update all inputs.

```sh
nix flake update --flake ./{path_to_dir_of_flake.lock}
```
You can specify inputs (for example; Only update the home-manager input) with:

```sh
nix flake update home-manager
```
# Bootstrapping my nix-config
TBD


