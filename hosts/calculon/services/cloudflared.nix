{ pkgs, ... }:
{
  # Cloudflare Tunnel — exposes selected services at calculon.jpinzer.me
  # The tunnel token must be placed in /etc/cloudflared/tunnel-token
  # (created manually, kept out of the nix store)
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 5;
      DynamicUser = true;
      LoadCredential = "tunnel-token:/etc/cloudflared/tunnel-token";
    };
    script = ''
      ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run \
        --token "$(cat $CREDENTIALS_DIRECTORY/tunnel-token)"
    '';
  };
}
