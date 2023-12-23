# nix-build -E '(import <nixpkgs> {}).callPackage ./. {}'
# nix-env -i ./result
# nix-env -q
# nix-env --uninstall

# bmkdep-f76db982a71c817423e0609ec9625e351e9e9e7d
# nix-env -q --files bmkdep-f76db982a71c817423e0609ec9625e351e9e9e7d

# nix-env -qa --installed bmkdep-f76db982a71c817423e0609ec9625e351e9e9e7d
# nix-env --uninstall bmkdep-f76db982a71c817423e0609ec9625e351e9e9e7d

# sudo nix-env -f '<nixpkgs>' -iA <package-name>

# nix-env --uninstall bmkdep-f76db982a71c817423e0609ec9625e351e9e9e7d

{ lib
, stdenv
, fetchFromGitHub
, bmake
, groff
}:

stdenv.mkDerivation rec {
  pname = "bmkdep";
  version = "f76db982a71c817423e0609ec9625e351e9e9e7d";

  src = fetchFromGitHub {
    owner  = "trociny";
    repo   = "bmkdep";
    rev    = "f76db982a71c817423e0609ec9625e351e9e9e7d";
    hash   = "sha256-dpLLYRY5lpV0jUURyvjr/Mf1JPUEnD0bm9ZJNTKb27Y=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    bmake
    groff
    stdenv
  ];
  enableParallelBuilding = true;
  enableParallelInstalling = false;

  # note: build checks value of '$CC' to add some extra cflags, but we don't
  # necessarily know which 'stdenv' someone chose, so we leave it alone (e.g.
  # if we use stdenv vs clangStdenv, we don't know which, and CC=cc in all
  # cases.) it's unclear exactly what should be done if we want those flags,
  # but the defaults work fine.
  makeFlags = [ ];


  # fix up multi-output install. we also have to fix the pkg-config libdir
  # file; it uses prefix=$out; libdir=${prefix}/lib, which is wrong in
  # our case; libdir should really be set to the $lib output.
    preConfigure = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    substituteInPlace Makefile --replace "/man/man" "/man"
    echo "out directory: $out"
    '';

    installPhase = ''
    bmake install PREFIX=$out
    '';
  
    postInstall = ''
    # Move files to $out/bin
    mv $out/bin/bmkdep $out/bin/

    # Move man page to $out/share/man/man1
    mv $out/share/man/man/bmkdep.1 $out/share/man/man1/
    '';

  meta = with lib; {
    description = "NetBSD version of mkdep";
    homepage    = "https://github.com/trociny/bmkdep";
    license     = licenses.bsd2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ someone ];
  };
}
