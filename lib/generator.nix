{ lib }:
{
  toConfigXpui = {
    colorScheme,
    currentTheme
  }:
  lib.generators.toINI {
    mkKeyValue =
      lib.generators.mkKeyValueDefault
        {
          mkValueString =
            v:
            if builtins.isBool v then
              (if v then "1" else "0")
            else
              lib.generators.mkValueStringDefault { } v;
        }
        "=";
  } 
  {
    Setting = {
      spotify_path = "__REPLACEME__";
      prefs_path = "__REPLACEME2__";
      color_scheme = "${colorScheme}";
      current_theme = "${currentTheme}";
      inject_css = true;
      inject_theme_js = true;
      replace_colors = true;
      overwrite_assets = true;
    };
  };
  
  spicedSpotify = {
    spotify,
    spicetify-cli,
    coreutils-full,
    configINI,
    catppuccin
  }:
  let
    config-xpui = builtins.toFile "config-xpui.ini" configINI;
  in
  spotify.overrideAttrs (
    _: {
    name = "spicetify";
    postInstall = ''
        set -e

        export SPICETIFY_CONFIG=$out/share/spicetify
        mkdir -p $SPICETIFY_CONFIG

        cp ${spicetify-cli}/bin/spicetify-cli $SPICETIFY_CONFIG/spicetify-cli
        ${coreutils-full}/bin/chmod +x $SPICETIFY_CONFIG/spicetify-cli
        cp -r ${spicetify-cli}/bin/jsHelper $SPICETIFY_CONFIG/jsHelper

        export PATH=$SPICETIFY_CONFIG:$PATH

        pushd $SPICETIFY_CONFIG
        
        cp ${config-xpui} config-xpui.ini
        ${coreutils-full}/bin/chmod a+wr config-xpui.ini
        
        mkdir -p $out/share/spotify
        touch $out/share/spotify/prefs

        sed -i "s|__REPLACEME__|$out/Applications/Spotify.app/Contents/Resources|g" config-xpui.ini
        sed -i "s|__REPLACEME2__|$out/share/spotify/prefs|g" config-xpui.ini
        
        mkdir -p ./Themes
        cp -r ${catppuccin}/catppuccin ./Themes/catppuccin
        ${coreutils-full}/bin/chmod -R a+wr Themes
        
        popd > /dev/null
        spicetify-cli --no-restart backup apply
      '';
    }
  );
}