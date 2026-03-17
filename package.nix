{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, xdotool
, libGL
, freetype
, libz
, libusb1
, e2fsprogs
, fontconfig
, libgpg-error
, cnVersion ? false
}:

let
  version = if cnVersion then "15.0.0.C159" else "15.0.0.175";
  src = if cnVersion then fetchurl {
    url = "https://driver.huion.cn/Driver/Linux/HuionTablet_LinuxDriver_v${version}.x86_64.tar.xz";
    hash = "sha256-iAcUBJxgQ5d35aROIxVJ2Dx/9nf70DBSwNYpmterpFo=";
    curlOptsList = [ "-H" "User-Agent: Mozilla/5.0" "-H" "Referer: https://www.huion.cn/" ];
  }
  else fetchurl {
    url = "https://driverdl.huion.com/driver/Linux/HuionTablet_LinuxDriver_v${version}.x86_64.tar.xz";
    hash = "sha256-iAcUBJxgQ5d35aROIxVJ2Dx/9nf70DBSwNYpmterpFo=";
    curlOptsList = [ "-H" "User-Agent: Mozilla/5.0" "-H" "Referer: https://www.huion.com/" ];
  };
in 
stdenv.mkDerivation rec {
  pname = "huion-tablet-driver";
  inherit version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    xdotool
    libGL
    freetype
    libz
    libusb1
    e2fsprogs
    fontconfig
    libgpg-error
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/huiontablet
    cp -r huiontablet/* $out/lib/huiontablet/

    chmod +x $out/lib/huiontablet/huionCore
    chmod +x $out/lib/huiontablet/huiontablet

    # udev rules
    mkdir -p $out/lib/udev/rules.d
    cp huiontablet/res/rule/20-huion.rules \
       $out/lib/udev/rules.d/

    # desktop
    mkdir -p $out/share/applications
    cat > $out/share/applications/huiontablet.desktop <<EOF
    [Desktop Entry]
    Name=HuionTablet
    Comment=Huion driver
    Exec=$out/bin/huiontablet
    Icon=huiontablet
    Terminal=false
    Type=Application
    Categories=Utility;
    StartupNotify=true
    EOF

    # icon
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp icon/huiontablet.png \
       $out/share/icons/hicolor/256x256/apps/

    mkdir -p $out/bin
    makeWrapper $out/lib/huiontablet/huiontablet.sh \
      $out/bin/huiontablet \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      --prefix PATH : ${lib.makeBinPath [ xdotool ]}

    makeWrapper $out/lib/huiontablet/huionCore.sh \
      $out/bin/huionCore \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      --prefix PATH : ${lib.makeBinPath [ xdotool ]}

    runHook postInstall
  '';

  postPatch = ''
    substituteInPlace huiontablet/huiontablet.sh \
      --replace 'dirname=`dirname $0`' "dirname=$out/lib/huiontablet"

    substituteInPlace huiontablet/huionCore.sh \
      --replace 'dirname=`dirname $0`' "dirname=$out/lib/huiontablet"
  '';

  dontFixup = false;

  meta = with lib; {
    description = "Huion tablet linux driver (repackaged for NixOS)";
    homepage = "https://www.huion.com";
    downloadPage = "https://www.huion.com/download";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "huiontablet";
  };
}
