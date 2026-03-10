{config, pkgs, ...}:
let
  user = "niko";
in
{

  # NixOS entrypoint
  fonts.fontDir.enable = true; # Create a dir w/ links to all fonts in /run/current-system/sw/share/X11/fonts

  # Home-manager entrypoint
  home-manager.users.${user} = {
    home.packages = with pkgs; [
      gnome-font-viewer
      # Fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      inter
      roboto
      jetbrains-mono
    ];

    fonts.fontconfig = {
      enable = true;
    };

    # Symlink fonts to font folder
    home.file.".local/share/fonts" = {
      source = ./enabled;
      recursive = true;
    };
    
  };
}
