{ pkgs, ... }:
let
  # Upstream's prebuilt client fixes this path to /audiobookshelf.
  audiobookshelf = pkgs.audiobookshelf.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      chmod -R u+w "$out/opt/client/dist"
      grep -rlZ /audiobookshelf "$out/opt/client/dist" \
        | xargs -0 --no-run-if-empty sed -i 's|/audiobookshelf|/audiobooks|g'
    '';
  });
in
{
  services.audiobookshelf = {
    enable = true;
    group = "services";
    host = "127.0.0.1";
    package = audiobookshelf;
    port = 8888;
    openFirewall = false;
  };

  systemd.services.audiobookshelf.environment.ROUTER_BASE_PATH = "/audiobooks";
}
