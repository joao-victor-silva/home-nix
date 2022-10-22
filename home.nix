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

    # pkgs is the set of all packages in the default home.nix implementation
    pkgs.cmake
    pkgs.tmux
    pkgs.ripgrep
    pkgs.fd
    pkgs.lazygit
    pkgs.exa
    pkgs.bat

    pkgs.nix-prefetch-github

    pkgs.gh

    # wm
    # pkgs.qtile

    # Fonts
    pkgs.inter
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
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

  # powerlevel10k config
  home.file.".p10k.zsh".source = ./zsh/.p10k.zsh;

  # neovim config
  home.file.".config/nvim".source = pkgs.fetchFromGitHub {
     owner = "joao-victor-silva";
     repo = "dotfiles";
     rev = "7975fa0";
     hash = "sha256-ZVQbOrPcc8oBE4AitoqwClf4wlCe8DwyUYBghZ839ig=";
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
    theme = "Arc-Dark";
  };

  programs.kitty = {
    enable = true;
    font.name = "JetBrains Mono Nerd Font";
    font.size = 12;
    settings = {
      shell = "zsh";
      enable_audio_bell = false;

      # The basic colors
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";

      # Cursor colors
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";

      # URL underline color when hovering with mouse
      url_color = "#F5E0DC";

      # Kitty window border colors
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      # Tab bar colors
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111B";

      # Colors for marks (marked text in the terminal)
      mark1_foreground = "#1E1E2E";
      mark1_background = "#B4BEFE";
      mark2_foreground = "#1E1E2E";
      mark2_background = "#CBA6F7";
      mark3_foreground = "#1E1E2E";
      mark3_background = "#74C7EC";

      # The 16 terminal colors

      # black
      color0 = "#45475A";
      color8 = "#585B70";

      # red
      color1 = "#F38BA8";
      color9 = "#F38BA8";

      # green
      color2 = "#A6E3A1";
      color10 = "#A6E3A1";

      # yellow
      color3 = "#F9E2AF";
      color11 = "#F9E2AF";

      # blue
      color4 = "#89B4FA";
      color12 = "#89B4FA";

      # magenta
      color5 = "#F5C2E7";
      color13 = "#F5C2E7";

      # cyan
      color6 = "#94E2D5";
      color14 = "#94E2D5";

      # white
      color7 = "#BAC2DE";
      color15 = "#A6ADC8" ;
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
      # load p10k config
      if [[ -r "${config.home.homeDirectory}/.p10k.zsh" ]]; then
        source "${config.home.homeDirectory}/.p10k.zsh"
      fi
    '';

    plugins = [
      {
        name = "key_bindings_fix";
        file = "key_bindings_fix.zsh";
	src = ./zsh;
      }

      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "v1.16.1";
          hash = "sha256-DLiKH12oqaaVChRqY0Q5oxVjziZdW/PfnRW1fCSCbjo=";
        };
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
    ];
  };
}
