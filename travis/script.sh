#!/bin/sh
set -e
xctool -workspace BeamMusicPlayerExample.xcworkspace -scheme BeamMusicPlayerExample -sdk iphonesimulator clean build test
./travis/appledoc.sh
pod spec lint
