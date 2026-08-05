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

    sabnzbd = prev.sabnzbd.overrideAttrs (oldAttrs: {
      # SABnzbd opens its history SQLite DB in the default rollback-journal mode
      # with the default 5s busy timeout. On ZFS (fsync latency, no SLOG) a
      # history write can hold the write lock long enough that the web UI's
      # periodic "SELECT COUNT(*) FROM history" reader exceeds the timeout, so
      # SABnzbd logs "database is locked" and fires an error notification.
      # WAL journal mode lets readers run concurrently with the writer, and a
      # 30s busy timeout absorbs the occasional slow fsync. --replace-fail makes
      # a future SABnzbd release that moves this line fail the build loudly
      # instead of silently dropping the fix.
      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          substituteInPlace sabnzbd/database.py \
            --replace-fail \
              'self.cursor = self.connection.cursor()' \
              'self.cursor = self.connection.cursor(); self.connection.execute("PRAGMA journal_mode=WAL"); self.connection.execute("PRAGMA busy_timeout=30000")'
        '';
    });
  };
}
