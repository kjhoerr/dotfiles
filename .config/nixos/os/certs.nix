{ config, lib, pkgs, ... }:
let
  jdk = config.cacerts.jdkPackage;
  add-keystore-cert = aliasname: cert: ''
    ${jdk}/bin/keytool \
      -importcert \
      -file ${cert} \
      -keystore $out \
      -alias ${aliasname} \
      -noprompt \
      -trustcacerts
  '';
  compile-command-keystore-certs = certs: lib.concatStrings (builtins.attrValues (
    builtins.mapAttrs add-keystore-cert certs
  ));

  cacertsFile = pkgs.runCommand "cacerts-custom" {} ''
    cp ${jdk}/lib/openjdk/lib/security/cacerts $out
    chmod +w $out

    ${compile-command-keystore-certs config.cacerts.certificateFiles}
  '';

in {
  options = {
    cacerts.jdkPackage = lib.mkPackageOption pkgs "openjdk21_headless" { };
    cacerts.certificateFiles = lib.mkOption {
      type = with lib.types; attrsOf path;
      default = { };
      example = lib.literalExpression ''{ cert-for-bundle = /persist/ssl/certs/cert-for-bundle.crt; }'';
      description = ''
        A map of custom cert files. These are concatenated to form the system's
        default CA bundle as well as used to create a custom cacerts file for
        use by Java.
      '';
    };
  };

  config = {
    # Include cert files in default CA cert bundle used system-wide
    security.pki.certificateFiles = builtins.attrValues config.cacerts.certificateFiles;

    # Ensure javax.net.ssl.trustStore property is set to the custom cacerts file
    environment.variables.JAVAX_NET_SSL_TRUSTSTORE = cacertsFile;
    #environment.variables._JAVA_OPTIONS = " -Djavax.net.ssl.trustStore=${cacertsFile}";

    # Allow NIX_SSL_CERT_FILE to be overridden and passed through for the nix
    # daemon if a new cert file is required in the CA chain
    security.sudo.extraConfig = ''
      Defaults env_keep += "NIX_SSL_CERT_FILE"
    '';
  };
}
