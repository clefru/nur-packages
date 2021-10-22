{ pkgs ? import <nixpkgs> {} }:
with pkgs;

stdenv.mkDerivation rec {
  version = "10.10.2s";
  pname = "ib-tws";

  src = fetchurl {
    url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
    sha256 = "0njxam1rhmxs6hca5k04fbv2xibdhrhn4gc15fzp2vzjhqi4w3wj";
    executable = true;
  };

  # Only build locally for license reasons.
  preferLocalBuild = true;

  phases = [ "installPhase" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    # We use an installer FHS environment because the shell script unpacks
    # a binary, and immediately calls that binary. There is little hope
    # for us to patchelf ld-linux in between. An FHS env is easier.
    ${buildFHSUserEnv { name = "fhs"; }}/bin/fhs ${src} -q -dir $out/libexec

    # The following disables the JRE compatability check inside the tws script
    # so that we can use Oracle JRE pkgs of nixpkgs.
    sed -i 's#test_jvm "$INSTALL4J_JAVA_HOME_OVERRIDE"#app_java_home="$INSTALL4J_JAVA_HOME_OVERRIDE"#' $out/libexec/tws

    # Make the tws launcher script read $HOME/.tws/tws.vmoptions
    # instead of the unmutable version in $out.
    sed -i -e 's#read_vmoptions "$prg_dir/$progname.vmoptions"#read_vmoptions "$HOME/.tws/$progname.vmoptions"#' $out/libexec/tws

    # We set a bunch of flags found in the Arch PKGBUILD. The flags
    # releated to AA fonts seem to make a positive difference.
    # -Dawt.useSystemAAFontSettings=lcd or -Dawt.useSystemAAFontSettings=on
    # -Dsun.java2d.xrender=True not applied. Results in WARNING: The version of libXrender.so cannot be detected.
    # -Dsun.java2d.opengl=False not applied. Why would I disable that?
    # -Dswing.aatext=true applied
    mkdir $out/bin
    sed -e s#__OUT__#$out# -e s#__JAVAHOME__#${pkgs.oraclejre8.home}# ${./tws-wrap.sh} > $out/bin/ib-tws
    chmod a+rx $out/bin/ib-tws

    # FIXME Fixup .desktop starter.
  '';

  meta = with lib; {
    description = "Trader Work Station of Interactive Brokers";
    homepage = "https://www.interactivebrokers.com";
    license = licenses.unfree;
    maintainers = [ maintainers.clefru ];
    platforms = platforms.linux;
  };
}
