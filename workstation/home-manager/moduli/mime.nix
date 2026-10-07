{ config, pkgs, ... }:

{
  xdg.mimeApps = {
    enable = true;

    # Imposta le applicazioni predefinite per i vari tipi MIME
    defaultApplications = {
      # --- LibreOffice Writer (Documenti di testo) ---
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
      "application/msword" = [ "writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      "application/rtf" = [ "writer.desktop" ];

      # --- LibreOffice Calc (Fogli di calcolo) ---
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      "application/vnd.ms-excel" = [ "calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
      "text/csv" = [ "calc.desktop" ];

      # --- LibreOffice Impress (Presentazioni) ---
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
      
      # Testo e Documenti
      "text/plain" = [ "emacsclient.desktop" ];
      "application/pdf" = [ "org.kde.okular.desktop" ];

      # Immagini
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/png" = [ "swayimg.desktop" ];

      # Directory (fondamentale per fare aprire le cartelle a PCManFM)
      "inode/directory" = [ "pcmanfm.desktop" ];

      # Terminale
      "x-scheme-handler/terminal" = [ "com.mitchellh.ghostty.desktop" ];
      
      # Web e Media
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
    };
  };
}
