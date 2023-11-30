#!/bin/sh

#  build-universal-framework.sh
#  verify
#
#  Created by Jamy Bailly on 29/11/2023.
#  

# create folder where we place built frameworks
rm -r derived_data
rm -r build
mkdir build
# build framework for simulators
xcodebuild clean build \
  -project verify.xcodeproj \
  -scheme verify \
  -configuration Release \
  -sdk iphonesimulator \
  -derivedDataPath derived_data
# create folder to store compiled framework for simulator
mkdir build/simulator
# copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphonesimulator/verify.framework build/simulator
#build framework for devices
xcodebuild clean build \
  -project verify.xcodeproj \
  -scheme verify \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath derived_data
# create folder to store compiled framework for simulator
mkdir build/devices
# copy compiled framework for simulator into our build folder
cp -r derived_data/Build/Products/Release-iphoneos/verify.framework build/devices
# create folder to store compiled universal framework
mkdir build/universal
####################### Create universal framework #############################
# copy device framework into universal folder
cp -r build/devices/verify.framework build/universal/
# create framework binary compatible with simulators and devices, and replace binary in unviersal framework
lipo -remove arm64 build/simulator/verify.framework/verify -output build/simulator/verify.framework/verify

lipo -create \
  build/simulator/verify.framework/verify \
  build/devices/verify.framework/verify \
  -output build/universal/verify.framework/verify
# copy simulator Swift public interface to universal framework
cp -r build/simulator/verify.framework/Modules/verify.swiftmodule/* build/universal/verify.framework/Modules/verify.swiftmodule
