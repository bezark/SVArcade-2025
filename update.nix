{pkgs }:

pkgs.writeShellScriptBin "update" ''
  echo "updating"
  cd /home/SVArcade-2025
  ${pkgs.git}/bin/git pull
''
