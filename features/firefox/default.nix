{config, ...}:
let
  user = "niko";
in
{

  # Home-manager entrypoint
  home-manager.users.${user}.programs.firefox = {
    enable = true;
  };

}
