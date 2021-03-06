{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc801" }: let
  inherit (nixpkgs) pkgs;
  ghc = pkgs.haskell.packages.${compiler}.ghcWithPackages(ps: [
    ps.hdevtools ps.doctest ps.hspec-discover ps.hlint ps.ghc-mod
  ]);
  cabal-install = pkgs.haskell.packages.${compiler}.cabal-install;
  pkg = import ./default.nix { inherit nixpkgs compiler; };
  npm = import ./npm {};
in
  pkgs.stdenv.mkDerivation rec {
    name = pkg.pname;
    buildInputs = [ ghc cabal-install npm.nodePackages.ldapjs ] ++ pkg.env.buildInputs;
    shellHook = ''
      ${pkg.env.shellHook}
      cabal configure --enable-tests --package-db=$NIX_GHC_LIBDIR/package.conf.d
    '';
  }
