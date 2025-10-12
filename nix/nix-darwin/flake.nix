{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    add-unstable-packages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = _prev.config.allowUnfree;
      };
    };
    username = "mathieu";
    configuration = {
      pkgs,
      lib,
      config,
      ...
    }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        add-unstable-packages
      ];
      environment.systemPackages =
        [
          pkgs.air # Live reload for go apps
          pkgs.act # Run your github Actions locally
          pkgs.bun # Fast nodejs
          pkgs.nodejs_24
          pkgs.pnpm
          pkgs.fzf
          pkgs.bat
          pkgs.git
          pkgs.gh
          pkgs.gnupg
          pkgs.unstable.go_1_25
          pkgs.unstable.zed-editor
          # pkgs.lua-language-server
          pkgs.mkalias
          pkgs.neovim
          pkgs.nil
          #pkgs.opentofu
          pkgs.pass
          pkgs.rclone
          pkgs.ripgrep
          #pkgs.rustup
          # pkgs.sqlc
          # pkgs.stylua
          # pkgs.unstable.stripe-cli
          # pkgs.tailwindcss
          # pkgs.tailwindcss-language-server
          # pkgs.qmk
          pkgs.templ
          pkgs.tmux
          pkgs.zoxide
          pkgs.starship
          pkgs.unstable.aerospace
          pkgs.unstable.opencode
          pkgs.typescript
          pkgs.unstable.ghostty-bin
          pkgs.unstable.raycast
          pkgs.unstable.sketchybar
          pkgs.lua
          pkgs.jq
          pkgs.nixd
          pkgs.unstable.typescript-language-server
          pkgs.unstable.eslint
        ];

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.caskaydia-cove
        pkgs.unstable.sketchybar-app-font
      ];

      users.users.mathieu = {
        name = username;
        home = "/Users/mathieu";
      };

      homebrew = {
        user = username;
        enable = true;
        # onActivation.cleanup = "uninstall";
        brews = [
          "mas"
          "borders"
        ];
        casks = [
          "hammerspoon"
          # "alfred"
          "notion"
          "discord"
          "the-unarchiver"
          "android-platform-tools"
          "monitorcontrol"
          "autodesk-fusion"
          "orcaslicer"
          "brave-browser"
          "font-sf-pro"
          "sf-symbols"
          "font-hack-nerd-font"
        ];
        taps = [
          "FelixKratz/formulae"
        ];
        masApps = {
          # Yoink = 457622435;
        };

        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.primaryUser = username;

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      # Auto upgrade nix package and the daemon service.
      nix.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      security.pam.services.sudo_local.touchIdAuth = true;
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      services.sketchybar.enable = true;

      system.defaults = {
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleShowAllExtensions = true;
        loginwindow.GuestEnabled = false;
        finder.FXPreferredViewStyle = "clmv";
        dock.autohide = true;
        finder.AppleShowAllExtensions = true;
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."m1pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."m1pro".pkgs;
  };
}
