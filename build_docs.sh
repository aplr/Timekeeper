#!/bin/sh

xcodebuild docbuild -scheme Timekeeper -derivedDataPath ./DerivedData -destination generic/platform=iOS

cp -r DerivedData/Build/Products/Debug-iphoneos/Timekeeper.doccarchive ./build
