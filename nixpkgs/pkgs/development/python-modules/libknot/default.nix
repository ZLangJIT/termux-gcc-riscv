{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  hatchling,

  # native dependencies
  knot-dns,
}:

buildPythonPackage rec {
  pname = "libknot";
  version = "3.3.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RG2NOFQC6rxeutawn3ArZy9uNLn+gPmEqrv1E0YYJx4=";
  };

  postPatch = ''
    substituteInPlace libknot/__init__.py \
      --replace "libknot%s.dylib" "${lib.getLib knot-dns}/lib/libknot%s.dylib" \
      --replace "libknot.so%s" "${lib.getLib knot-dns}/lib/libknot.so%s"
  '';

  build-system = [ hatchling ];

  pythonImportsCheck = [ "libknot" ];

  meta = with lib; {
    description = "Python bindings for libknot";
    homepage = "https://gitlab.nic.cz/knot/knot-dns/-/tree/master/python/libknot";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ hexa ];
  };
}