{
  description = "The Virtuoso Open Source triple store and graph database";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages.virtuoso = with pkgs; stdenv.mkDerivation rec {
          name = "virtuoso-opensource-7.2.8";

          src = fetchurl {
            url = "mirror://sourceforge/virtuoso/${name}.tar.gz";
            sha256 = "sha256-l50iHR3et4mNsKkorYg4l9ndzTmIalQEL66am5tVG/o=";
          };

          buildInputs = [ libxml2 openssl readline gawk yacc flex];

          CPP = "${stdenv.cc}/bin/gcc -E";

          configureFlags = [
            "--enable-shared" "--disable-all-vads" "--with-readline=${readline.dev}"
            "--disable-hslookup" "--disable-wbxml2" "--without-iodbc"
            "--enable-openssl=${openssl.dev}"
          ];

          postInstall=''
            echo Moving documentation
            mkdir -pv $out/share/doc
            mv -v $out/share/virtuoso/doc $out/share/doc/${name}
            echo Removing jars and empty directories
            find $out -name "*.a" -delete -o -name "*.jar" -delete -o -type d -empty -delete
            '';

          meta = with stdenv.lib; {
            description = "SQL/RDF database used by, e.g., KDE-nepomuk";
            homepage = http://virtuoso.openlinksw.com/dataspace/dav/wiki/Main/;
            #configure: The current version [...] can only be built on 64bit platforms
            platforms = [ "x86_64-linux" ];
            maintainers = [ ];
          };
      };
      packages.startVirtuoso = pkgs.runCommand "startVirtuoso" {
           buildInputs = with pkgs; [ makeWrapper openjdk packages.virtuoso ];
      } ''
         mkdir -p $out/bin
         cp ${./start-virtuoso.sh} $out/bin/startVirtuoso
         wrapProgram "$out/bin/startVirtuoso" \
             --prefix PATH : $PATH
       '';
      packages.bulkImport = pkgs.runCommand "bulkImport" {
           buildInputs = with pkgs; [ makeWrapper openjdk packages.virtuoso ];
      } ''
         mkdir -p $out/bin
         cp ${./bulk-import.sh} $out/bin/bulkImport
         wrapProgram "$out/bin/bulkImport" \
             --prefix PATH : $PATH
       '';

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ openjdk yacc flex];
      };

      defaultPackage = packages.virtuoso;
  });
}
