/*
 * LCMacOSDock.m
 *
 * Plain C glue layer over the macOS Cocoa dock APIs so LCB can bind via
 * c: foreign handlers rather than objc: directly.
 *
 * The dock menu is implemented via a dedicated NSApplicationDelegate subclass
 * (LCDockDelegate) that responds only to applicationDockMenu:. To avoid
 * stomping on OpenXTalk's existing app delegate, LCDockDelegate is stored
 * separately and only installed/uninstalled on demand. All other delegate
 * responsibilities remain with the original delegate.
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

// ---------------------------------------------------------------------------
// Dock menu — click callback
// ---------------------------------------------------------------------------

static LCDockMenuClickCallback sDockMenuClickCallback = NULL;

void LCDockMenuSetClickCallback(LCDockMenuClickCallback cb) {
    sDockMenuClickCallback = cb;
}

void LCDockMenuClearClickCallback(void) {
    sDockMenuClickCallback = NULL;
}

// ---------------------------------------------------------------------------
// Dock menu — item registry
// Each item is stored as { "title": NSString, "enabled": NSNumber }
// keyed by its identifier string, in insertion order via an NSMutableArray.
// ---------------------------------------------------------------------------

static NSMutableArray<NSString *>            *sMenuOrder  = nil;
static NSMutableDictionary<NSString *, NSDictionary *> *sMenuItems = nil;

static void ensureMenuRegistry(void) {
    if (!sMenuOrder)  sMenuOrder  = [NSMutableArray array];
    if (!sMenuItems)  sMenuItems  = [NSMutableDictionary dictionary];
}

void LCDockMenuAddItem(const char *identifier, const char *title) {
    if (!identifier || !title) return;
    ensureMenuRegistry();
    NSString *ident = [NSString stringWithUTF8String:identifier];
    NSString *label = [NSString stringWithUTF8String:title];
    if (![sMenuOrder containsObject:ident])
        [sMenuOrder addObject:ident];
    sMenuItems[ident] = @{ @"title": label, @"enabled": @YES, @"separator": @NO };
}

void LCDockMenuAddSeparator(void) {
    ensureMenuRegistry();
    // Use a unique key for each separator so multiple separators are supported
    NSString *ident = [NSString stringWithFormat:@"__sep_%lu", (unsigned long)sMenuOrder.count];
    [sMenuOrder addObject:ident];
    sMenuItems[ident] = @{ @"title": @"", @"enabled": @NO, @"separator": @YES };
}

void LCDockMenuRemoveItem(const char *identifier) {
    if (!identifier) return;
    ensureMenuRegistry();
    NSString *ident = [NSString stringWithUTF8String:identifier];
    [sMenuOrder removeObject:ident];
    [sMenuItems removeObjectForKey:ident];
}

void LCDockMenuClear(void) {
    ensureMenuRegistry();
    [sMenuOrder  removeAllObjects];
    [sMenuItems  removeAllObjects];
}

void LCDockMenuSetItemEnabled(const char *identifier, int enabled) {
    if (!identifier) return;
    ensureMenuRegistry();
    NSString *ident = [NSString stringWithUTF8String:identifier];
    NSDictionary *existing = sMenuItems[ident];
    if (!existing) return;
    sMenuItems[ident] = @{
        @"title":     existing[@"title"],
        @"enabled":   enabled ? @YES : @NO,
        @"separator": existing[@"separator"]
    };
}

// ---------------------------------------------------------------------------
// Dock menu delegate
// Responds only to applicationDockMenu: — all other delegate calls are
// forwarded to the original app delegate via message forwarding.
// ---------------------------------------------------------------------------

@interface LCDockDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, weak) id<NSApplicationDelegate> originalDelegate;
@end

@implementation LCDockDelegate

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    ensureMenuRegistry();
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    menu.autoenablesItems = NO;
    for (NSString *ident in sMenuOrder) {
        NSDictionary *meta = sMenuItems[ident];
        if (!meta) continue;
        if ([meta[@"separator"] boolValue]) {
            [menu addItem:[NSMenuItem separatorItem]];
        } else {
            NSMenuItem *item = [[NSMenuItem alloc]
                initWithTitle:meta[@"title"]
                       action:@selector(dockMenuItemClicked:)
                keyEquivalent:@""];
            item.representedObject = ident;
            item.target            = self;
            item.enabled           = [meta[@"enabled"] boolValue];
            [menu addItem:item];
        }
    }
    return menu;
}

- (void)dockMenuItemClicked:(NSMenuItem *)sender {
    NSString *ident = sender.representedObject;
    if (!ident || !sDockMenuClickCallback) return;
    LCDockMenuClickCallback cb = sDockMenuClickCallback;
    char *identCopy = strdup([ident UTF8String]);
    dispatch_async(dispatch_get_main_queue(), ^{
        cb(identCopy);
        free(identCopy);
    });
}

// Forward all other delegate messages to the original delegate
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) return YES;
    return [self.originalDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.originalDelegate respondsToSelector:aSelector])
        return self.originalDelegate;
    return nil;
}

@end

// ---------------------------------------------------------------------------
// Dock menu — install / uninstall
// ---------------------------------------------------------------------------

static LCDockDelegate *sDockDelegate = nil;

void LCDockMenuInstall(void) {
    if (sDockDelegate) return; // already installed
    sDockDelegate = [[LCDockDelegate alloc] init];
    NSApplication *app = [NSApplication sharedApplication];
    sDockDelegate.originalDelegate = app.delegate;
    app.delegate = sDockDelegate;
}

void LCDockMenuUninstall(void) {
    if (!sDockDelegate) return;
    NSApplication *app = [NSApplication sharedApplication];
    // Restore original delegate only if we're still the active one
    if (app.delegate == sDockDelegate)
        app.delegate = sDockDelegate.originalDelegate;
    sDockDelegate = nil;
}
