#!/bin/bash
# Build macosdock_glue.dylib and install it into the LCB extension folder.
# Run from the directory containing LCMacOSDock.m
# Usage: ./build_glue.sh /path/to/org.openxtalk.macosdock

set -e

EXTENSION_DIR="${1:-.}"

echo "Building arm64..."
clang -x objective-c -dynamiclib -framework Cocoa \
  -arch arm64 \
  -fobjc-arc \
  -undefined dynamic_lookup \
  -o macosdock_glue_arm64.dylib LCMacOSDock.m

echo "Building x86_64..."
clang -x objective-c -dynamiclib -framework Cocoa \
  -arch x86_64 \
  -fobjc-arc \
  -undefined dynamic_lookup \
  -o macosdock_glue_x86_64.dylib LCMacOSDock.m

echo "Creating universal binary..."
lipo -create macosdock_glue_arm64.dylib macosdock_glue_x86_64.dylib \
  -output macosdock_glue.dylib

echo "Installing..."
mkdir -p "$EXTENSION_DIR/code/x86_64-mac"
mkdir -p "$EXTENSION_DIR/code/arm64-mac"
cp macosdock_glue.dylib "$EXTENSION_DIR/code/x86_64-mac/macosdock_glue.dylib"
cp macosdock_glue.dylib "$EXTENSION_DIR/code/arm64-mac/macosdock_glue.dylib"

rm macosdock_glue_arm64.dylib macosdock_glue_x86_64.dylib

echo "Done! Dylib installed to:"
echo "  $EXTENSION_DIR/code/x86_64-mac/macosdock_glue.dylib"
echo "  $EXTENSION_DIR/code/arm64-mac/macosdock_glue.dylib"
