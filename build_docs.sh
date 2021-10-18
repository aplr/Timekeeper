#!/bin/sh

xcodebuild docbuild -scheme Timekeeper -derivedDataPath ./DerivedData -destination generic/platform=iOS

rm -rf build
mkdir build
cp -r DerivedData/Build/Products/Debug-iphoneos/Timekeeper.doccarchive ./build
