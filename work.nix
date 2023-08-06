{ pkgs, config, ... }: {
  networking.hostName = "rdc-work"; # Define your hostname.
  networking.extraHosts = ''
    127.0.0.1 fcovm1804.com
  '';

  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  services.openvpn.servers = {
    workVPN = { config = "config /home/rcook/Documents/vpn/work.conf "; };
  };
  services.nfs.server = {
    enable = true;
    exports = ''
      /export		10.157.208.1/20(rw,fsid=1,insecure,no_subtree_check,async,no_root_squash)
      /export/fco	10.157.208.1/20(rw,fsid=1,insecure,no_subtree_check,async,no_root_squash)
    '';
  };
}
