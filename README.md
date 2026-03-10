# community.livecode.macos.dockbadge

A LiveCode Builder library for setting and clearing the macOS dock icon badge label.

---

## Requirements

- **OpenXTalk 1.14** or greater
- macOS (uses Cocoa `NSDockTile` API — not available on other platforms)

---

## Installation

1. Open the **Extension Builder** in the OpenXTalk IDE.
2. Load `dockbadge.lcb`.
3. Click **Test** to compile, or **Install** to make it available in your stack.

---

## Usage

Once the extension is installed, call the handlers from any LiveCode Script:

```livecode
-- Show a badge with a number
SetDockBadgeLabel "99"

-- Update the badge
SetDockBadgeLabel "5"

-- Clear the badge
ClearDockBadge
```

To clear the badge you can also pass an empty string:

```livecode
SetDockBadgeLabel ""
```

---

## Cross-platform note

This library is macOS-only, but the handlers include a built-in platform guard — calling `SetDockBadgeLabel` or `ClearDockBadge` on Windows or Linux is a safe no-op, so no additional checks are needed in your stack script.

## API

| Handler | Parameters | Description |
|---|---|---|
| `SetDockBadgeLabel` | `pLabel` — String | Sets the dock icon badge to the given string. Pass `""` to clear. |
| `ClearDockBadge` | — | Clears the dock icon badge. |

Full API documentation is in `api.lcdoc`.
