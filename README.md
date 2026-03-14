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

Full API documentation is in `api.lcdoc`.
