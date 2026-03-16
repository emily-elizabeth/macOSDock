#ifndef LC_MACOS_DOCK_H
#define LC_MACOS_DOCK_H

#ifdef __cplusplus
extern "C" {
#endif

// Badge
void  LCDockSetBadgeLabel(const char *label);

// Icon image
void  LCDockSetIconImageFile(const char *filePath);
void  LCDockResetIconImage(void);

// Dock menu — item click callback
typedef void (*LCDockMenuClickCallback)(const char *itemIdentifier);
void  LCDockMenuSetClickCallback(LCDockMenuClickCallback cb);
void  LCDockMenuClearClickCallback(void);

// Dock menu — item management
void  LCDockMenuAddItem(const char *identifier, const char *title);
void  LCDockMenuAddSeparator(void);
void  LCDockMenuRemoveItem(const char *identifier);
void  LCDockMenuClear(void);
void  LCDockMenuSetItemEnabled(const char *identifier, int enabled);

// Dock menu — install / uninstall
void  LCDockMenuInstall(void);
void  LCDockMenuUninstall(void);

#ifdef __cplusplus
}
#endif

#endif
