{ pkgs }:

pkgs.writeShellScriptBin "sshtunnel" ''
  port=$1
  dest=$2
  ${pkgs.procps}/bin/pkill -f "${pkgs.openssh}/bin/ssh -L 127.0.0.1:$port:127.0.0.1:$port"
  ${pkgs.openssh}/bin/ssh -L 127.0.0.1:$port:127.0.0.1:$port -N $dest &
''
