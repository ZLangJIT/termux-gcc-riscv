{ lib
, stdenv
, fetchurl
# for passthru.tests
, python3
, perlPackages
, haskellPackages
, luaPackages
, ocamlPackages
, testers
}:

# Note: this package is used for bootstrapping fetchurl, and thus
# cannot use fetchpatch! All mutable patches (generated by GitHub or
# cgit) that are needed here should be included directly in Nixpkgs as
# files.

let
  version = "2.6.3";
  tag = "R_${lib.replaceStrings ["."] ["_"] version}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "expat";
  inherit version;

  src = fetchurl {
    url = with finalAttrs; "https://github.com/libexpat/libexpat/releases/download/${tag}/${pname}-${version}.tar.xz";
    hash = "sha256-J02yVKaXm95arUBHY6cElWlA5GWEPyqb2e168i4sDvw=";
  };

  strictDeps = true;

  outputs = [ "out" "dev" ]; # TODO: fix referrers
  outputBin = "dev";

  enableParallelBuilding = true;

  configureFlags = lib.optional stdenv.isFreeBSD "--with-pic";

  outputMan = "dev"; # tiny page for a dev tool

  doCheck = true; # not cross;

  preCheck = ''
    patchShebangs ./run.sh ./test-driver-wrapper.sh
  '';

  # CMake files incorrectly calculate library path from dev prefix
  # https://github.com/libexpat/libexpat/issues/501
  postFixup = ''
    substituteInPlace $dev/lib/cmake/expat-${finalAttrs.version}/expat-noconfig.cmake \
      --replace "$"'{_IMPORT_PREFIX}' $out
  '';

  passthru.tests = {
    inherit python3;
    inherit (python3.pkgs) xmltodict;
    inherit (haskellPackages) hexpat;
    inherit (perlPackages) XMLSAXExpat XMLParser;
    inherit (luaPackages) luaexpat;
    inherit (ocamlPackages) ocaml_expat;
    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = with lib; {
    changelog = "https://github.com/libexpat/libexpat/blob/${tag}/expat/Changes";
    homepage = "https://libexpat.github.io/";
    description = "A stream-oriented XML parser library written in C";
    mainProgram = "xmlwf";
    platforms = platforms.all;
    license = licenses.mit; # expat version
    pkgConfigModules = [ "expat" ];
  };
})