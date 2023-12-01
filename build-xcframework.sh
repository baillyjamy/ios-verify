#!/bin/sh

#  build-xcframework.sh
#  verify
#
#  Created by Jamy Bailly on 01/12/2023.
#  

# create folder where we place built frameworks
rm -r build
mkdir build

# build framework for simulators
xcodebuild clean archive \
  -project verify.xcodeproj \
  -archivePath "./build/ios_sim.xcarchive" \
  -scheme verify \
  -configuration Release \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO

#build framework for devices
xcodebuild clean archive \
  -project verify.xcodeproj \
  -archivePath "./build/ios.xcarchive" \
  -scheme verify \
  -configuration Release \
  -sdk iphoneos \
  SKIP_INSTALL=NO

#build framework for macos
xcodebuild clean archive \
  -project verify.xcodeproj \
  -archivePath "./build/macos.xcarchive" \
  -scheme verify \
  -configuration Release \
  SKIP_INSTALL=NO

#build xcframework
xcodebuild -create-xcframework \
  -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/verify.framework" \
  -framework "./build/ios.xcarchive/Products/Library/Frameworks/verify.framework" \
  -framework "./build/macos.xcarchive/Products/Library/Frameworks/verify.framework" \
  -output "./build/verify.xcframework"
