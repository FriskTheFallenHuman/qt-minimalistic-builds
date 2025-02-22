Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Call Visual Studio Dev Tools
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1'

$version_base = "6.5"
$version = "6.5.4"

$base_folder = $pwd.Path
$qt_sources_url = "https://download.qt.io/official_releases/qt/" + $version_base + "/" + $version + "/src/single/qt-everywhere-opensource-src-" + $version + ".zip"
$qt_archive_file = $pwd.Path + "\qt-" + $version + ".zip"
$qt_src_base_folder = $pwd.Path + "\qt-everywhere-src-" + $version

$tools_folder = $pwd.Path + "\tools\"
$type = "static"
$prefix_base_folder = "qt-" + $version + "-" + $type + "-msvc2022-x86_64"
$prefix_folder = $pwd.Path + "\" + $prefix_base_folder
$build_folder = $pwd.Path + "\bld"

# Download Qt sources, unpack.
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12,Tls13'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

if (!(Test-Path -Path $qt_archive_file -PathType Leaf)) {
    try { Invoke-WebRequest -Uri $qt_sources_url -OutFile $qt_archive_file } catch { Write-Host "Failed to download the file. Error: $_" }
}

if (!(Test-Path -Path $qt_src_base_folder)) {& "$tools_folder\7za.exe" x $qt_archive_file}

# Configure.
if (!(Test-Path -Path $build_folder)) {New-Item -Path $build_folder -ItemType Directory}
cd $build_folder
pushd $build_folder

& "$qt_src_base_folder\configure.bat" -debug-and-release -opensource -confirm-license -opengl desktop -no-dbus -no-icu -no-fontconfig -nomake examples -nomake tests -skip qt3d -skip qtactiveqt -skip qtcanvas3d -skip qtconnectivity -skip qtdatavis3d -skip qtdoc -skip qtgamepad -skip qtlocation -skip qtnetworkauth -skip qtpurchasing -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtspeech -skip qtvirtualkeyboard -skip qtwebview -skip qtwebengine -skip qtscript -skip qtquicktimeline -skip qtopcua -skip qtcoap -skip qtcharts -skip qthttpserver -skip qtwayland -skip qtwebchannel -skip qtlanguageserver -skip qtmqtt -skip qtsvg -no-feature-assistant -no-feature-designer -no-feature-qtwebengine-build -qt-zlib -static -static-runtime -ltcg -prefix $prefix_folder --

# Compile.
cmake --build . --parallel 10
cmake --install . --config Release
cmake --install . --config Debug

# Return to our working directory
popd

# Create final archive.
& "$tools_folder\7za.exe" a -t7z "${prefix_base_folder}.7z" "$prefix_folder" -mmt -mx9
