{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Julian Pinzer";
    userEmail = "julian@jpinzer.me";
    aliases = {
      co = "checkout";
      cob = "checkout -b";

      tags = "tag -l";
      branches = "branch -a";
      remotes = "remote -v";

      amend = "commit -a --amend";

      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

      whoami = "!sh -c 'echo \"$(git config --get user.name) <$(git config --get user.email)>\"'";
    };
    signing = {
      format = "ssh";
      key = "key::ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXKurM/LnTUuwWYwg7pafMiKuRQZ1dUpyb0uIL8RTC2fTTD4lGLCZqKxJF2eWp91Wwg1bVN2iSjcuoGMDEVgRqV5UghJfR6Wvg04aCIZKcpY/ObDbpj5epEgqiZxTKxZlIpdQuYGG9cFyw2xLZtXDmibyjlojrj4sQF5Sume0FrhNHX24/k3KjNv+6HILlyPYmBOnPrKMKgmh9IJAOBnxMq3UnAIyH7uevixgl3lKKTt+GQUy2cjFEVye5MBcKycCPtr5ftn2833+sPXY+YU8wxWJl+iEWSoFv5d1mSywMyZlrsqzt47IHUTh968Hn3u67V8SKzqz0UvTA8Bdp/s0XXogZOfgn/I7NIcMUOYivabzH078N3TS8zNMSfkvGOi1eOC8/FpoSWBk54teuwGy4dj3rum4Dc50+G7DpIycHf+tCkbi570cbXbOgIwY8KJHekm7R3BgOCExWTbXCZ1AIAp1VEVjWevXYuxJOqBW5WtE2VNR9fs9T7stksXPmlcPPcUnLSCE67RHXGhLT+j7yk+y9cv4N18xM8QfpqBGPjouXrI8unDWCWb4MhkafKFsvNRbSFtMqZOdGEVxXz2eboOjnraDC4DBsvVm9IvMg5WznNWf7MdA78zEzLCkrZE2V+/Z3QvnV5lMM9aLOb2Cqj7nQnlAEPJdyebyL4Q24Rw==";
      signByDefault = false;
    };
    difftastic = {
      enable = true;
    };
    extraConfig = {
      branch = {
        autosetuprebase = "always";
        sort = "-committerdate";
      };
      core = {
        autocrlf = "input";
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefsmonitor
        fsmonitor = true;
        safecrlf = false;
        untrackedCache = true;
      };
      fetch = {
        prune = true;
      };
      feature = {
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-featuremanyFiles
        # manyFiles = true;
      };
      format = {
        signOff = true;
      };
      help = {
        autocorrect = 10;
      };
      init = {
        defaultBranch = "main";
      };
      push = {
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefaultgit
        default = "current";
        gpgSign = "if-asked";
        autoSetupRemote = true;
      };
      pull = {
        rebase = true;
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      rebase = {
        autosquash = true;
        autostash = true;
        updateRefs = true;
      };
      commit = {
        verbose = true;
      };
      rerere = {
        enabled = true;
      };
      diff = {
        algorithm = "histogram";
        submodule = "log";
      };
      status = {
        submoduleSummary = true;
      };
      submodule = {
        recurse = true;
      };
      log = {
        date = "iso-local";
      };
    };
    lfs = {
      enable = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}
