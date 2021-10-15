#!/bin/sh

jazzy \
    --clean \
    --output build \
    --author "Andreas Pfurtscheller" \
    --author-url "https://github.com/aplr" \
    --module "Timekeeper" \
    --theme "fullwidth" \
    --github-url "https://github.com/aplr/Timekeeper" \
    --swift-build-tool "spm" \
    --exclude "/*/Internal*" \
    --sdk "iphonesimulator" \
    --build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5,-Xswiftc,-sdk,-Xswiftc,`xcrun --sdk iphonesimulator --show-sdk-path`,-Xswiftc,-target,-Xswiftc,x86_64-apple-ios15.0-simulator