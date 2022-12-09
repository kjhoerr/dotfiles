;; config.scm | system.scm
(add-to-load-path "/home/kjhoerr/.config/guix/modules/")
; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules
 (gnu)
 ((nongnu packages linux) #:select (linux linux-firmware))
 ((nongnu system linux-initrd) #:select (microcode-initrd))
 ((kh packages) #:select (%incl-packages))
 ((kh services) #:select (%incl-services)))

;; common variables
(define username "kjhoerr")
(define host-name "ariadne")

;; not exported by gnu system
(define %default-modprobe-blacklist (@@ (gnu system) %default-modprobe-blacklist))

(operating-system
 (kernel linux)
 (initrd microcode-initrd)
 ;; includes iwlwifi, intel-microcode
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))
 (host-name host-name)
 
 (kernel-arguments
  (list
   "quiet"
   "numa=off"
   "nowatchdog"
   "nvme.noacpi=1"
   (string-append
    "modprobe.blacklist="
    (string-join
     (cons*
      "sp5100_tco"        ;; disable watchdog timer
      "pcspkr" "snd_pcsp" ;; Stop the beeping
      "uhci_hcd"          ;; USB 1.1
      %default-modprobe-blacklist)
     ","))))

 ;; plugdev group, udev support for hardware key
 (groups
  (cons
   (user-group
    (name "plugdev")
    (system? #t))
   %base-groups))

 ;; The list of user accounts ('root' is implicit).
 (users
  (cons*
   (user-account
    (name username)
    (comment username)
    (home-directory (string-append "/home/" username))
    (group "users")
    (supplementary-groups '("wheel" "netdev" "audio" "video" "input" "tty" "kvm" "plugdev" "docker")))
   %base-user-accounts))

 (packages %incl-packages)
 (services %incl-services)

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets (list "/boot/efi"))
   (keyboard-layout keyboard-layout)))
 (mapped-devices
  (list
   (mapped-device
    (source
     (uuid "3bfd1204-f91e-4050-9450-77c53b7f30f3"))
    (target "cryptroot")
    (type luks-device-mapping))))

 (file-systems
  (cons*
   (file-system
    (mount-point "/boot/efi")
    (device (uuid "2344-C297"
                  'fat32))
    (type "vfat"))
   (file-system
    (mount-point "/")
    (device "/dev/mapper/cryptroot")
    (type "ext4")
    (dependencies mapped-devices)) %base-file-systems)))

