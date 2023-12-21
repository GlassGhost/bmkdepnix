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
  enableParallelBuilding = false;
  enableParallelInstalling = false;

  # note: build checks value of '$CC' to add some extra cflags, but we don't
  # necessarily know which 'stdenv' someone chose, so we leave it alone (e.g.
  # if we use stdenv vs clangStdenv, we don't know which, and CC=cc in all
  # cases.) it's unclear exactly what should be done if we want those flags,
  # but the defaults work fine.
  makeFlags = [ "-r" "PREFIX=$(out)" ];

  # fix up multi-output install. we also have to fix the pkg-config libdir
  # file; it uses prefix=$out; libdir=${prefix}/lib, which is wrong in
  # our case; libdir should really be set to the $lib output.
  postInstall = ''
    # Create necessary directories
    mkdir -p $out/usr/local/bin
    mkdir -p $out/usr/local/man/man1

    # Move files to /usr/local/bin
    mv $out/bin/example-executable $out/usr/local/bin/

    # Move man page to /usr/local/man/man1
    mv $out/share/man/man1/example-man-page.1 $out/usr/local/man/man1/
  '';

  outputs = [ "out" "lib" "dev" ];

  meta = with lib; {
    description = "NetBSD version of mkdep";
    homepage    = "https://github.com/trociny/bmkdep";
    license     = licenses.bsd2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ someone ];
  };
}
