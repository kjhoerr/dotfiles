# gpg-agent.nix
{ lib, pkgs, ... }:
let
  gpg-sshid-ctl-src = builtins.readFile ../scripts/gpg-sshid-ctl.sh;
  gpg-sshid-ctl = (pkgs.writeScriptBin "gpg-sshid-ctl" gpg-sshid-ctl-src).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in {

  programs.gpg.enable = lib.mkDefault true;
  programs.gpg.mutableKeys = lib.mkDefault false;
  programs.gpg.mutableTrust = lib.mkDefault false;
  programs.gpg.publicKeys = [
    {
      text = ''
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEYw0SZxYJKwYBBAHaRw8BAQdAejOFnS2WZ+Au1T280d/uWJraC/AUqV4HIiEr
zSwnOwi0JEtldmluIEhvZXJyIDxraG9lcnJAa3NtcGFydG5lcnMuY29tPoiQBBMW
CAA4FiEE5rlyHQh9k+aM62BOVFgYvmKcfZUFAmMNE2ACGwMFCwkIBwIGFQoJCAsC
BBYCAwECHgECF4AACgkQVFgYvmKcfZXETAD+KaDR56Fr5tpNE+LWVoRcYW4Mjcip
AgQWXki5VS782uwA/iyIXl0mBDDG//NEC17N2Fs69xFd3RcAvvnzbX0TB18LtCRL
ZXZpbiBIb2VyciA8a2pob2VyckBwcm90b25tYWlsLmNvbT6IkAQTFggAOBYhBOa5
ch0IfZPmjOtgTlRYGL5inH2VBQJjDRNSAhsDBQsJCAcCBhUKCQgLAgQWAgMBAh4B
AheAAAoJEFRYGL5inH2V3YAA/3YsS9/aE7fky8KpcxT7sVRUQ6swp32r25Gfgctf
CGPAAP9Q4l+wOvbeQvd5jU/q7Dht4sVDJklhsJzlgU+MZ/1WC7QjS2V2aW4gSG9l
cnIgPGtqaG9lcnJAc3VibWVsb24udGVjaD6IkAQTFggAOBYhBOa5ch0IfZPmjOtg
TlRYGL5inH2VBQJjDRJnAhsDBQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEFRY
GL5inH2VCygBANoCtAxKurnlZBFGt+kNFtNC8BLSVrV03/fjDM+ouYVhAQC7oRWI
Kh9d6Z6zo5jlsiz7J+ohdM/krIDFd6H23oBsCbgzBGMNEskWCSsGAQQB2kcPAQEH
QEVH5c050+fT7lIYhycEVvbDx6+aNeDliEFTNLP2EULkiHgEGBYIACAWIQTmuXId
CH2T5ozrYE5UWBi+Ypx9lQUCYw0SyQIbIAAKCRBUWBi+Ypx9lUocAP9yxOytt73c
nbsKze66AAhaqN+4psDpZEn2BtwBz6LJRAEA3bNz78Ct0twtdZwsL49xX8RoCSY4
pd5y9FfAu8C/2Q24OARjDRJnEgorBgEEAZdVAQUBAQdASmPTnAx5EDeefYoxmOme
D0JGfCIE09xQK7HQ9yIEABEDAQgHiHgEGBYIACAWIQTmuXIdCH2T5ozrYE5UWBi+
Ypx9lQUCYw0SZwIbDAAKCRBUWBi+Ypx9lbjDAPwNTGQ3cipLaKeQuqbcB9wr1gBv
dRkFvHvWWUlOGTU8PAEAkwcdrCiv9u39IFb33fneTOvk3R5sUW26Ct35pF6Yjws=
=P3+j
-----END PGP PUBLIC KEY BLOCK-----
'';
      trust = "ultimate";
    }
  ];

  # gnome-keyring is greedy and will override SSH_AUTH_SOCK where undesired
  services.gnome-keyring.enable = lib.mkDefault false;

  services.gpg-agent.enable = lib.mkDefault true;
  services.gpg-agent.enableSshSupport = lib.mkDefault true;
  services.gpg-agent.enableExtraSocket = lib.mkDefault true;

  home.packages = lib.mkAfter [ gpg-sshid-ctl ];

}

