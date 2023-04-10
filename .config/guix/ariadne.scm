;; config.scm | system.scm
(add-to-load-path "/home/kjhoerr/.config/guix/modules/")
; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules
 (gnu)
 ((kh packages) #:select (%incl-packages))
 ((kh services) #:select (%incl-services)))

;; common variables
(define username "kjhoerr")
(define host-name "ariadne")

;; not exported by gnu system
(define %default-modprobe-blacklist (@@ (gnu system) %default-modprobe-blacklist))

(operating-system
 (locale "en_US.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))
 (host-name host-name)
 
 (kernel-arguments
  (list
   "quiet"
   "numa=off"
   "nowatchdog"
   (string-append
    "modprobe.blacklist="
    (string-join
     (cons*
      "sp5100_tco"        ;; disable watchdog timer
      "pcspkr" "snd_pcsp" ;; Stop the beeping
      "uhci_hcd"          ;; USB 1.1
      %default-modprobe-blacklist)
     ","))))

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

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "2acd6653-e121-4993-9594-22b1b153e3a8")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "4a1644df-2dc2-45dd-892d-3156a73e0c83"
                                  'ext4))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "7B41-BB11"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
