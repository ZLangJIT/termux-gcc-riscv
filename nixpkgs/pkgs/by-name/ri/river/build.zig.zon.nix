# generated by zon2nix (https://github.com/nix-community/zon2nix)

{ linkFarm, fetchzip }:

linkFarm "zig-packages" [
  {
    name = "122014eeb4600a059bdcfe1c864862f17e6d5e4237e3bb7d6818f2a5583f6f4eb843";
    path = fetchzip {
      url = "https://codeberg.org/ifreund/zig-pixman/archive/v0.1.0.tar.gz";
      hash = "sha256-Atfkiyt9v+GWry3xA2Y0Iv6AvwbZ+EHfHLmX0AUEz6Y=";
    };
  }
  {
    name = "1220714d1cc39c3abb1d9c22a0b838d847ead099cb7d9931821490483f30c022e827";
    path = fetchzip {
      url = "https://codeberg.org/ifreund/zig-wlroots/archive/v0.17.0.tar.gz";
      hash = "sha256-C1D2dBn65Z9PmDacpeYbdX574fcOyYi/BJVDUMibkPA=";
    };
  }
  {
    name = "1220840390382c88caf9b0887f6cebbba3a7d05960b8b2ee6d80567b2950b71e5017";
    path = fetchzip {
      url = "https://codeberg.org/ifreund/zig-xkbcommon/archive/v0.1.0.tar.gz";
      hash = "sha256-xilmsDGWlkfpTiGff+/nb76jx87ANdr4zqYy6rKOBMg=";
    };
  }
  {
    name = "1220b0f8f822c1625af7aae4cb3ab2c4ec1a4c0e99ef32867b2a8d88bb070b3e7f6d";
    path = fetchzip {
      url = "https://codeberg.org/ifreund/zig-wayland/archive/v0.1.0.tar.gz";
      hash = "sha256-VLEx8nRgmJZWgLNBRqrR7bZEkW0m5HTRv984HKwoIfA=";
    };
  }
]
