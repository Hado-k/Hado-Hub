<div align="center">

# 💜 HadoUI

**A premium, modern purple UI framework for Roblox scripts — by Hado**

`v2.0.0` · Single file · Drop into any script · [Discord](https://discord.gg/x2RtUZb6d9)

</div>

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Window](#window)
- [Tabs](#tabs)
- [Elements](#elements)
  - [Section](#section) · [Label](#label) · [Paragraph](#paragraph) · [Divider](#divider)
  - [Button](#button) · [Toggle](#toggle) · [Slider](#slider)
  - [Dropdown](#dropdown) · [Multi Dropdown](#multi-dropdown)
  - [Keybind](#keybind) · [Color Picker](#color-picker) · [Input](#input)
  - [Discord Card](#discord-card)
- [Locked Elements](#locked-elements)
- [Notifications](#notifications)
- [Dialogs](#dialogs)
- [Topbar Tags](#topbar-tags)
- [Icons](#icons)
- [Themes](#themes)
- [Flags & Configs](#flags--configs)
- [Settings Tab](#settings-tab)
- [Window Controls](#window-controls)
- [Files & Folders](#files--folders)
- [FAQ](#faq)

---

## Features

- 🎨 **Premium purple design** — gradients, rounded corners, smooth animations everywhere
- 🖼️ **Lucide icons** on tabs, notifications, dialogs, and buttons (auto-loaded, text fallback)
- 🪟 **Full window system** — drag, resize from every border, minimize, hide/reopen pill, remembers position & size
- 📐 **Auto DPI scaling** — UI sizes itself to the screen resolution (1080p = 100%, 4K = 200%)
- 📱 **Mobile ready** — full touch support, auto-fit sizing, larger grab zones, tap-to-reopen
- 🔔 **Notification system** — Success / Warning / Error / Information, custom icons, close button
- 💬 **Dialog popups** — confirmation dialogs with custom buttons
- 🔒 **Lockable elements** — grey out premium features with a lock overlay
- 🔍 **Searchable dropdowns** — search box appears automatically on long lists
- 👥 **Live Discord card** — real member/online counts + server icon from the Discord API
- 💾 **Config system** — save/load named configs, auto-persisted UI preferences
- 🌈 **5 themes** + custom accent color, all switchable at runtime

---

## Installation

**Option A — loadstring from GitHub** *(recommended)*. Loads the latest version straight from the repo:

```lua
local HadoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hado-k/Hado-Hub/main/HadoUI.lua"))()
```

Or run the ready-made hub in one line:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Hado-k/Hado-Hub/main/Hado.lua"))()
```

**Option B — load from your executor workspace.** Put `HadoUI.lua` in your executor's `workspace/HadoUI/` folder:

```lua
local HadoUI = loadstring(readfile("HadoUI/HadoUI.lua"))()
```

**Option C — paste it in.** Put the entire contents of `HadoUI.lua` at the top of your script. It returns the library and also sets `getgenv().HadoUI`.

> **Custom logo:** put a square `icon.png` inside the executor's `HadoUI/` workspace folder and it is picked up automatically, or pass `Icon = "rbxassetid://ID"` to `CreateWindow`.

> **`Hado.lua`** is a ready-made hub built on the library (Main / Player / Visuals / Settings tabs, live Discord card, working ESP). Run `HadoUI.lua` first, then `Hado.lua` — edit it to build your own hub.

---

## Quick Start

```lua
local HadoUI = loadstring(readfile("HadoUI/HadoUI.lua"))()

local Window = HadoUI:CreateWindow({
    Name       = "My Script",
    Version    = "v1.0",
    Author     = "Hado",
    Discord    = "https://discord.gg/x2RtUZb6d9",
    ConfigName = "MyScript",
    ToggleKey  = Enum.KeyCode.RightShift,
})

local Main = Window:AddTab({ Name = "Main", Icon = "house" })

Main:AddSection("Farming")
Main:AddToggle({
    Name = "Auto Farm", Flag = "AutoFarm",
    Callback = function(state) print("Auto farm:", state) end,
})

Window:AddSettingsTab()   -- full Settings page in one line

HadoUI:Notify({ Title = "Loaded", Content = "Welcome!", Type = "Success" })
```

---

## Window

```lua
local Window = HadoUI:CreateWindow({
    Name       = "My Script",               -- top bar title
    Version    = "v1.0",                    -- version chip next to the title
    Author     = "Hado",                    -- "by <Author>" under the title
    Discord    = "https://discord.gg/...",  -- copied by the Discord button
    Icon       = nil,                       -- "rbxassetid://ID" (optional, see Installation)
    ConfigName = "MyScript",                -- file prefix for configs & UI state
    ToggleKey  = Enum.KeyCode.RightShift,   -- key that shows/hides the window
})
```

The window ships with:

| Built-in | Description |
|---|---|
| Top bar | Logo, title, version chip, author, status dot, live **FPS/ping**, Discord button, minimize, close |
| Sidebar | Icon tabs with a sliding selection pill + **profile card** (your avatar & username) |
| Loader | Branded loading screen with glow + progress bar before the UI opens |
| Open pill | Draggable floating **"Open <Name>"** button whenever the window is hidden |
| Persistence | Position, size, scale, and DPI setting survive between sessions |

### Window methods

| Method | Description |
|---|---|
| `Window:AddTab(nameOrTable)` | Create a tab — `AddTab("Main")` or `AddTab({ Name = "Main", Icon = "house" })` |
| `Window:AddSettingsTab()` | Prebuilt Settings page (scale, DPI, transparency, blur, theme, accent, configs) |
| `Window:Dialog(options)` | Popup dialog — see [Dialogs](#dialogs) |
| `Window:Tag(options)` | Top bar chip — see [Topbar Tags](#topbar-tags) |
| `Window:Show()` / `Window:Hide()` / `Window:Toggle()` | Control visibility (also bound to `ToggleKey`) |
| `Window:Minimize(state?)` | Collapse to the top bar / restore |
| `Window:SetTheme(name)` | Switch theme — see [Themes](#themes) |
| `Window:SetAccent(color3)` | Change the accent color live |
| `Window:SetScale(multiplier)` | User scale multiplier (0.6 – 1.4) |
| `Window:SetTransparency(0-0.6)` | Window background transparency |
| `Window:SaveConfig(name)` / `Window:LoadConfig(name)` / `Window:ResetConfig()` | Config system — see [Flags & Configs](#flags--configs) |
| `Window:Destroy()` | Remove the window entirely |

---

## Tabs

```lua
local Tab = Window:AddTab({ Name = "Player", Icon = "user" })
```

- `Icon` is optional — any [lucide icon name](https://lucide.dev/icons) (`"house"`, `"user"`, `"eye"`, `"swords"`, `"settings"`, ...) or `"rbxassetid://ID"`.
- The active tab is highlighted by a sliding pill; the icon tints purple.
- `Tab.Select()` switches to the tab programmatically.

---

## Elements

Every element accepts `Name`, most accept `Description` (grey helper text on a second line), `Flag` (for configs), and `Locked` / `LockedTitle`.

### Section

```lua
Tab:AddSection("Farming")             -- accent dot + uppercase label + line
```
Returns `{ SetText }`.

### Label

```lua
local lbl = Tab:AddLabel("Small grey hint text")
lbl:SetText("Updated text")
```

### Paragraph

```lua
local par = Tab:AddParagraph({ Title = "Info", Content = "Longer text.\nSupports RichText." })
par:SetTitle("New title") ; par:SetContent("New content")
```

### Divider

```lua
Tab:AddDivider()
```

### Button

```lua
Tab:AddButton({
    Name        = "Kill All",
    Description = "Optional helper text",   -- optional
    ButtonText  = "Execute",                -- chip label, default "Execute"
    Callback    = function() end,
})
```
Returns `{ Fire, Lock, Unlock }`. The whole row is clickable.

### Toggle

```lua
Tab:AddToggle({
    Name        = "Auto Farm",
    Description = "Optional helper text",
    Default     = false,
    Flag        = "AutoFarm",
    Callback    = function(state) end,
})
```
Returns `{ Set, GetState, Lock, Unlock }`. The track glows purple while enabled.

### Slider

```lua
Tab:AddSlider({
    Name        = "Walk Speed",
    Description = "Optional helper text",
    Min = 16, Max = 200, Default = 16,
    Step        = 1,          -- optional rounding step
    Suffix      = " studs",   -- optional text after the value
    Flag        = "WalkSpeed",
    Callback    = function(value) end,
})
```
Returns `{ Set, Lock, Unlock }`. Current value shows in a chip.

### Dropdown

```lua
local dd = Tab:AddDropdown({
    Name     = "Farm Mode",
    Options  = { "Nearest", "Richest", "Random" },
    Default  = "Nearest",
    Search   = nil,        -- auto: search box appears at 8+ options (true/false to force)
    Flag     = "FarmMode",
    Callback = function(value) end,
})
dd:Set("Random")
dd:Refresh({ "New", "Options" })       -- pass true as 2nd arg to keep selection
```

### Multi Dropdown

```lua
Tab:AddMultiDropdown({
    Name     = "Item Filter",
    Options  = { "Coins", "Gems", "Chests" },
    Default  = { "Coins" },
    Flag     = "ItemFilter",
    Callback = function(list) end,     -- receives an array of selected options
})
```

### Keybind

```lua
Tab:AddKeybind({
    Name            = "Panic Key",
    Default         = Enum.KeyCode.P,
    Flag            = "PanicKey",
    Callback        = function(key) end,   -- fired when the key is pressed
    ChangedCallback = function(key) end,   -- fired when the bind is changed
})
```
Click the chip, press a key to rebind. **Backspace clears the bind.**

### Color Picker

```lua
Tab:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(122, 44, 255),
    Flag     = "ESPColor",
    Callback = function(color3) end,
})
```
Click the swatch to expand a saturation/value square + hue bar. Returns `{ Set, GetColor, Lock, Unlock }` (`Set` accepts a Color3 or `"#hex"`).

### Input

```lua
Tab:AddInput({
    Name        = "Webhook URL",
    Default     = "",
    Placeholder = "https://...",
    Flag        = "Webhook",
    Callback    = function(text, enterPressed) end,   -- fired on focus lost
})
```
Returns `{ Set, GetText, Lock, Unlock }`.

### Discord Card

Live server widget — fetches **real member & online counts** and the server icon from the Discord API, refreshing periodically:

```lua
Tab:AddDiscord({
    Invite          = "x2RtUZb6d9",   -- invite code or full discord.gg URL
    Title           = "My Server",    -- placeholder until the real name loads
    ButtonText      = "Join",         -- copies the invite link + notification
    RefreshInterval = 120,            -- seconds between count refreshes
})
```

> Uses the executor's `request` function. If HTTP isn't available it falls back to showing the invite link. Server icons are cached in `HadoUI/cache/`.

---

## Locked Elements

Grey out features (e.g. premium-only) with a lock overlay:

```lua
local esp = Tab:AddToggle({
    Name = "Rage Mode",
    Locked = true, LockedTitle = "Premium only",
})

-- later, after a key check:
esp:Unlock()
esp:Lock("Subscription expired")   -- re-lock with new text
```

Works on Button, Toggle, Slider, Dropdown, Multi Dropdown, Keybind, Color Picker, and Input.

---

## Notifications

```lua
HadoUI:Notify({
    Title    = "Purchase complete",
    Content  = "You bought <b>Golden Shark</b>.",  -- RichText supported
    Type     = "Success",       -- Success | Warning | Error | Information
    Icon     = "bell",          -- optional lucide icon (replaces the type glyph)
    Duration = 4,               -- seconds
    CanClose = true,            -- show the ✕ close button
})
```

Notifications stack bottom-right with a colored side bar, icon bubble, and timer bar.

---

## Dialogs

```lua
Window:Dialog({
    Title   = "Reset progress?",
    Content = "This action cannot be undone.",
    Icon    = "circle-alert",
    Buttons = {
        { Title = "Reset",  Variant = "Primary", Callback = function() end },
        { Title = "Cancel" },   -- non-primary buttons are grey
    },
})
```

Dims the screen, pops a centered card. The first button defaults to Primary (accent gradient). Returns `{ Close }`.

---

## Topbar Tags

Small chips next to the status pill:

```lua
Window:Tag({ Title = "BETA", Icon = "flame" })                       -- themed chip
Window:Tag({ Title = "v2.0", Color = Color3.fromRGB(28, 28, 28) })   -- custom color
```

Returns `{ SetTitle }`.

---

## Icons

Icons come from the **lucide** pack (900+ icons), fetched once per session. Anywhere an `Icon` option exists you can use:

- A lucide name: `"house"`, `"user"`, `"eye"`, `"settings"`, `"swords"`, `"flame"`, `"bell"`, `"lock"`, ... (browse at [lucide.dev/icons](https://lucide.dev/icons))
- A Roblox asset: `"rbxassetid://123456789"`

If the pack can't be downloaded (HTTP blocked), everything falls back to text — nothing breaks.

---

## Themes

| Theme | Accent | Vibe |
|---|---|---|
| **Purple** *(default)* | `#7A2CFF` | The Hado look — purple-tinted blacks |
| **Dark** | `#7A2CFF` | Neutral greys, purple accent |
| **Midnight** | `#3B6FF5` | Deep navy blue |
| **Rose** | `#EC4899` | Dark rose pink |
| **Emerald** | `#10B981` | Deep green |

```lua
Window:SetTheme("Midnight")                       -- adopts the theme's accent
Window:SetAccent(Color3.fromRGB(255, 100, 50))    -- override accent any time
```

Both are also in the Settings tab; every element restyles live.

---

## Flags & Configs

Any element with a `Flag` is tracked:

```lua
HadoUI.Flags.AutoFarm          -- current value of the flag
HadoUI.Options.AutoFarm:Set(true)   -- the element object (Set fires the callback)
```

Configs are JSON files saved per `ConfigName`:

```lua
Window:SaveConfig("legit")     -- HadoUI/configs/MyScript_legit.json
Window:LoadConfig("legit")     -- applies every saved flag through element:Set
Window:ResetConfig()           -- restores every element to its default
```

The prebuilt Settings tab includes a config name input, a **dropdown of your saved configs**, and Save / Load / Reset buttons. Colors are saved as hex, keybinds as key names — both restored correctly.

---

## Settings Tab

`Window:AddSettingsTab()` builds a full page:

| Group | Controls |
|---|---|
| Interface | UI Scale slider · **Auto DPI Scaling** toggle · Background Transparency · Acrylic Blur · Theme dropdown · Accent color picker · Toggle UI keybind |
| Configuration | Config name input · Saved configs dropdown · Save / Load / Reset |
| About | Script name, version, library credit, toggle key reminder |

**Auto DPI Scaling** sizes the UI to the screen: 1080p = 100%, 1440p ≈ 133%, 4K = 200%, small screens shrink to 70%. It reacts live to resolution changes, and the user's UI Scale multiplies on top.

---

## Mobile

HadoUI detects touch devices automatically (touch available + no keyboard) and adapts — no configuration needed:

- **Touch everywhere** — dragging the window, resizing from edges, sliders, color pickers, dropdowns, and the open pill all respond to touch.
- **Auto-fit sizing** — the window starts smaller (480×340) and scales to fit the phone screen, so it never overflows.
- **Larger grab zones** — resize edges and corners are widened to finger size.
- **Tap to reopen** — since there's no keyboard, closing the window shows the draggable **Open** pill; notifications say "Tap the Open button" instead of naming a key.

Everything works the same in code — you don't write anything mobile-specific.

---

## Window Controls

| Action | How |
|---|---|
| Move | Drag the top bar |
| Resize | Drag any edge or corner (min 460×320) |
| Minimize | `—` button collapses to the top bar |
| Hide / reopen | `✕` button or `ToggleKey`; the floating **Open pill** (draggable) reopens it |
| Content width | Element column caps at ~780px and centers itself on very wide windows |

---

## Files & Folders

Everything lives in the executor workspace under `HadoUI/`:

```
HadoUI/
├── icon.png                  ← your logo (optional, auto-detected)
├── <ConfigName>_ui.json      ← window position/size/scale/DPI (auto-saved)
├── configs/
│   └── <ConfigName>_<name>.json   ← saved configs
└── cache/
    └── discord_<id>.png      ← cached Discord server icons
```

---

## FAQ

**The icons don't show.** Your executor blocked `game:HttpGet` to GitHub. Everything still works — buttons fall back to text glyphs.

**The Discord card says "discord.gg/..." instead of counts.** Your executor has no `request`/`http_request` function, or Discord's API rate-limited the request. The Join button still works.

**Can I use it in multiple scripts at once?** Yes — each `CreateWindow` gets its own window; give each a unique `ConfigName`.

**How do I add my logo for other users?** Upload the image to Roblox as a decal and pass `Icon = "rbxassetid://ID"` — workspace `icon.png` only exists on your machine.

**Studio support?** The UI renders, but anything needing executor functions (configs, clipboard, custom icons, HTTP) silently disables itself.

---

<div align="center">

Built with 💜 by **Hado** · HadoUI v2.0.0

</div>
