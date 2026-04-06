{
  config,
  lib,
  pkgs,
  ...
}:
let
  gitCfg = config.infra.git;

  # Wrap git with LD_PRELOAD for Active Directory NSS resolution.
  # On AD-managed machines, the user ID is missing from /etc/passwd and needs
  # to be loaded via the correct shared object.
  adCustomGitPackage =
    let
      inherit (pkgs) git;
    in
    pkgs.writeScriptBin "git" ''
      #!${pkgs.bash}/bin/bash
      export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libnss_sss.so.2"
      exec "${git}/bin/git" "$@"
    '';

  git-package = if gitCfg.useAdWrapper then adCustomGitPackage else pkgs.git;

  signing = lib.mkIf (gitCfg.signingKeyPath != null) {
    format = "ssh";
    key = gitCfg.signingKeyPath;
    signByDefault = true;
  };
in
{
  programs.git = {
    enable = true;
    package = git-package;
    ignores = [ "*.swp" ];
    settings = {
      user = {
        name = gitCfg.userName;
        email = gitCfg.userEmail;
      };
      branch.sort = "-committerdate";
      column.ui = "auto";
      commit = {
        gpgsign = gitCfg.signingKeyPath != null;
        verbose = true;
      };
      core = {
        autocrlf = "input";
        editor = "vim";
        excludeFiles = "~/.gitignore";
        fsmonitor = true;
        untrackedCache = true;
        whitespace = "-trailing-space,-indent-with-non-tab,-tab-in-indent";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
        "sopsdiffer" = {
          textconv = "sops decrypt";
        };
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      alias = {
        dfw = "diff -w --ignore-blank-lines";
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
        followTags = true;
      };
      rebase = {
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      tag = {
        sort = "version:refname";
        gpgSign = gitCfg.signingKeyPath != null;
      };
      gpg.ssh.allowedSignersFile = lib.mkIf (gitCfg.allowedSignersFile != null) gitCfg.allowedSignersFile;
    };
    lfs = {
      enable = true;
    };
    attributes = [
      "flake.lock -diff"
    ];
    inherit signing;
  };
  programs.delta = {
    enable = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
  };
}
