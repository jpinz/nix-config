{
  additions = final: _prev: import ../pkgs { pkgs = final; };

  modifications = final: prev: {
    tdarr-server = prev.tdarr-server.overrideAttrs (oldAttrs: {
      # Remove musl prebuilts that auto-patchelf can't satisfy on glibc systems
      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          rm -rf node_modules/bcrypt/prebuilds/linux-*/bcrypt.musl.node
        '';
    });
  };
}
