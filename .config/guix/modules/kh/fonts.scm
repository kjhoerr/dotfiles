(define-module (kh fonts)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages compression))

(define-public font-merriweather
  (package
    (name "font-merriweather")
    (version "1.582")
    (source (origin
              (method url-fetch)
              (uri "https://codeload.github.com/SorkinType/Merriweather/zip/refs/tags/v1.582")
              (sha256
               (base32
                "cksoku1ectf9kq0n72u8b11c8hnha6gjl0uscbtblntjgvpm9uf"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))

         (let ((unzip    (string-append (assoc-ref %build-inputs "unzip")
                                        "/bin/unzip"))
               (font-dir (string-append %output "/share/fonts/opentype"))
               (doc-dir  (string-append %output "/share/doc/" ,name)))
           (system* unzip (assoc-ref %build-inputs "source"))
           (mkdir-p font-dir)
           (mkdir-p doc-dir)
           (for-each (lambda (font)
                       (copy-file font
                                  (string-append font-dir "/"
                                                 (basename font))))
                     (find-files "." "\\.otf$"))
           (for-each (lambda (doc)
                       (copy-file doc
                                  (string-append doc-dir "/"
                                                 (basename doc))))
                     (find-files "." "\\.pdf$"))))))
    (native-inputs
     `(("source" ,source)
       ("unzip" ,unzip)))
    (home-page "https://github.com/SorkinType/Merriweather")
    (synopsis "Font with many Unicode symbols")
    (description
     "Merriweather is useful for creating long texts for books or articles, headlines and captions.")

    ;;Merriweather is licensed under the SIL Open Font License v1.1 (http://scripts.sil.org/OFL)
    (license license:fsf-free (uri "http://scripts.sil.org/OFL"))))
