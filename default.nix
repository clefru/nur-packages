self: pkgs: {
  beam = pkgs.callPackage ./pkgs/beam {};
  grin = pkgs.callPackage ./pkgs/grin/grin.nix {};
  grin-miner = pkgs.callPackage ./pkgs/grin/grin-miner.nix {};
  linux-sgx = pkgs.callPackage ./pkgs/linux-sgx {};
  rnnoise = pkgs.callPackage ./pkgs/rnnoise {};
  noise-suppression-for-voice = pkgs.callPackage ./pkgs/noise-suppression-for-voice {};
}
