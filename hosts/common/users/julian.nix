{ pkgs, ... }:
{
  users.users.julian = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXKurM/LnTUuwWYwg7pafMiKuRQZ1dUpyb0uIL8RTC2fTTD4lGLCZqKxJF2eWp91Wwg1bVN2iSjcuoGMDEVgRqV5UghJfR6Wvg04aCIZKcpY/ObDbpj5epEgqiZxTKxZlIpdQuYGG9cFyw2xLZtXDmibyjlojrj4sQF5Sume0FrhNHX24/k3KjNv+6HILlyPYmBOnPrKMKgmh9IJAOBnxMq3UnAIyH7uevixgl3lKKTt+GQUy2cjFEVye5MBcKycCPtr5ftn2833+sPXY+YU8wxWJl+iEWSoFv5d1mSywMyZlrsqzt47IHUTh968Hn3u67V8SKzqz0UvTA8Bdp/s0XXogZOfgn/I7NIcMUOYivabzH078N3TS8zNMSfkvGOi1eOC8/FpoSWBk54teuwGy4dj3rum4Dc50+G7DpIycHf+tCkbi570cbXbOgIwY8KJHekm7R3BgOCExWTbXCZ1AIAp1VEVjWevXYuxJOqBW5WtE2VNR9fs9T7stksXPmlcPPcUnLSCE67RHXGhLT+j7yk+y9cv4N18xM8QfpqBGPjouXrI8unDWCWb4MhkafKFsvNRbSFtMqZOdGEVxXz2eboOjnraDC4DBsvVm9IvMg5WznNWf7MdA78zEzLCkrZE2V+/Z3QvnV5lMM9aLOb2Cqj7nQnlAEPJdyebyL4Q24Rw=="
    ];
  };
}
