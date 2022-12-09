; Indicate which modules to import to access the variables
;; used in this configuration.
(define-module (kh services)
 #:export (%incl-services)
 #:use-module (gnu)
 #:use-module ((gnu packages games) #:select (steam-devices-udev-rules))
 #:use-module ((gnu packages freedesktop) #:select (fprintd libfprint))
 #:use-module ((gnu packages security-token) #:select (libu2f-host libyubikey))
 #:use-module ((gnu services authentication) #:select (fprintd-service-type))
 #:use-module ((gnu services cups) #:select (cups-service-type))
 #:use-module ((gnu services desktop) #:select (bluetooth-service %desktop-services elogind-configuration elogind-service-type gnome-desktop-service-type))
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
    (bluetooth-service #:auto-enable? #t)
    (service gnome-desktop-service-type)
    (service cups-service-type)
    (service docker-service-type)
    ;;(service fprintd-service-type)
    (service pcscd-service-type) ;; hardware key
    (udev-rules-service 'steam-devices steam-devices-udev-rules)
    (service syncthing-service-type
	     (syncthing-configuration
	      (user username)))
    (service nix-service-type)
    (service tlp-service-type
             (tlp-configuration
              (sched-powersave-on-bat? #t))))
   (modify-services
    %desktop-services
    ;; enable substitute for nonguix
    (guix-service-type
     config =>
     (guix-configuration
      (inherit config)
      (substitute-urls
       (append (list "https://substitutes.nonguix.org") %default-substitute-urls))
      (authorized-keys
       (append (list (plain-file "non-guix.pub" "
				 (public-key
				  (ecc
				   (curve Ed25519)
				    (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
	       %default-authorized-guix-keys))))

    ;; s2idle suspend default behavior
    (elogind-service-type
     config =>
     (elogind-configuration
      (inherit config)
      (handle-power-key 'suspend)))

    ;; hardware key support
    (udev-service-type
     config =>
     (udev-configuration
      (inherit config)
      (rules
       (cons* fprintd libu2f-host libfprint libyubikey
	      (udev-configuration-rules config)))))

    ;; enable wayland for gdm, gnome
    (gdm-service-type
     config =>
     (gdm-configuration
      (inherit config)
      (wayland? #t))))))

