# Waybar Configuration
{config, ...}:
let
  user = "niko";
in
{
  # Home-manager entrypoint
  home-manager.users.${user}.programs.waybar = {
    enable = true;

    systemd.enable = true;

    style = ./style.css;

    settings.mainBar = {
      layer = "top";
      mode="overlay";
      position = "left";
      width = 60;
      margin = "10 5 10 10";
      output = [ "DP-2" ];
      reload_style_on_change=true;
      start_hidden=true;

      modules-center = [ "clock" ];

      clock = {
	interval = 1;
	format = "{:%H\n:%M}";
	format-alt = "{:%d\n%m\n%y}";
        calendar.format.today = "<span color='#98971A'><b>{}</b></span>";
      };
    };
  };

}
