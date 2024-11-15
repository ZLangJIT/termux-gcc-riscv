{
  lib,
  addonDir,
  buildKodiAddon,
  fetchFromGitHub,
  kodi,
  requests,
  dateutil,
  six,
  kodi-six,
  signals,
  websocket,
}:
let
  python = kodi.pythonPackages.python.withPackages (p: with p; [ pyyaml ]);
in
buildKodiAddon rec {
  pname = "jellyfin";
  namespace = "plugin.video.jellyfin";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-kodi";
    rev = "v${version}";
    sha256 = "sha256-N5ZNGeLf3P4p3RQimSaZteddKjqXE274mWpo7W9xqPs=";
  };

  nativeBuildInputs = [ python ];

  # ZIP does not support timestamps before 1980 - https://bugs.python.org/issue34097
  patches = [ ./no-strict-zip-timestamp.patch ];

  buildPhase = ''
    ${python}/bin/python3 build.py --version=py3
  '';

  postInstall = ''
    mv /build/source/addon.xml $out${addonDir}/${namespace}/
  '';

  propagatedBuildInputs = [
    requests
    dateutil
    six
    kodi-six
    signals
    websocket
  ];

  meta = with lib; {
    homepage = "https://jellyfin.org/";
    description = "A whole new way to manage and view your media library";
    license = licenses.gpl3Only;
    maintainers = teams.kodi.members;
  };
}
