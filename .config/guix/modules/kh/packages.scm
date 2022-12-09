; Indicate which modules to import to access the variables
;; used in this configuration.
(define-module (kh packages)
 #:export (%incl-packages)
 #:use-module (gnu system)
 #:use-module ((gnu packages admin) #:select (dmidecode inetutils neofetch pfetch))
 #:use-module ((gnu packages certs) #:select (nss-certs))
 #:use-module ((gnu packages compression) #:select (unzip zip))
 #:use-module ((gnu packages emacs) #:select (emacs))
 #:use-module ((gnu packages emacs-xyz) #:select (emacs-guix))
 #:use-module ((gnu packages file) #:select (file))
 #:use-module ((gnu packages fonts) #:select (font-awesome font-fira-code font-google-noto font-ibm-plex font-openmoji font-wqy-zenhei))
 #:use-module ((gnu packages freedesktop) #:select (fprintd libfprint))
 #:use-module ((gnu packages games) #:select (steam-devices-udev-rules))
 #:use-module ((gnu packages gnome) #:select (dconf gnome-tweaks gsettings-desktop-schemas))
 #:use-module ((gnu packages gnupg) #:select (gnupg pinentry pinentry-gnome3))
 #:use-module ((gnu packages linux) #:select (powertop tlp))
 #:use-module ((gnu packages package-management) #:select (nix))
 #:use-module ((gnu packages security-token) #:select (libu2f-host libyubikey yubikey-personalization))
 #:use-module ((gnu packages ssh) #:select (openssh))
 #:use-module ((gnu packages version-control) #:select (git))
 #:use-module ((gnu packages vim) #:select (neovim neovim-packer neovim-syntastic))
 #:use-module ((nongnu packages firmware) #:select (fwupd-nonfree)))

(define %font-packages 
  (list
    font-awesome
    font-fira-code
    font-google-noto
    font-ibm-plex
    font-openmoji
    font-wqy-zenhei))

(define %gnome-packages
  (list
    dconf
    gsettings-desktop-schemas
    gnome-tweaks
    pinentry-gnome3))

(define %cli-packages
  (list
    dmidecode
    file
    fprintd
    fwupd-nonfree
    git
    inetutils
    neofetch
    neovim
    neovim-packer
    neovim-syntastic
    nix
    openssh
    pfetch
    powertop
    unzip
    zip))

(define %req-packages
  (list
    gnupg
    nss-certs
    pinentry
    yubikey-personalization))

(define-public %incl-packages
  (append
   %req-packages
   %cli-packages
   %gnome-packages
   %font-packages
   %base-packages))

