# org.openxtalk.macosdock

A LiveCode Builder library for controlling the macOS dock icon — set and clear badge labels, and set or reset the dock icon image.

---

## Requirements

- **OpenXTalk 1.14** or greater
- macOS (uses Cocoa `NSDockTile` and `NSApplication` APIs)

---

## Installation

1. Open the **Extension Builder** in the OpenXTalk IDE.
2. Load `org.openxtalk.macosdock.lcb`.
3. Click **Test** to compile, or **Install** to make it available in your stack.

---

## Usage

```livecode
-- Show a badge
SetDockBadgeLabel "99"

-- Update the badge
SetDockBadgeLabel "5"

-- Clear the badge
ClearDockBadge

-- Set a custom dock icon (absolute path required)
SetDockIconImage "/Users/emily/myapp/icons/alert.png"

-- Restore the default dock icon
ResetDockIconImage

-- Set up a dock menu
DockMenuAddItem "prefs", "Open Preferences"
DockMenuAddItem "update", "Check for Updates"
DockMenuAddSeparator
DockMenuAddItem "quit", "Quit"
DockMenuInstall

-- Disable an item
DockMenuSetItemEnabled "update", false

-- Remove an item
DockMenuRemoveItem "quit"

-- Clear all items
DockMenuClear

-- Uninstall the dock menu
DockMenuUninstall
```

Handle the click message in your stack script:

```livecode
on dockMenuItemClicked pIdentifier
   if pIdentifier is "prefs" then
      -- open preferences
   else if pIdentifier is "update" then
      -- check for updates
   end if
end dockMenuItemClicked
```

---

## Cross-platform note

All handlers include a built-in platform guard — calling them on Windows or Linux is a safe no-op, so no additional checks are needed in your stack script.

---

## API

| Handler | Parameters | Description |
|---|---|---|
| `SetDockBadgeLabel` | `pLabel` — String | Sets the dock icon badge to the given string. Pass `""` to clear. |
| `ClearDockBadge` | — | Clears the dock icon badge. |
| `SetDockIconImage` | `pPath` — String | Sets the dock icon to an image file at the given absolute path. |
| `ResetDockIconImage` | — | Restores the dock icon to the default application icon. |
| `DockMenuInstall` | — | Installs the dock menu and registers the caller as the message target. |
| `DockMenuUninstall` | — | Uninstalls the dock menu and restores the original app delegate. |
| `DockMenuAddItem` | `pIdentifier`, `pTitle` — String | Adds an item to the dock menu. |
| `DockMenuAddSeparator` | — | Adds a separator to the dock menu. |
| `DockMenuRemoveItem` | `pIdentifier` — String | Removes an item from the dock menu. |
| `DockMenuClear` | — | Removes all items from the dock menu. |
| `DockMenuSetItemEnabled` | `pIdentifier` — String, `pEnabled` — Boolean | Enables or disables a dock menu item. |

Full API documentation is in `api.lcdoc`.
