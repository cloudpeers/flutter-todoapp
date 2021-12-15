#!/bin/sh

rm -rf build/appimage
mkdir -p build/appimage

cp -R build/linux/x64/release/bundle/ build/appimage/todoapp.AppDir
cp linux/appimage/todoapp.png build/appimage/todoapp.AppDir/
cp linux/appimage/AppRun build/appimage/todoapp.AppDir/
cp linux/appimage/todoapp.desktop build/appimage/todoapp.AppDir/

cd build/appimage
gh release download -p appimagetool-x86_64.AppImage -R AppImage/AppImageKit
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage todoapp.AppDir
