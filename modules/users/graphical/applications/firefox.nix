{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical.applications;
in {
  options.ki.graphical.applications.firefox = {
    enable = mkEnableOption "Enable Firefox configured";
  };

  config = mkIf cfg.firefox.enable {
    programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bypass-paywalls-clean
        darkreader
        metamask
        ublock-origin
        sponsorblock
        clearurls
        cookie-autodelete
        (buildFirefoxXpiAddon {
          pname = "tokyo-night-v2";
          addonId = "tokyo-night-v2@fun840";
          version = "1.0";
          url = "https://addons.mozilla.org/firefox/downloads/file/3872556/tokyo_night_v2-1.0.xpi";
          sha256 = "NemfZYTUUEEpFsla89w87fTHlGV8VLvB3ekAokiAzfk=";

          meta = with lib; {
            description = "Tokyo Night theme";
            license = pkgs.lib.licenses.cc-by-nc-sa-30;
            platforms = pkgs.lib.platforms.all;
          };
        })
      ];
      profiles = {
        personal = {
          id = 0;
          settings = let
            newTab = let
              activityStream = "browser.newtabpage.activity-stream";
            in {
              "${activityStream}.feeds.topsites" = true;
              "${activityStream}.feeds.section.highlights" = true;
              "${activityStream}.feeds.section.topstories" = false;
              "${activityStream}.feeds.section.highlights.includePocket" = false;
              "${activityStream}.section.highlights.includePocket" = false;
              "${activityStream}.showSearch" = false;
              "${activityStream}.showSponsoredTopSites" = false;
              "${activityStream}.showSponsored" = false;
            };

            searchBar = {
              "browser.urlbar.suggest.quicksuggest.sponsored" = false;
              "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            };

            telemetry = let
              telKit = "toolkit.telemetry";
              activityStream = "browser.newtabpage.activity-stream";
            in {
              "${activityStream}.telemetry" = false;
              "${activityStream}.feeds.telemetry" = false;
              "browser.ping-centre.telemetry" = false;
              "${telKit}.reportingpolicy.firstRun" = false;
              "${telKit}.unified" = false;
              "${telKit}.archive.enabled" = false;
              "${telKit}.updatePing.enabled" = false;
              "${telKit}.shutdownPingSender.enabled" = false;
              "${telKit}.newProfilePing.enabled" = false;
              "${telKit}.bhrPing.enabled" = false;
              "${telKit}.firstShutdownPing.enabled" = false;
              "datareporting.healthreport.uploadEnabled" = false;
              "datareporting.policy.dataSubmissionEnabled" = false;
              "app.shield.optoutstudies.enable" = false;
            };

            domPrivacy = {
              "dom.battery.enabled" = false;
            };

            https = {
              "dom.security.https_only_mode" = true;
              "dom.security.https_only_mode_ever_enabled" = true;
            };

            graphics = {
              "media.ffmpeg.vaapi.enabled" = true;
              "media.rdd-ffmpeg.enabled" = true;
              "media.navigator.mediadataencoder_vpx_enabled" = true;
            };

            scroll = let
              smooth = "general.smoothScroll.msdPhysics";
            in {
              "${smooth}.enabled" = true;
              "${smooth}.motionBeginSpringConstant" = 450;
              "${smooth}.continuousMotionMaxDeltaMS" = 250;
              "${smooth}.regularSpringConstant" = 450;
              "${smooth}.slowdownMinDeltaMS" = 50;
              "${smooth}.slowdownMinDeltaRatio;0" = 4;
              "${smooth}.slowdownSpringConstant" = 5000;
              "mousewheel.min_line_scroll_amount" = 22;
              "toolkit.scrollbox.horizontalScrollDistance" = 4;
              "toolkit.scrollbox.verticalScrollDistance" = 5;
            };

            general = {
              "widget.use-xdg-desktop-portal.file-picker" = 2;
              "widget.use-xdg-desktop-portal.mime-handler" = 2;
              "browser.aboutConfig.showWarning" = false;
              "browser.shell.checkDefaultBrowser" = false;
              "browser.toolbars.bookmarks.visibility" = "newtab";
              "browser.urlbar.showSearchSuggestionsFirst" = false;
              "extensions.htmlaboutaddons.inline-options.enabled" = false;
              "extensions.htmlaboutaddons.recommendations.enabled" = false;
              "extensions.pocket.enabled" = false;
              "browser.fullscreen.autohide" = false;
            };

            passwords = {
              "signon.rememberSignons" = false;
              "signon.autofillForms" = false;
              "signon.generation.enabled" = false;
              "signon.management.page.breach-alerts.enabled" = false;
            };

            downloads = {
              "browser.download.useDownloadDir" = false;
            };
          in
            newTab // searchBar // telemetry // domPrivacy // https // graphics // scroll // general // passwords // downloads;
        };
      };
    };
  };
}
