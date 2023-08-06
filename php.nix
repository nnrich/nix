{ pkgs, lib, config, ... }:
{
  services.httpd = {
    enable = true;
    enablePHP = true;
    virtualHosts."fcovm1804.com" = {
      documentRoot = "/srv/http/skyline";
      locations."/" = { index = "index.php index.html"; };

      extraConfig = ''
        SetEnv BE_UUID "76e80709-c943-4ec4-9754-1cf259d08262"
        SetEnv jobs_uuid "69fc23a4-e4d9-4319-8ac2-c97ac500a26c"
        SetEnv jobs_pw "test"
        SetEnv api_base "https://192.168.122.26"
        Redirect permanent /rest/open/current https://192.168.122.26/rest/open/current
        Redirect permanent /rest/admin/current https://192.168.122.26/rest/admin/current
        Redirect permanent /rest/user/current https://192.168.122.26/rest/user/current
      '';
    };
  };
}
