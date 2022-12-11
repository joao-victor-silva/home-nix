{
  config,
  pkgs,
  ...
}: let
  nixGLIntel =
    (pkgs.callPackage "${builtins.fetchTarball {
        url = https://github.com/guibou/nixGL/archive/7165ffbccbd2cf4379b6cd6d2edd1620a427e5ae.tar.gz;
        sha256 = "1wc85xqnq2wb008y9acb29jbfkc242m9697g2b8j6q3yqmfhrks1";
      }}/nixGL.nix"
      {})
    .nixGLIntel;
  targets.genericLinux.enable = true;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "user name here";
  home.homeDirectory = "/home/<user name here>";

  fonts.fontconfig.enable = true;

  #xsession = {
  #  enable = true;
  #  windowManager.command = ''
  #    ${config.home.homeDirectory}/.nix-profile/bin/qtile start
  #  '';
  #};

  # Packages to install
  home.packages = [
    # libs
    pkgs.glibc
    pkgs.libcxx
    pkgs.gcc

    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.cmake
    pkgs.tmux
    pkgs.ripgrep
    pkgs.fd
    pkgs.lazygit
    pkgs.exa
    pkgs.bat
    pkgs.xclip
    pkgs.starship

    pkgs.nix-prefetch-github

    pkgs.gh

    # wm
    # pkgs.qtile

    # Fonts
    pkgs.inter
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})

    # Flatpak support
    pkgs.flatpak
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # tmux config
  home.file.".tmux.conf".source = ./tmux/tmux.conf;

  # neovim config
  home.file.".config/nvim".source = pkgs.fetchFromGitHub {
     owner = "joao-victor-silva";
     repo = "dotfiles";
     rev = "7975fa0";
     hash = "sha256-Z3Indyj5O8VUuWEILC8Gqq+51fm+syLxUzyCbohHxX0=";
  };

  # https://unix.stackexchange.com/questions/364773/how-to-get-installed-application-to-be-detected-by-rofi
  programs.rofi = {
    enable = true;
    font = "Inter 12";
    terminal = "kitty";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = " 﩯  Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
      kb-cancel = "Super+space,Escape";
    };
    # theme = "Arc-Dark";
    theme = ./rofi/theme.rasi;
  };

  programs.kitty = {
    enable = true;
    font.name = "JetBrains Mono Nerd Font";
    font.size = 12;
    theme = "Catppuccin-Mocha";
    settings = {
      shell = "zsh";
      enable_audio_bell = false;
    };

    # https://pmiddend.github.io/posts/nixgl-on-ubuntu/
    # https://discourse.nixos.org/t/using-nixgl-to-fix-opengl-applications-on-non-nixos-distributions/9940
    package = pkgs.writeShellScriptBin "kitty" ''
      #!/bin/sh

      ${nixGLIntel}/bin/nixGLIntel ${pkgs.kitty}/bin/kitty "$@"
    '';
  };

  programs.neovim = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    initExtra = ''
      # source the nix profiles
      if [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
        source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
      fi

      # starship
      eval "$(starship init zsh)"
    '';

    plugins = [
      {
        name = "key_bindings_fix";
        file = "key_bindings_fix.zsh";
	src = ./zsh;
      }

      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          hash = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }

      {
        name = "fast-syntax-highlighting";
        file = "fast-syntax-highlighting.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          hash = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
        };
      }
    ];

    shellAliases = {
      ls = "exa";
      cat = "bat";
    };
  };

  programs.git = {
    enable = true;
    userName = "git user name here";
    userEmail = "git user email here";
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
    ignores = [
      ".direnv"
      ".envrc"
    ];
  };

  services.dunst = {
    enable = true;
  };
}
