{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.applications;
  systemCfg = config.machineData.systemConfig;
in {
  options.ki.applications = {
    enable = mkEnableOption "Enable a set of common applications";
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      EDITOR = "vim";
    };

    home.packages = with pkgs;
      [
        # Notes
        obsidian # knowledge base
        xournalpp # drawing
        notes-up # Markdown editor

        # SSH mount
        sshfs

        # Password manager
        keepassxc

        # CLI tools
        bat
        glow
        nnn
        grit
        timewarrior
        buku
        yt-dlp

        # Run commands/programs through a specified proxy
        proxychains-ng

        # Developing
        alejandra
        cargo
        rustc
        ghc
        clang

        # Messaging
        teams # School sometimes uses ;w;

        # Productivity suite
        pdftk

        # MS Calibri compatible font
        carlito

        # Calculator
        bc
        bitwise
      ]
      ++ (
        if systemCfg.connectivity.android.enable
        then [android-tools android-file-transfer]
        else []
      );

    fonts.fontconfig.enable = true;

    programs.taskwarrior.enable = true;

    home.activation = {
      tasktime = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p ${config.xdg.dataHome}/task/hooks/
        $DRY_RUN_CMD rm -rf ${config.xdg.dataHome}/task/hooks/on-modify.timewarrior
        $DRY_RUN_CMD cp ${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior ${config.xdg.dataHome}/task/hooks/
        PYTHON3="#!${pkgs.python3}/bin/python3"
        $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i "1s@.*@$PYTHON3@" ${config.xdg.dataHome}/task/hooks/on-modify.timewarrior
        $DRY_RUN_CMD chmod +x ${config.xdg.dataHome}/task/hooks/on-modify.timewarrior
      '';
    };

    programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        vo = "gpu";
        hwdec = "auto-safe";
        ytdl-format = "ytdl-format=bestvideo[height<=?1440][fps<=?30][vcodec!=?vp9]+bestaudio/best";
      };
    };

    services.mpd = {
      enable = true;
      dataDir = "/home/${config.home.username}/.mpd";
      musicDirectory = "/home/${config.home.username}/Nextcloud/Music";
      network.listenAddress = "127.0.0.1";
      network.port = 6600;
      extraConfig = ''
        audio_output {
          type        "pipewire"
          name        "PipeWire Sound Server"
        }

        audio_output {
          type        "fifo"
          name        "FIFO audio output for visualization"
          path        "/tmp/mpd.fifo"
        }
      '';
    };

    programs.ncmpcpp = {
      enable = true;
      # Enable visualizer support
      package = pkgs.ncmpcpp.override {
        visualizerSupport = true;
        taglibSupport = true;
      };
      mpdMusicDir = "/home/${config.home.username}/Music";
      settings = {
        # NCMPCPP Data dir, for e.g error logs
        ncmpcpp_directory = "/home/${config.home.username}/.music/ncmpcpp";
        # MPD settings, connect to our local MPD instance
        mpd_host = "${config.services.mpd.network.listenAddress}";
        mpd_port = "${builtins.toString config.services.mpd.network.port}";
        # Visualizer settings
        visualizer_data_source = "/tmp/mpd.fifo";
        visualizer_output_name = "FIFO";
        visualizer_in_stereo = "yes";
        visualizer_type = "spectrum";
        visualizer_look = "●|";
        visualizer_autoscale = "yes";
        visualizer_fps = "56";
        # Cosmetic settings
        colors_enabled = "yes";
        volume_color = "white";
        state_line_color = "green";
        state_flags_color = "white";
        main_window_color = "white";
        header_window_color = "white";
        statusbar_color = "white";
        autocenter_mode = "yes";
        window_border_color = "green";
        alternative_ui_separator_color = "green";
        empty_tag_color = "yellow";
        color1 = "white";
        color2 = "green";

        current_item_prefix = "$3$r";
        current_item_suffix = "$/r$9";

        progressbar_look = "━━╸";
        progressbar_color = "white";
        progressbar_elapsed_color = "green";

        user_interface = "alternative";
        alternative_header_first_line_format = "$3$aqqu$/a$9 $4{%40f}|{%t}$9 $3$atqq$/a$9";
        alternative_header_second_line_format = "$3$aqqu$/a$9 $5$b{%a}|{%D}$/b$9 $3$atqq$/a$9";

        current_item_inactive_column_prefix = "yellow";
        current_item_inactive_column_suffix = "yellow";

        song_list_format = "{$4%a$9 - }{$8%t$9}|{$0%f$9} - {$7(%l)$9}";
        song_library_format = "{$4%n$9 - }{$0%t$9}|{$4%f$9}";
        browser_playlist_prefix = "$7playlist$9 ";
        selected_item_prefix = "$0";
        selected_item_suffix = "$9";

        song_status_format = "{(%l) }{%a - }{%t}|{%f}";
        song_window_title_format = "{%a - }{%t}|{%f}";
        song_columns_list_format = "(7f)[blue]{l} (15)[red]{a} (55)[green]{t|f} (30)[yellow]{b}";

        playlist_display_mode = "columns";
        browser_display_mode = "classic";
        search_engine_display_mode = "columns";
        incremental_seeking = "yes";
        external_editor = "vim";
      };
    };
  };
}
