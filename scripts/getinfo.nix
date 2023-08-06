{ pkgs }:

pkgs.writeShellScriptBin "getinfo" ''
  ${pkgs.openssh}/bin/ssh root@$1 cat /etc/extility/config/vars.tsv | grep 'API_JADE_DB_PASSWORD\|XVP_DB_PASSWORD\|TL_DB_PASSWORD\|MBE_UUID\|JOB_ADMIN_PASSWORD\|JOB_ADMIN_UUID'
''
