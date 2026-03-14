/*
 * LCMacOSDock.m
 *
 * Plain C glue layer over the macOS Cocoa dock APIs so LCB can bind via
 * c: foreign handlers rather than objc: directly.
 *
 * Build (via build_glue.sh):
 *   clang -x objective-c -fobjc-arc -dynamiclib -framework Cocoa \
 *         -arch arm64  -o macosdock_glue_arm64.dylib  LCMacOSDock.m
 *   clang -x objective-c -fobjc-arc -dynamiclib -framework Cocoa \
 *         -arch x86_64 -o macosdock_glue_x86_64.dylib LCMacOSDock.m
 *   lipo -create macosdock_glue_arm64.dylib macosdock_glue_x86_64.dylib \
 *        -output macosdock_glue.dylib
 */

#import <Cocoa/Cocoa.h>
#import "LCMacOSDock.h"

// ---------------------------------------------------------------------------
// Badge
// ---------------------------------------------------------------------------

void LCDockSetBadgeLabel(const char *label) {
    NSString *str = label ? [NSString stringWithUTF8String:label] : @"";
    [[NSApplication sharedApplication].dockTile setBadgeLabel:str];
}

// ---------------------------------------------------------------------------
// Icon image
// ---------------------------------------------------------------------------

void LCDockSetIconImageFile(const char *filePath) {
    if (!filePath) return;
    NSString *path = [NSString stringWithUTF8String:filePath];
    NSImage  *img  = [[NSImage alloc] initWithContentsOfFile:path];
    if (!img) return;
    [NSApplication sharedApplication].applicationIconImage = img;
}

void LCDockResetIconImage(void) {
    [NSApplication sharedApplication].applicationIconImage =
        [NSImage imageNamed:NSImageNameApplicationIcon];
}
