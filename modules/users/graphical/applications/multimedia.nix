{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.graphical.applications;

  # I could not find a way to avoid this...
  # I have added a few required for 2.99.10
  gimpBuildInputs = with pkgs; [
    appstream
    appstream-glib
    libarchive
    babl
    gegl
    gtk3
    glib
    gdk-pixbuf
    gobject-introspection
    vala
    pango
    cairo
    gexiv2
    harfbuzz
    isocodes
    freetype
    fontconfig
    lcms
    libpng
    libjpeg
    poppler
    poppler_data
    libtiff
    openexr
    libmng
    librsvg
    libwmf
    zlib
    libzip
    ghostscript
    aalib
    shared-mime-info
    libwebp
    libheif
    python
    libexif
    xorg.libXpm
    glib-networking
    libmypaint
    mypaint-brushes1
    libgudev
  ];
in {
  config = {
    home.packages = with pkgs; [
      vimiv-qt
      pinta
      inkscape
      krita
      ffmpegthumbnailer
      gimp
      # TODO doesn't seem to build, too tired rn to find out why
      #(gimp.override rec {
      #  gtk2 = gtk3;
      #  gtk-mac-integration-gtk2 = gtk-mac-integration;
      #})
      #(gimp.overrideAttrs (_: rec {
      #  pname = "gimp";
      #  version = "2.99.10";
      #  src = fetchurl {
      #    url = "http://download.gimp.org/pub/gimp/v${lib.versions.majorMinor version}/${pname}-${version}.tar.bz2";
      #    sha256 = "ngjxxKRV6N1N0Fef4olBnjjINds448DUDNETf7ARLyk=";
      #  };
      #
      #  patches = [
      #    (substituteAll {
      #      src = ./patches/remove-cc-reference.patch;
      #      cc_version = stdenv.cc.cc.name;
      #    })
      #  ];
      #
      #  buildInputs = gimpBuildInputs;
      #
      #  passthru = {
      #    gtk = gtk3;
      #  };
      #}))
    ];

    xdg.configFile."vimiv/vimiv.conf" = {
      text = ''
        [GENERAL]
        monitor_filesystem = True
        shuffle = False
        startup_library = True
        style = default-dark

        [COMMAND]
         history_limit = 100

        [COMPLETION]
        fuzzy = False

        [SEARCH]
        ignore_case = True
        incremental = True

        [IMAGE]
        autoplay = True
        autowrite = ask
        overzoom = 1.0

        [LIBRARY]
        width = 0.3
        show_hidden = False

        [THUMBNAIL]
        size = 128

        [SLIDESHOW]
        delay = 2.0
        indicator = slideshow:

        [STATUSBAR]
        collapse_home = True
        show = True
        message_timeout = 60000
        mark_indicator = <b>*</b>
        left = {pwd}
        left_image = {index}/{total} {basename} [{zoomlevel}]
        left_thumbnail = {thumbnail-index}/{thumbnail-total} {thumbnail-name}
        left_manipulate = {basename}   {image-size}   Modified: {modified}   {processing}
        center_thumbnail = {thumbnail-size}
        center = {slideshow-indicator} {slideshow-delay} {transformation-info}
        right = {keys}  {mark-count}  {mode}
        right_image = {keys}  {mark-indicator} {mark-count}  {mode}

        [KEYHINT]
        delay = 500
        timeout = 5000

        [TITLE]
        fallback = vimiv
        image = vimiv - {basename}

        [METADATA]
        keys1 = Exif.Image.Make, Exif.Image.Model, Exif.Image.DateTime, Exif.Photo.ExposureTime, Exif.Photo.FNumber, Exif.Photo.IsoSpeedRatings, Exif.Photo.FocalLength, Exif.Photo.LensMake, Exif.Photo.LensModel, Exif.Photo.ExposureBiasValue
        keys2 = Exif.Photo.ExposureTime, Exif.Photo.FNumber, Exif.Photo.IsoSpeedRatings, Exif.Photo.FocalLength
        keys3 = Exif.Image.Artist, Exif.Image.Copyright

        [PLUGINS]
        print = default

        [ALIASES]
      '';
    };
  };
}
