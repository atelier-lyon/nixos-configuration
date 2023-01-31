# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  security.pam = {
 	enableEcryptfs = true;
	services = {
		login.makeHomeDir = true;
		sshd.makeHomeDir = true;
		sddm.makeHomeDir = true;
		sddm.unixAuth = false;
	}; 
  };

networking.hostName = "MKL-WS1"; # Define your hostname.
networking.nameservers = ["10.42.150.102"];

services.samba = {
    enable = true;
    securityType = "ads";
    extraConfig = 
''
 realm = ATELIER.LOCAL
 workgroup = ATELIER
 #log file = /var/log/samba/%m.log
 kerberos method = secrets and keytab
 client signing = yes
 client use spnego = yes
'';
 };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # OpenSSH
  services.openssh.enable = true;
  
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "azerty";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.makerspace = {
    isNormalUser = true;
    description = "makerspace";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      krb5
      samba4Full
      nss_ldap
      pam_ldap
      getent
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

krb5.enable = true;
krb5.libdefaults.default_realm = "ATELIER.LOCAL";
security.pam.services.systemd-user.makeHomeDir = true;

#krb5 = {
#  enable = true;
#  defaultRealm = "NAS.ATELIER.LOCAL";
#};


#krb5.realms = {
#  "NAS.ATELIER.LOCAL" = {
#    admin_server = "nas.atelier.local";
#    kdc = [
#      "nas.atelier.local"
#    ];
#  };
#};

  services.sssd.enable = true;
  
  # Setup sssd config file
  services.sssd.config = 
  ''
[sssd]
config_file_version = 2
services = nss, pam
domains = ATELIER.LOCAL
reconnection_retries = 3

[nss]
reconnection_retries = 3

[pam]
reconnection_retries = 3

[domain/ATELIER.LOCAL]
debug_level = 6
enumerate = true
auth_provider = ldap
ldap_search_base = dc=atelier, dc=local
ldap_uri = ldap://nas.atelier.local/
krb5_realm = ATELIER.LOCAL
default_shell=/bin/sh
ad_server = nas.atelier.local
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = ATELIER.LOCAL
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = atelier.local
use_fully_qualified_names = True
ldap_id_mapping = True
access_provider = ad
ad_gpo_ignore_unreadable = True
ad_gpo_access_control = permissive
ldap_default_authtok_type = password
ldap_default_authtok = RedactedSSSDPassword
ldap_default_bind_dn = dc=atelier,dc=local
'';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
