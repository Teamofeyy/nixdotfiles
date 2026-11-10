{lib, ...}: {
  programs.noctalia.settings = {
    plugins = {
      enabled = ["teamofey/university-schedule"];
      source = [
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          enabled = true;
        }
        {
          name = "community";
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          enabled = true;
        }
        {
          name = "nixdotfiles";
          kind = "path";
          location = "${./plugins}";
          enabled = true;
        }
      ];
    };

    plugin_settings."teamofey/university-schedule".calendar_names = [
      "timarnd06@gmail.com"
    ];

    desktop_widgets = {
      enabled = lib.mkForce true;
      schema_version = 2;
      widget_order = ["university-schedule"];

      grid = {
        visible = false;
        cell_size = 16;
        major_interval = 4;
      };

      widget.university-schedule = {
        type = "teamofey/university-schedule:schedule";
        output = "HDMI-A-1";
        cx = 1670.0;
        cy = 360.0;
        box_width = 380.0;
        box_height = 0.0;
        rotation = 0.0;

        settings = {
          background = true;
          background_color = "surface";
          background_opacity = 0.92;
          background_radius = 18.0;
          background_padding = 12.0;
        };
      };
    };
  };
}
