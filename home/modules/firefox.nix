{ config
, pkgs
, lib
, ...
}:
let
  inherit (pkgs) stdenv;
  inherit (lib) mkEnableOption mkOption mkIf literalExample;
  cfg = config.my-modules.firefox;
  mkEngine = template: alias: {
    urls = [{ inherit template; }];
    definedAliases = [ alias ];
  };
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    clearurls
    sponsorblock
    ghostery
    floccus
  ];
in
{
  options.my-modules.firefox = with lib.types; {
    enable = mkEnableOption "Custom Firefox setup";
    enableGnomeExtensions = mkEnableOption "enable GNOME extension";
    extraExtensions = mkOption {
      type = listOf package;
      default = [ ];
      example = literalExample "[ pkgs.nur.repos.rycee.firefox-addons.ublock-origin ]";
    };
    extraEngines = mkOption {
      type = attrsOf (submodule {
        options = {
          urls = mkOption {
            type = listOf (submodule {
              options = {
                template = mkOption {
                  type = str;
                };
              };
            });
          };
          definedAliases = mkOption { type = listOf str; };
        };
      });
      default = { };
      example = literalExample ''
        {
          jira = {
            urls = [ "https://jira.extranix.com/browse/{searchTerms}" ];
            definedAliases = [ "@j" ];
        }
      '';
    };
  };

  config =
    let
      allExtensions = cfg.extraExtensions ++ extensions;
      engines = {
        Google = mkEngine "https://www.google.com/search?q={searchTerms}" "@g";
        "Duck Duck Go" = mkEngine "https://duckduckgo.com/?q={searchTerms}" "@ddg";
        YouTube = mkEngine "https://www.youtube.com/results?search_query={searchTerms}" "@yt";
        "GitHub Code" = mkEngine "https://github.com/search?q={searchTerms}&type=code" "@gh";
        "Nix Packages" = mkEngine "https://search.nixos.org/packages?channel=unstable&query={searchTerms}" "@np";
        "Nix Options" = mkEngine "https://search.nixos.org/options?channel=unstable&query={searchTerms}" "@no";
        "Home Manager" = mkEngine "https://home-manager-options.extranix.com/?query={searchTerms}&release=master" "@hm";
        "Noogle" = mkEngine "https://noogle.dev/q?term={searchTerms}" "@noogle";
        "Hoogle" = mkEngine "https://hoogle.haskell.org/?hoogle={searchTerms}&scope=set%3Astackage" "@hoogle";
        "Amazon" = mkEngine "https://www.amazon.fr/s?k={searchTerms}" "@az";
        "Gleam Packages" = mkEngine "https://packages.gleam.run/?search={searchTerms}" "@gleam";
        "Artifact Hub" = mkEngine "https://artifacthub.io/packages/search?ts_query_web={searchTerms}&sort=relevance" "@artifact";
        "Docker Hub" = mkEngine "https://hub.docker.com/search?q={searchTerms}" "@docker";
        "Terraform Providers" = mkEngine "https://registry.terraform.io/search/providers?q={searchTerms}" "@tf";
        "Terraform Modules" = mkEngine "https://registry.terraform.io/search/modules?q={searchTerms}" "@tfm";
      } // cfg.extraEngines;
    in
    mkIf cfg.enable {
      programs.firefox = {
        inherit (cfg) enable;
        package =
          let
            linux-pkg =
              if cfg.enableGnomeExtensions then
                pkgs.firefox.override
                  {
                    nativeMessagingHosts = with pkgs; [ gnome-browser-connector ];
                  }
              else
                pkgs.firefox;
            mac-pkg = pkgs.firefox;
          in
          if stdenv.isLinux then linux-pkg else mac-pkg;
        policies = {
          PasswordManagerEnabled = false;
          OfferToSaveLogins = false;
          AutofillCreditCardEnabled = false;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisableTelemetry = true;
          DisablePocker = true;
          PromptForDownloadLocation = true;
          StartDownloadsInTempDirectory = true;
          ExtensionSettings = builtins.listToAttrs (
            builtins.map
              (e: lib.nameValuePair e.addonId {
                installation_mode = "force_installed";
                install_url = "file://${e.src}";
                updates_disabled = true;
                private_browsing = true;
                default_area = "navbar";
              })
              allExtensions
          );
        };
        profiles.massi = {
          extensions.packages = allExtensions;
          extensions.force = true;
          isDefault = true;
          search = {
            inherit engines;
            force = true;
            default = "google";
          };
          settings = {
            # catppuccin background color
            "browser.display.background_color.dark" = "#1e1e2e";
            "browser.discovery.enabled" = false;
            "browser.startup.homepage" = "about:blank";
            "general.smoothScroll" = true;
            "signon.autofillForms" = false;
            "widget.non-native-theme.scrollbar.style" = 3;
            "browser.uidensity" = 0;
            "browser.compactmode.show" = true;
            "breakpad.reportURL" = "";
            "browser.urlbar.trimHttps" = true;
            "browser.urlbar.trimURLs" = true;
            "browser.urlbar.suggest.calculator" = true;
            # do not send crash reports
            "browser.tabs.crashReporting.sendReport" = false;
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
            # do not warn when accessing about:config
            "browser.aboutConfig.showWarning" = false;
            # do not recommend extensions
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "extensions.getAddons.showPane" = false;
            "extensions.postDownloadThirdPartyPrompt" = false;
            "browser.preferences.moreFromMozilla" = false;
            "browser.tabs.tabmanager.enabled" = false;
            # enable tab groups
            "browser.tabs.groups.enable" = true;
            "browser.tabs.groups.smart.enabled" = true;
            "extensions.pocket.enable" = false;

            # sidebar with vertical tabs
            "sidebar.visibility" = "expand-on-hover";
            "sidebar.main.tools" = "aichat,history,bookmarks";
            "sidebar.expandOnHover" = true;
            "sidebar.verticalTabs" = true;
            "browser.toolbars.bookmarks.visibility" = "always";

            # do not open menu with Alt
            "ui.key.menuAccessKeyFocuses" = false;
            # do not show "Top Sites" in new tab page
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            # do not show "Top Stories" in new tab page
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            # disable full screen fade animation
            "full-screen-api.transition-duration.enter" = "0 0";
            "full-screen-api.transition-duration.leave" = "0 0";
            "full-screen-api.transition.timeout" = 0;
            "full-screen-api.warning.delay" = 0;
            # disable message "... is now fullscreen"
            "full-screen-api.warning.timeout" = 0;
            # disable welcome page when launching firefox for the first time
            "browser.aboutwelcome.enabled" = false;
            # dark:0 light:1 system:2 browser:3
            "layout.css.prefers-color-scheme.content-override" = 0;
            # disable address auto fill
            "extensions.formautofill.addresses.enabled" = false;
            # makes firefox faster in sway
            # https://www.reddit.com/r/swaywm/comments/1iuqclq/firefox_is_now_way_more_efficient_under_sway_it/
            "gfx.webrenderer.compositor.force-enabled" = true;
            # disable "caret"
            "accessibility.browsewithcaret_shortcut.enabled" = false;
          };
        };
      };
    };
}
