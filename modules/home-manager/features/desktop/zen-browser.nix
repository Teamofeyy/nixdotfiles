{
  config,
  lib,
  pkgs,
  ...
}: let
  normalExtension = slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "normal_installed";
  };
in {
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = lib.mkDefault true;
    nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];

    # These are defaults, not locked preferences. Changes made in Zen take
    # precedence and survive future Home Manager activations.
    extraPrefs = ''
      defaultPref("zen.workspaces.continue-where-left-off", true);
      defaultPref("zen.urlbar.behavior", "float");
      defaultPref("zen.welcome-screen.seen", true);
      defaultPref("browser.startup.homepage", "about:blank");
      defaultPref("browser.newtabpage.enabled", false);
      defaultPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      defaultPref("media.ffmpeg.vaapi.enabled", true);
      defaultPref("gfx.webrender.all", true);
      defaultPref("widget.wayland.fractional-scale.enabled", true);
    '';

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
      ExtensionSettings = {
        "plasma-browser-integration@kde.org" = normalExtension "plasma-integration";
        "jid1-MnnxcxisBPnSXQ@jetpack" = normalExtension "privacy-badger17";
        "clipper@obsidian.md" = normalExtension "web-clipper-obsidian";
        "@testpilot-containers" = normalExtension "multi-account-containers";
        "uBlock0@raymondhill.net" = normalExtension "ublock-origin";
        "@zen-auto-close-tabs" = normalExtension "zen-auto-close-tabs"; 
      };
    };

    profiles.${config.home.username} = {
      isDefault = true;

      pins = {
        "Gmail" = {
          id = "795e8397-7a44-4086-95f4-af54d8b24665";
          url = "https://mail.google.com/mail/u/0/#inbox";
          position = 101;
          isEssential = true;
        };
        "GitLab" = {
          id = "5a1e0be2-2e3d-4202-b795-18e69d901e44";
          url = "https://gitlab.internal.madrigal.ru/";
          position = 102;
          isEssential = true;
        };
        "Confluence" = {
          id = "94bc7990-7a91-4fdd-ae2d-6df49221badd";
          url = "https://confluence.internal.madrigal.ru/index.action#all-updates";
          position = 103;
          isEssential = true;
        }; 
        "Jira" = {
          id = "a0013f20-47e1-474f-b512-b57c55ac8de1";
          url = "https://jira.internal.madrigal.ru/secure/RapidBoard.jspa?rapidView=9&projectKey=MSS";
          position = 104;
          isEssential = true;
        }; 
        "ChatGPT" = {
          id = "20f11868-990f-4f26-8dcc-2ad901e36c6c";
          url = "https://chatgpt.com";
          position = 105;
          isEssential = true;
        }; 
        "Github" = {
          id = "8d061451-64cd-41ea-bb59-44ada9537288";
          url = "https://github.com/Teamofeyy?tab=repositories";
          position = 106;
          isEssential = true;
        }; 
        "DeepSeek" = {
          id = "379d4290-176a-4d42-a5f6-3d4d030728f9";
          url = "https://chat.deepseek.com";
          position = 107;
          isEssential = true;
        }; 
        
      };

      mods = [
        "72f8f48d-86b9-4487-acea-eb4977b18f21" #  Better Ctrl+Tab panel
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
      ];

      #      containersForce = true; # Delete containers not declared here
      #spacesForce = true; # Delete spaces not declared here
      #TODO: fix
      # spaces = {
      #   "Personal" = {
      #     id = "c6de089c-410d-4206-961d-ab11f988d40a";
      #     position = 1000;
      #     icon = "🏠";
      #   };
      #   "Work" = {
      #     id = "cdd10fab-4fc5-494b-9041-325e5759195b";
      #     position = 2000;
      #     icon = "💼";
      #     theme = {
      #       type = "gradient";
      #       colors = [
      #         {
      #           red = 100;
      #           green = 150;
      #           blue = 200;
      #           algorithm = "floating";
      #           type = "explicit-lightness";
      #           lightness = 50;
      #         }
      #       ];
      #       opacity = 0.8;
      #       texture = 0.5;
      #     };
      #   };
      #   "Shopping" = {
      #     id = "78aabdad-8aae-4fe0-8ff0-2a0c6c4ccc24";
      #     position = 3000;
      #     icon = "💸";
      #   };
      # };
    };
  };
}
