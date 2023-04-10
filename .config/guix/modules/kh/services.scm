; Indicate which modules to import to access the variables
;; used in this configuration.
(define-module (kh services)
 #:export (%incl-services)
 #:use-module (gnu)
 #:use-module ((gnu packages freedesktop) #:select (fprintd libfprint))
 #:use-module ((gnu packages security-token) #:select (libu2f-host))
 #:use-module ((gnu services authentication) #:select (fprintd-service-type))
 #:use-module ((gnu services cups) #:select (cups-service-type))
 #:use-module ((gnu services desktop) #:select (bluetooth-configuration bluetooth-service-type %desktop-services elogind-configuration elogind-service-type gnome-desktop-service-type))
 #:use-module ((gnu services docker) #:select (docker-service-type))
 #:use-module ((gnu services nix) #:select (nix-service-type))
 #:use-module ((gnu services pm) #:select (tlp-configuration tlp-service-type))
 #:use-module ((gnu services security-token) #:select (pcscd-service-type))
 #:use-module ((gnu services syncthing) #:select (syncthing-configuration syncthing-service-type))
 #:use-module ((gnu services xorg) #:select (gdm-configuration gdm-service-type)))

(define username "kjhoerr")

(define-public %incl-services
  (append
   (list
    (service bluetooth-service-type
             (bluetooth-configuration
               (auto-enable? #t)))
    (service gnome-desktop-service-type)
    (service cups-service-type)
    (service docker-service-type)
    ;;(service fprintd-service-type)
    (service pcscd-service-type) ;; hardware key
    (service syncthing-service-type
             (syncthing-configuration
              (user username)))
    (service nix-service-type)
    (udev-rules-service 'fido2 libu2f-host #:groups '("plugdev"))
    (service tlp-service-type
             (tlp-configuration
              (sched-powersave-on-bat? #t))))
   (modify-services
    %desktop-services

    ;; s2idle suspend default behavior
    (elogind-service-type
     config =>
     (elogind-configuration
      (inherit config)
      (handle-power-key 'suspend)))

    ;; enable wayland for gdm, gnome
    (gdm-service-type
     config =>
     (gdm-configuration
      (inherit config)
      (wayland? #t))))))
