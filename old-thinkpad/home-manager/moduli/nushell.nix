{ config, lib, pkgs, ... }:

{
  # Gestione dichiarativa di Nushell (ora integrata correttamente tramite Home Manager)
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      buffer_editor = "emacsclient -c";
      # Usa il cestino per ogni rm, senza bisogno di un alias.
      rm.always_trash = true;
    };
    extraConfig = ''
      def git_branch_name [] {
          let branch = (do { git branch --show-current } | complete | get stdout | str trim)
          if ($branch | is-empty) { "" } else { $" ($branch)" }
      }

      def prompt [] {
          $"(ansi cyan_bold)($env.USER)(ansi reset)@(ansi green_bold)(hostname | str trim)(ansi reset):(ansi yellow_bold)(pwd | str replace $env.HOME "~")(ansi reset)(git_branch_name) (ansi red_bold)λ(ansi reset)\n(ansi attr_bold)$> "
      }

      $env.PROMPT_COMMAND = { prompt }
      $env.PROMPT_INDICATOR = { "" }
    '';
    shellAliases = {
      g = "git";
      ll = "ls -l";
      la = "ls -la";
      yt = "yt-dlp --embed-metadata -i";
      ytt = "yt --skip-download --write-thumbnail";
      ffmpeg = "ffmpeg -hide_banner";

      # Home Manager / NixOS
      hms = "home-manager switch -f ~/.config/home-manager/home.nix";
      hmb = "home-manager build -f ~/.config/home-manager/home.nix --no-out-link";
      nrs = "sudo nixos-rebuild switch";
    };
  };
}