{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let debExtract = stdenv.mkDerivation {
  name = "beam-wallet";
  src = fetchurl {
    url = "https://builds.beam.mw/mainnet/2019.01.03/Release/linux/Beam-Wallet-1.0.3976.deb";
    sha256 = "1p2an7qqahr2b9lbpdparrlyjjrpcs1mmg8k7pg1x8ph1l4cwpxc";
  };
  phases = [ "buildPhase" ];
  buildInputs = [ dpkg ];
  buildPhase = ''
    mkdir $out
    dpkg-deb -x $src $out
    mv $out/usr/* $out
    rmdir $out/usr
  '';
};
in buildFHSUserEnv {
  name = "BeamWallet";
  targetPkgs = pkgs: with pkgs; [
    xorg.libX11
    xorg.libxcb
    libGL
    freetype
    fontconfig
    xorg.libXi
    xorg.libXrender
    cups
    stdenv.cc.cc.lib
    debExtract
  ];
  runScript = "/usr/bin/BeamWallet";
}
