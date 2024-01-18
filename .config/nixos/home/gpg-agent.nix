# gpg-agent.nix
{ lib, pkgs, ... }:
let
  gpgsshctl = pkgs.writeShellScriptBin "gpg-sshid-ctl" ''
    #!/usr/bin/env bash
    # Enable or disable sshcontrol for a specific key or all keys when the SSH agent is controlled by GPG

    ## Script inputs

    if [ -z "$SSHCONTROL_FILE" ];
    then
      SSHCONTROL_FILE=~/.gnupg/sshcontrol
    fi

    command="$1"
    identity_file="$2"
    shift 2

    ## Input validation

    if [ ! -w "$SSHCONTROL_FILE" ];
    then
      echo "GPG sshcontrol file $SSHCONTROL_FILE is not writable." 1>&2
      exit 1
    fi

    if [ -n "$identity_file" ] && [ ! -r "$identity_file" ];
    then
      echo "Identity file $identity_file is not readable." 1>&2
      exit 1
    fi

    # Display expected usage of script
    function usage {
      echo "Usage: $0 {enable|disable} [<ID file>]" 1>&2
      exit 1
    }

    # Find and parse keygrip for keyfile provided
    function find_keygrip {
      fingerprint_output=$(ssh-keygen -lf "$1")
      fingerprint=$(echo "$fingerprint_output" | awk '{print $2}')

      keygrip_output=$(gpg-connect-agent 'keyinfo --ssh-list --ssh-fpr' /bye)
      keygrip=$(echo "$keygrip_output" | grep "$fingerprint" | awk '{print $3}')
      echo "$keygrip"
      return
    }

    # Use sed to enable or disable a given keygrip or regex group in the SSHCONTROL_FILE.
    function sshctrl {
      if [ -z "$3" ];
      then
        grip="[A-Z0-9]+"
      else
        grip="$3"
      fi
      sed -i -r "s/^$1($grip)/$2\1/" $SSHCONTROL_FILE
      return
    }

    # Parse identity_file for keygrip if it exists
    if [ -n "$identity_file" ];
    then
      keygrip=$(find_keygrip "$identity_file")
      if [ "$?" -ne "0" ];
      then
        echo "Error occurred while parsing keygrip" 1>&2
        exit 1
      fi
    fi

    # Process command
    if [ "$command" = "disable" ];
    then
      sshctrl "" "!" "$keygrip"
      result=$?
    elif [ "$command" = "enable" ];
    then
      sshctrl "!" "" "$keygrip"
      result=$?
    else
      usage
    fi

    # Process result status code for error
    if [ "$result" -ne "0" ];
    then
      echo "Error occurred while running $command sshcontrol." 1>&2
      ukg=$keygrip
      if [ -z "$ukg" ];
      then
        ukg="N/A"
      fi
      echo "Keygrip used: $ukg" 1>&2
      exit 1
    fi

    # Output result
    if [ -z "$keygrip" ];
    then
      echo "All keys in $SSHCONTROL_FILE $command""d."
    else
      echo "Identity file $identity_file (keygrip: $keygrip) $command""d."
    fi
    exit
  '';
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

  home.packages = lib.mkAfter [ gpgsshctl ];

}

