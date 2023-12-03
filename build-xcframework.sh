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
  -archivePath "./build/ios_sim.xcarchive" \
  -scheme verify \
  -sdk iphonesimulator \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

#build framework for devices
xcodebuild clean archive \
  -archivePath "./build/ios.xcarchive" \
  -scheme verify \
  -sdk iphoneos \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

#build framework for macos
xcodebuild clean archive \
  -archivePath "./build/macos.xcarchive" \
  -scheme verify \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

#build xcframework
xcodebuild -create-xcframework \
  -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/SynapsVerify.framework" \
  -framework "./build/ios.xcarchive/Products/Library/Frameworks/SynapsVerify.framework" \
  -framework "./build/macos.xcarchive/Products/Library/Frameworks/SynapsVerify.framework" \
  -output "./build/SynapsVerify.xcframework"
