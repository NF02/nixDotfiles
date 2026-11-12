{ config, lib, pkgs, ... }:

let
  # Ivy Bridge (HD 4000, Gen7) usa il driver VA-API i965.
  # iHD supporta da Broadwell (Gen8) in poi, quindi non questa GPU.
  vaapiDriver = pkgs.intel-vaapi-driver;
  # L'HD 4000 non ha VDPAU nativo: su Intel si usa il traduttore
  # libvdpau-va-gl, che in decodifica supporta solo H.264.
  vdpauDriver = pkgs.libvdpau-va-gl;
in
{
  # Driver VA-API + vainfo per verificare l'accelerazione hardware.
  home.packages = with pkgs; [
    vaapiDriver
    libva-utils
    vdpauDriver
  ];

  # Binari personali, senza dover modificare il PATH a mano.
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  # Variabili di sessione: Home Manager le esporta sia in bash sia in Nushell
  # (tramite env.nu -> hm-session-vars.nu).
  home.sessionVariables = {
    # Editor: EDITOR/VISUAL sono già impostati da services.emacs.defaultEditor.
    PAGER = "less";
    LESS = "-FRX";
    MANPAGER = "less -R";

    # Terminale e integrazione Wayland.
    TERMINAL = "alacritty";
    BROWSER = "firefox";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";

    # Accelerazione video: VA-API (i965) come via principale.
    LIBVA_DRIVER_NAME = "i965";
    LIBVA_DRIVERS_PATH = "${vaapiDriver}/lib/dri";
    # VDPAU tradotto su VA-API. Il path esplicito serve perché il
    # libvdpau di nixpkgs cerca in /run/opengl-driver/lib/vdpau,
    # che su questo sistema non esiste (hardware.graphics off).
    VDPAU_DRIVER = "va_gl";
    VDPAU_DRIVER_PATH = "${vdpauDriver}/lib/vdpau";
  };

  # Terminale predefinito per xdg-terminal-exec e per i portali XDG.
  xdg.configFile."xdg-terminals.list" = {
    force = true;
    text = "Alacritty.desktop\n";
  };
}
