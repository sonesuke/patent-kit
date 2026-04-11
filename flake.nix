{
  description = "Patent-Kit dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "chromium" ];
          };

          devPackages = with pkgs; [
            bashInteractive
            zsh
            zsh-completions
            zsh-autosuggestions
            zsh-syntax-highlighting
            coreutils
            findutils
            gnugrep
            gnutar
            gzip
            gnused
            curl
            gitMinimal
            gh
            cacert
            ripgrep
            unzip
            jq
            vim
            nodejs_22
            sqlite
            chromium
            python3
          ];
        in
        {
          default = pkgs.dockerTools.buildLayeredImage {
            name = "patent-kit";
            tag = "latest";
            contents = pkgs.buildEnv {
              name = "image-root";
              paths = devPackages;
              pathsToLink = [ "/bin" "/etc" "/lib" "/share" ];
            };
            fakeRootCommands = ''
              mkdir -p ./home/user/.config ./workspaces ./tmp ./lib
              chmod 1777 ./tmp
              echo "user:x:1000:1000::/home/user:/bin/zsh" >> ./etc/passwd
              echo "user:x:1000:" >> ./etc/group
              chown -R 1000:1000 ./home/user
              chmod 755 ./home/user
              mkdir -p ./usr/bin
              ln -sf /bin/env ./usr/bin/env
              for f in ${pkgs.glibc}/lib/ld-linux*.so*; do
                ln -sf "$f" ./lib/$(basename "$f")
              done
            '';
            config = {
              Env = [
                "LANG=C.UTF-8"
                "LANGUAGE=C.UTF-8"
                "LC_ALL=C.UTF-8"
                "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
                "HOME=/home/user"
              ];
              User = "1000:1000";
              Cmd = [ "/bin/zsh" ];
            };
          };
        }
      );
    };
}
