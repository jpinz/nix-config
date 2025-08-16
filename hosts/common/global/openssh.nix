{
  services = {
    openssh = {
      enable = true;
      ports = [ 2222 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
  };
  programs.ssh.startAgent = true;
}
