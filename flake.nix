{
  description = "Reusable Nix modules for home-manager, NixOS, and nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmt = treefmt-nix.lib.evalModule pkgs ./modules/shared/format.nix;
      in
      {
        formatter = treefmt.config.build.wrapper;

        packages =
          let
            vimLib = import ./lib/vim { inherit (pkgs) lib; };
            mkPrinter =
              name: content: pkgs.writeShellScriptBin name "cat ${pkgs.writeText "${name}.txt" content}";
          in
          {
            show-vimrc = mkPrinter "show-vimrc" (vimLib.generateVimrc { });
            show-ideavimrc = mkPrinter "show-ideavimrc" (vimLib.generateIdeavimrc { });
            show-vscode-settings = mkPrinter "show-vscode-settings" (
              builtins.toJSON (vimLib.generateVscodeSettings { })
            );
            show-vscode-keybindings = mkPrinter "show-vscode-keybindings" (
              builtins.toJSON (vimLib.generateVscodeKeybindings { })
            );
          };

        checks =
          let
            inherit (pkgs) lib;
            nfsExportResults = lib.runTests (import ./tests/nfs-export.nix { inherit lib; });
            persistResults = lib.runTests (import ./tests/persist.nix { inherit lib; });
          in
          {
            nfs-export = pkgs.runCommand "nfs-export-test" { } (
              if nfsExportResults == [ ] then
                ''
                  echo "All nfs-export tests passed"
                  touch $out
                ''
              else
                ''
                  echo "Test failures: ${builtins.toJSON nfsExportResults}"
                  exit 1
                ''
            );
            persist = pkgs.runCommand "persist-test" { } (
              if persistResults == [ ] then
                ''
                  echo "All persist tests passed"
                  touch $out
                ''
              else
                ''
                  cat <<'EOF'
                  Test failures: ${builtins.toJSON persistResults}
                  EOF
                  exit 1
                ''
            );
          };
      }
    )
    // {
      homeManagerModules = {
        infra-options = ./modules/shared/global_variables;
        git = ./modules/home-manager/programs/git.nix;
        fish = ./modules/home-manager/programs/fish.nix;
        helix = ./modules/home-manager/programs/helix;
        alacritty = ./modules/home-manager/programs/alacritty.nix;
        ghostty = ./modules/home-manager/programs/ghostty.nix;
        i3 = ./modules/home-manager/i3.nix;
        i3-status-rust = ./modules/home-manager/programs/i3_status_rust.nix;
        polybar = ./modules/home-manager/programs/polybar.nix;
        direnv = ./modules/home-manager/programs/direnv.nix;
        fzf = ./modules/home-manager/programs/fzf.nix;
        lazygit = ./modules/home-manager/programs/lazygit.nix;
        rofi = ./modules/home-manager/programs/rofi.nix;
        dunst = ./modules/home-manager/programs/dunst.nix;
        zsh = ./modules/home-manager/programs/zsh.nix;
        beets = ./modules/home-manager/programs/beets.nix;
        mako = ./modules/home-manager/programs/mako.nix;
        shared-packages = ./modules/home-manager/shared_packages.nix;
        default = {
          imports = [
            ./modules/shared/global_variables
            ./modules/home-manager/programs/git.nix
            ./modules/home-manager/programs/fish.nix
            ./modules/home-manager/programs/helix
            ./modules/home-manager/programs/alacritty.nix
            ./modules/home-manager/programs/ghostty.nix
            ./modules/home-manager/programs/direnv.nix
            ./modules/home-manager/programs/fzf.nix
            ./modules/home-manager/programs/lazygit.nix
            ./modules/home-manager/programs/dunst.nix
            ./modules/home-manager/programs/zsh.nix
            ./modules/home-manager/programs/beets.nix
          ];
        };
      };

      nixosModules = {
        infra-options = ./modules/shared/global_variables;
        hardening = {
          imports = [
            ./modules/nixos/hardening/audit.nix
            ./modules/nixos/hardening/kernel.nix
            ./modules/nixos/hardening/no-defaults.nix
            ./modules/nixos/hardening/noexec.nix
            ./modules/nixos/hardening/sshd.nix
            ./modules/nixos/hardening/sudo.nix
            ./modules/nixos/hardening/usbguard.nix
          ];
        };
        locale = ./modules/nixos/locale.nix;
        nfs-client = ./modules/nixos/nfs-client.nix;
        nfs-server = ./modules/nixos/nfs-server.nix;
        restic-backup = ./modules/nixos/restic-backup.nix;
        persist = ./modules/nixos/persist.nix;
        packages = ./modules/nixos/packages.nix;
        mosquitto = ./modules/nixos/mosquitto.nix;
        zigbee2mqtt = ./modules/nixos/zigbee2mqtt.nix;
        default = {
          imports = [
            ./modules/shared/global_variables
            ./modules/nixos/locale.nix
            ./modules/nixos/packages.nix
          ];
        };
      };

      darwinModules = {
        infra-options = ./modules/shared/global_variables;
        system = ./modules/darwin/system.nix;
        dock = ./modules/darwin/dock;
        desktoppr = ./modules/darwin/desktoppr;
        homebrew = ./modules/darwin/homebrew.nix;
        aerospace = ./modules/darwin/aerospace.nix;
        casks = ./modules/darwin/casks.nix;
        default = {
          imports = [
            ./modules/shared/global_variables
            ./modules/darwin/system.nix
            ./modules/darwin/homebrew.nix
            ./modules/darwin/aerospace.nix
            ./modules/darwin/casks.nix
          ];
        };
      };

      lib = {
        nfs = import ./lib/nfs.nix;
        vim = import ./lib/vim { inherit (nixpkgs) lib; };
      };
    };
}
