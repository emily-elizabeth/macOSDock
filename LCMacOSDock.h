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

#ifdef __cplusplus
}
#endif

#endif
