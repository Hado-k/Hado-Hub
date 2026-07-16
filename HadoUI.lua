--[[
    ██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗   ██╗██╗
    ██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║   ██║██║
    ███████║███████║██║  ██║██║   ██║██║   ██║██║
    ██╔══██║██╔══██║██║  ██║██║   ██║██║   ██║██║
    ██║  ██║██║  ██║██████╔╝╚██████╔╝╚██████╔╝██║
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚═════╝ ╚═╝

    HadoUI — Premium purple UI framework by Hado
    Version 1.0.0

    ── QUICK START ────────────────────────────────────────────────
    local HadoUI = loadstring(readfile("HadoUI/HadoUI.lua"))()
    -- (or paste this whole file above your script; it returns the library
    --  and also sets getgenv().HadoUI)

    local Window = HadoUI:CreateWindow({
        Name     = "My Script",        -- shown in top bar
        Version  = "v1.0",             -- shown in top bar
        Author   = "Hado",             -- shown in top bar
        Discord  = "https://discord.gg/x2RtUZb6d9",
        Icon     = nil,                -- "rbxassetid://123456" (optional; auto-loads
                                       --  workspace file "HadoUI/icon.png" if present)
        ConfigName = "MyScript",       -- file name used for saved configs
        ToggleKey  = Enum.KeyCode.RightShift,
    })

    local Main = Window:AddTab("Main")                        -- or AddTab({ Name = "Main", Icon = "house" })
    -- Icons: any lucide icon name ("house", "user", "eye", "swords", "settings", ...)
    -- or a raw "rbxassetid://" id. Works on tabs, notifications, dialogs, tags.
    Main:AddSection("Farming")
    Main:AddToggle({ Name = "Auto Farm", Flag = "AutoFarm", Callback = function(v) end })
    Main:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
    Main:AddButton({ Name = "Do Thing", Callback = function() end })
    Main:AddDropdown({ Name = "Mode", Options = {"A","B"}, Default = "A", Callback = function(v) end })
    Main:AddMultiDropdown({ Name = "Targets", Options = {"X","Y"}, Callback = function(list) end })
    Main:AddKeybind({ Name = "Kill Switch", Default = Enum.KeyCode.K, Callback = function() end })
    Main:AddColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(122,44,255), Callback = function(c) end })
    Main:AddInput({ Name = "Webhook", Placeholder = "https://...", Callback = function(txt) end })
    Main:AddParagraph({ Title = "Info", Content = "Longer text here." })
    Main:AddLabel("Just a label")
    Main:AddDivider()

    Window:AddSettingsTab()            -- builds the full Settings page (scale,
                                       -- transparency, blur, accent, theme, configs)

    HadoUI:Notify({ Title = "Loaded", Content = "Welcome!", Type = "Success", Duration = 4,
                    Icon = "bell", CanClose = true })

    -- v2.0 additions:
    Window:Dialog({ Title = "Confirm", Content = "Are you sure?", Icon = "circle-alert",
        Buttons = { { Title = "Yes", Variant = "Primary", Callback = fn }, { Title = "Cancel" } } })
    Window:Tag({ Title = "BETA", Icon = "flame" })            -- topbar chip
    -- auto DPI scaling: UI sizes itself to the screen resolution (toggle in Settings)
    -- element extras: Locked = true / LockedTitle = "..."; element:Lock() / :Unlock()
    -- dropdowns with 8+ options gain a search box automatically (Search = true/false to force)
    -- themes: Purple, Dark, Midnight, Rose, Emerald (theme dropdown updates automatically)
    -- floating "Open" pill appears when the window is hidden (draggable, click to reopen)
    ───────────────────────────────────────────────────────────────
]]

--// Services -------------------------------------------------------------
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- touch-first device: touch available and no physical keyboard
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// Library root ---------------------------------------------------------
local HadoUI = {
    Version  = "2.0.0",
    Flags    = {},   -- Flag -> current value
    Options  = {},   -- Flag -> element object (has :Set)
    Windows  = {},
    Folder   = "HadoUI",
}

--// Themes ---------------------------------------------------------------
local ACCENT      = Color3.fromRGB(122, 44, 255)  -- #7A2CFF
local ACCENT_DARK = Color3.fromRGB(84, 22, 190)

local Themes = {
    Purple = {
        Background   = Color3.fromRGB(13, 10, 20),
        Surface      = Color3.fromRGB(18, 15, 27),
        Surface2     = Color3.fromRGB(24, 20, 35),
        Element      = Color3.fromRGB(29, 24, 43),
        ElementHover = Color3.fromRGB(36, 30, 53),
        Stroke       = Color3.fromRGB(52, 42, 78),
        StrokeSoft   = Color3.fromRGB(38, 31, 58),
        Text         = Color3.fromRGB(236, 231, 247),
        SubText      = Color3.fromRGB(152, 143, 176),
    },
    Dark = {
        Background   = Color3.fromRGB(11, 11, 13),
        Surface      = Color3.fromRGB(16, 16, 19),
        Surface2     = Color3.fromRGB(21, 21, 25),
        Element      = Color3.fromRGB(26, 26, 31),
        ElementHover = Color3.fromRGB(33, 33, 39),
        Stroke       = Color3.fromRGB(46, 46, 54),
        StrokeSoft   = Color3.fromRGB(36, 36, 42),
        Text         = Color3.fromRGB(238, 238, 242),
        SubText      = Color3.fromRGB(148, 148, 158),
    },
    Midnight = {
        DefaultAccent = Color3.fromRGB(59, 111, 245),
        Background   = Color3.fromRGB(10, 14, 26),
        Surface      = Color3.fromRGB(15, 21, 37),
        Surface2     = Color3.fromRGB(20, 28, 48),
        Element      = Color3.fromRGB(25, 34, 58),
        ElementHover = Color3.fromRGB(31, 42, 70),
        Stroke       = Color3.fromRGB(44, 58, 94),
        StrokeSoft   = Color3.fromRGB(33, 44, 73),
        Text         = Color3.fromRGB(219, 234, 254),
        SubText      = Color3.fromRGB(130, 150, 185),
    },
    Rose = {
        DefaultAccent = Color3.fromRGB(236, 72, 153),
        Background   = Color3.fromRGB(23, 5, 12),
        Surface      = Color3.fromRGB(33, 9, 18),
        Surface2     = Color3.fromRGB(43, 13, 25),
        Element      = Color3.fromRGB(52, 17, 31),
        ElementHover = Color3.fromRGB(63, 22, 39),
        Stroke       = Color3.fromRGB(94, 38, 60),
        StrokeSoft   = Color3.fromRGB(70, 29, 46),
        Text         = Color3.fromRGB(253, 242, 248),
        SubText      = Color3.fromRGB(198, 133, 162),
    },
    Emerald = {
        DefaultAccent = Color3.fromRGB(16, 185, 129),
        Background   = Color3.fromRGB(3, 17, 13),
        Surface      = Color3.fromRGB(7, 25, 20),
        Surface2     = Color3.fromRGB(11, 33, 27),
        Element      = Color3.fromRGB(15, 41, 34),
        ElementHover = Color3.fromRGB(20, 50, 41),
        Stroke       = Color3.fromRGB(32, 76, 62),
        StrokeSoft   = Color3.fromRGB(24, 58, 47),
        Text         = Color3.fromRGB(236, 253, 245),
        SubText      = Color3.fromRGB(114, 163, 143),
    },
}
Themes.Purple.DefaultAccent = ACCENT
Themes.Dark.DefaultAccent   = ACCENT

local Theme = {}                      -- live theme (copied from Themes + accent)
local ThemeRegistry = setmetatable({}, { __mode = "k" }) -- obj -> {Prop = key}

local function rebuildTheme(name, accent)
    local base = Themes[name] or Themes.Purple
    for k, v in pairs(base) do Theme[k] = v end
    Theme.Accent     = accent or Theme.Accent or ACCENT
    local h, s, v = Theme.Accent:ToHSV()
    Theme.AccentDark = Color3.fromHSV(h, math.min(s * 1.05, 1), v * 0.65)
    Theme.AccentSoft = Color3.fromHSV(h, math.max(s - 0.25, 0), math.min(v + 0.25, 1))
end
rebuildTheme("Purple", ACCENT)

local function themeValue(key)
    if key == "AccentSequence" then
        return ColorSequence.new(Theme.Accent, Theme.AccentDark)
    end
    return Theme[key]
end

-- Bind instance properties to theme keys so live theme/accent swaps restyle everything
local function Bind(obj, propMap)
    ThemeRegistry[obj] = propMap
    for prop, key in pairs(propMap) do
        obj[prop] = themeValue(key)
    end
    return obj
end

local function ApplyTheme()
    for obj, propMap in pairs(ThemeRegistry) do
        if obj.Parent ~= nil or obj:IsA("UIGradient") or obj:IsA("UIStroke") then
            for prop, key in pairs(propMap) do
                pcall(function() obj[prop] = themeValue(key) end)
            end
        end
    end
end

--// Small helpers --------------------------------------------------------
local function New(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Tween(obj, props, time, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function Corner(parent, radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function Stroke(parent, key, thickness, transparency)
    local s = New("UIStroke", {
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
    Bind(s, { Color = key or "Stroke" })
    return s
end

local function Padding(parent, t, b, l, r)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
        Parent = parent,
    })
end

-- Soft drop shadow using Roblox's stock radial shadow image
local function Shadow(parent, size, transparency)
    return New("ImageLabel", {
        Name = "Shadow", BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084", ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = transparency or 0.45,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(24, 24, 276, 276),
        Size = UDim2.new(1, size or 40, 1, size or 40),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = -1, Parent = parent,
    })
end

local function safeCallback(cb, ...)
    if type(cb) ~= "function" then return end
    local args = { ... }
    task.spawn(function()
        local ok, err = pcall(cb, unpack(args))
        if not ok then warn("[HadoUI] callback error: " .. tostring(err)) end
    end)
end

--// Filesystem (config) helpers -----------------------------------------
local fs = {
    canUse = (writefile and readfile and isfile and isfolder and makefolder) and true or false,
}

function fs.ensure()
    if not fs.canUse then return end
    pcall(function()
        if not isfolder(HadoUI.Folder) then makefolder(HadoUI.Folder) end
        if not isfolder(HadoUI.Folder .. "/configs") then makefolder(HadoUI.Folder .. "/configs") end
    end)
end

function fs.writeJSON(path, tbl)
    if not fs.canUse then return false end
    local ok = pcall(function() writefile(path, HttpService:JSONEncode(tbl)) end)
    return ok
end

function fs.readJSON(path)
    if not fs.canUse then return nil end
    local ok, data = pcall(function()
        if isfile(path) then return HttpService:JSONDecode(readfile(path)) end
    end)
    if ok then return data end
end

--// HTTP helpers ---------------------------------------------------------
local function httpRequest(opts)
    local req = (syn and syn.request) or (http and http.request) or http_request
        or request or (fluxus and fluxus.request)
    if not req then return nil end
    local ok, res = pcall(req, opts)
    if ok then return res end
end

-- downloads a web image once, caches it, returns a getcustomasset id (or nil)
local function fetchWebImage(url, cacheName)
    if not (fs.canUse and getcustomasset) then return nil end
    local dir = HadoUI.Folder .. "/cache"
    local path = dir .. "/" .. cacheName
    local ok, asset = pcall(function()
        if not isfile(path) then
            local res = httpRequest({ Url = url, Method = "GET" })
            if not (res and res.Body and #res.Body > 0) then return nil end
            if not isfolder(dir) then makefolder(dir) end
            writefile(path, res.Body)
        end
        return getcustomasset(path)
    end)
    if ok then return asset end
end

local function formatCount(n)
    n = tonumber(n) or 0
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.1fK", n / 1000) end
    return tostring(n)
end

--// Icon system (lucide icon pack, lazily fetched; everything degrades
--// gracefully to text if the pack can't be loaded) ----------------------
local IconPack = { tried = false, module = nil }

local function ensureIconPack()
    if IconPack.tried then return IconPack.module end
    IconPack.tried = true
    pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")
        local mod = loadstring(src)()
        mod.SetIconsType("lucide")
        IconPack.module = mod
    end)
    return IconPack.module
end

-- GetIcon("house") -> { Image, RectOffset, RectSize } or nil.
-- Also accepts a raw "rbxassetid://..." string.
local function GetIcon(name)
    if not name or name == "" then return nil end
    if type(name) == "string" and name:find("rbxassetid://") then
        return { Image = name, RectOffset = Vector2.new(0, 0), RectSize = Vector2.new(0, 0) }
    end
    local mod = ensureIconPack()
    if not mod then return nil end
    local ok, icon = pcall(function() return mod.Icon(name) end)
    if ok and icon and icon[1] then
        return {
            Image = icon[1],
            RectOffset = icon[2] and icon[2].ImageRectPosition or Vector2.new(0, 0),
            RectSize = icon[2] and icon[2].ImageRectSize or Vector2.new(0, 0),
        }
    end
    return nil
end

-- Creates a themed ImageLabel for an icon name; returns nil if unavailable
local function IconLabel(name, size, colorKey, parent, props)
    local ic = GetIcon(name)
    if not ic then return nil end
    local img = New("ImageLabel", {
        BackgroundTransparency = 1, Image = ic.Image,
        ImageRectOffset = ic.RectOffset, ImageRectSize = ic.RectSize,
        Size = UDim2.fromOffset(size, size), Parent = parent,
    })
    for k, v in pairs(props or {}) do img[k] = v end
    if typeof(colorKey) == "Color3" then
        img.ImageColor3 = colorKey
    elseif colorKey then
        Bind(img, { ImageColor3 = colorKey })
    end
    return img
end

--// ScreenGui root -------------------------------------------------------
local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    if syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = CoreGui
        return nil, sg
    end
    local ok2 = pcall(function() return CoreGui.Name end)
    if ok2 then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui do
    local parent, premade = getGuiParent()
    ScreenGui = premade or Instance.new("ScreenGui")
    ScreenGui.Name = "HadoUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    if parent then ScreenGui.Parent = parent end
end
HadoUI.ScreenGui = ScreenGui

--// Notification system --------------------------------------------------
local NotifyTypes = {
    Success     = { Color = Color3.fromRGB(70, 220, 130),  Icon = "✓" },
    Warning     = { Color = Color3.fromRGB(255, 184, 64),  Icon = "!" },
    Error       = { Color = Color3.fromRGB(255, 92, 92),   Icon = "✕" },
    Information = { Color = nil--[[accent]],               Icon = "i" },
}
NotifyTypes.Info = NotifyTypes.Information

local NotifyHolder = New("Frame", {
    Name = "Notifications", BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -18, 1, -18),
    Size = UDim2.new(0, 300, 1, -36),
    ZIndex = 200, Parent = ScreenGui,
}, {
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }),
})

function HadoUI:Notify(opts)
    opts = opts or {}
    local info     = NotifyTypes[opts.Type or "Information"] or NotifyTypes.Information
    local color    = info.Color or Theme.Accent
    local duration = opts.Duration or 4

    local card = New("Frame", {
        BackgroundTransparency = 1, ClipsDescendants = false,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 201, Parent = NotifyHolder,
    })

    local body = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(1, 320, 0, 0), -- start off-screen right
        ZIndex = 201, Parent = card,
    })
    Bind(body, { BackgroundColor3 = "Surface" })
    Corner(body, 10); Stroke(body, "Stroke", 1, 0.2); Shadow(body, 34, 0.5)

    New("Frame", { -- accent side bar
        BackgroundColor3 = color, Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 8, 0, 8), ZIndex = 203, Parent = body,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local iconDot = New("Frame", {
        BackgroundColor3 = color, BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 20, 0, 12),
        ZIndex = 202, Parent = body,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    -- custom lucide icon when provided, otherwise the type glyph
    local customIcon = opts.Icon and IconLabel(opts.Icon, 14, color, iconDot, {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 203,
    })
    if not customIcon then
        New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Text = info.Icon, TextColor3 = color, Font = Enum.Font.GothamBold,
            TextSize = 13, ZIndex = 203, Parent = iconDot,
        })
    end

    local title = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 11),
        Size = UDim2.new(1, -86, 0, 16), RichText = true,
        Text = opts.Title or "Notification", Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202, Parent = body,
    })
    Bind(title, { TextColor3 = "Text" })

    local content = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 56, 0, 29),
        Size = UDim2.new(1, -70, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Text = opts.Content or "", Font = Enum.Font.Gotham, TextSize = 12, RichText = true,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 202, Parent = body,
    })
    Bind(content, { TextColor3 = "SubText" })

    New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, 0), ZIndex = 201, Parent = content }) -- bottom pad

    -- timer bar
    local barBack = New("Frame", {
        BackgroundColor3 = color, BackgroundTransparency = 0.85,
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2), ZIndex = 203, Parent = body,
    })
    local bar = New("Frame", {
        BackgroundColor3 = color, Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 204, Parent = barBack,
    })

    local closed = false
    local function close()
        if closed or not card.Parent then return end
        closed = true
        Tween(body, { Position = UDim2.new(1, 320, 0, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.32)
        card:Destroy()
    end

    -- close button (top-right)
    if opts.CanClose ~= false then
        local x = New("TextButton", {
            BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -8, 0, 8), Size = UDim2.new(0, 18, 0, 18),
            Text = "✕", Font = Enum.Font.GothamBold, TextSize = 11,
            ZIndex = 205, Parent = body,
        })
        Bind(x, { TextColor3 = "SubText" })
        x.MouseEnter:Connect(function() Tween(x, { TextColor3 = Theme.Text }, 0.15) end)
        x.MouseLeave:Connect(function() Tween(x, { TextColor3 = Theme.SubText }, 0.15) end)
        x.MouseButton1Click:Connect(function() task.spawn(close) end)
    end

    Tween(body, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back)
    Tween(bar, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, close)
end

--// Blur (acrylic-style world blur behind the UI) ------------------------
local BlurEffect
local function SetBlur(enabled)
    if enabled then
        if not BlurEffect then
            BlurEffect = New("BlurEffect", { Name = "HadoUIBlur", Size = 0, Parent = Lighting })
        end
        Tween(BlurEffect, { Size = 14 }, 0.3)
    elseif BlurEffect then
        Tween(BlurEffect, { Size = 0 }, 0.3)
    end
end

--// Window ---------------------------------------------------------------
function HadoUI:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {
        Name       = cfg.Name or "HadoUI",
        VersionTag = cfg.Version or "v1.0",
        Author     = cfg.Author or "Hado",
        Discord    = cfg.Discord or "https://discord.gg/x2RtUZb6d9",
        ConfigName = cfg.ConfigName or (cfg.Name or "HadoUI"):gsub("%W", ""),
        ToggleKey  = cfg.ToggleKey or Enum.KeyCode.RightShift,
        Tabs       = {},
        Minimized  = false,
        Hidden     = false,
    }
    table.insert(HadoUI.Windows, Window)
    fs.ensure()

    -- restore last session's window state / ui prefs
    local uiState = fs.readJSON(HadoUI.Folder .. "/" .. Window.ConfigName .. "_ui.json") or {}

    local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
    -- mobile: smaller default window that fits a phone screen
    local defW = IS_MOBILE and 480 or 640
    local defH = IS_MOBILE and 340 or 440
    local W = math.clamp(uiState.W or defW, 420, viewport.X * 0.95)
    local H = math.clamp(uiState.H or defH, 300, viewport.Y * 0.95)
    local X = uiState.X or (viewport.X / 2 - W / 2)
    local Y = uiState.Y or (viewport.Y / 2 - H / 2)
    X = math.clamp(X, -W + 120, viewport.X - 120)
    Y = math.clamp(Y, 0, viewport.Y - 60)

    local TOPBAR_H  = 46
    local SIDEBAR_W = 160

    --── Root frame ──────────────────────────────────────────────────────
    local Root = New("Frame", {
        Name = "Window", BackgroundTransparency = 1,
        Position = UDim2.fromOffset(X, Y), Size = UDim2.fromOffset(W, H),
        Visible = false, Parent = ScreenGui,
    })

    -- auto DPI scaling: matches UI size to the screen resolution and tracks
    -- viewport changes live; the user's UI-scale setting multiplies on top
    Window._userScale = uiState.Scale or 1
    Window._autoDPI = uiState.AutoDPI ~= false
    local Scale = New("UIScale", { Parent = Root })
    local function autoScale()
        if not Window._autoDPI then return 1 end
        local v = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or viewport
        -- phones report tiny viewport heights but sit close to the eye; scale by
        -- how much of the screen the window would fill so it stays usable and
        -- never overflows the screen
        if IS_MOBILE then
            local fit = math.min(v.X / (W + 24), v.Y / (H + 24))
            return math.clamp(fit, 0.5, 1.1)
        end
        -- desktop: 1080p = 1.0 baseline; 1440p ≈ 1.33, 4K = 2.0, small screens shrink
        return math.clamp(v.Y / 1080, 0.7, 2)
    end
    local function applyScale(animate)
        local target = Window._userScale * autoScale()
        if animate then Tween(Scale, { Scale = target }, 0.2)
        else Scale.Scale = target end
    end
    applyScale()
    pcall(function()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            applyScale(true)
        end)
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            if workspace.CurrentCamera then
                workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    applyScale(true)
                end)
            end
            applyScale()
        end)
    end)

    -- plain Frame (NOT CanvasGroup: its texture pass caps resolution and makes
    -- large/maximized windows look blurry); open/close animate via UIScale
    local Main = New("Frame", {
        Name = "Main", Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, Parent = Root,
    })
    Bind(Main, { BackgroundColor3 = "Background" })
    Corner(Main, 14)
    local mainStroke = Stroke(Main, "Stroke", 1, 0.1)
    local popScale = New("UIScale", { Scale = 1, Parent = Main })

    -- faint diagonal accent wash to lift the flat background
    local wash = New("Frame", {
        BackgroundTransparency = 0, Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0, Parent = Main,
    })
    Corner(wash, 12)
    local washGrad = New("UIGradient", { Rotation = 115, Parent = wash })
    local function refreshWash()
        washGrad.Color = ColorSequence.new(Theme.Accent, Theme.Accent)
        washGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.90),
            NumberSequenceKeypoint.new(0.45, 0.985),
            NumberSequenceKeypoint.new(1, 1),
        })
    end
    refreshWash()
    Bind(wash, { BackgroundColor3 = "Background" }) -- keeps wash matching on theme swap

    --── Top bar ─────────────────────────────────────────────────────────
    local TopBar = New("Frame", {
        Name = "TopBar", Size = UDim2.new(1, 0, 0, TOPBAR_H),
        BackgroundTransparency = 1, ZIndex = 5, Parent = Main,
    })
    -- accent hairline under the top bar, fading out at both ends
    local topLine = New("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 1, -1), Size = UDim2.new(1, -24, 0, 1),
        ZIndex = 5, Parent = TopBar,
    })
    local topLineGrad = New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.2, 0.35),
            NumberSequenceKeypoint.new(0.8, 0.35),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = topLine,
    })
    Bind(topLineGrad, { Color = "AccentSequence" })

    -- Icon (circular "H" badge; uses image asset / workspace icon.png when available)
    local IconHolder = New("Frame", {
        Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 6, Parent = TopBar,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = IconHolder })
    local iconGrad = New("UIGradient", { Rotation = 45, Parent = IconHolder })
    Bind(iconGrad, { Color = "AccentSequence" })
    Bind(IconHolder, { BackgroundColor3 = "Accent" })

    local iconImage = cfg.Icon
    if not iconImage and isfile and getcustomasset then
        pcall(function()
            if isfile(HadoUI.Folder .. "/icon.png") then
                iconImage = getcustomasset(HadoUI.Folder .. "/icon.png")
            end
        end)
    end
    if iconImage then
        New("ImageLabel", {
            BackgroundTransparency = 1, Image = iconImage,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 7, Parent = IconHolder,
        }, { New("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    else
        New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Text = "H", Font = Enum.Font.GothamBlack, TextSize = 16,
            TextColor3 = Color3.new(1, 1, 1), ZIndex = 7, Parent = IconHolder,
        })
    end

    -- Title / version / author
    local titleLabel = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 52, 0, 8),
        Size = UDim2.new(0.5, 0, 0, 16), Text = Window.Name,
        Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = TopBar,
    })
    Bind(titleLabel, { TextColor3 = "Text" })

    local versionChip = New("TextLabel", {
        BackgroundTransparency = 0.85, Position = UDim2.new(0, 52 + titleLabel.TextBounds.X + 8, 0, 9),
        Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X,
        Text = " " .. Window.VersionTag .. " ", Font = Enum.Font.GothamMedium, TextSize = 10,
        ZIndex = 6, Parent = TopBar,
    })
    Bind(versionChip, { TextColor3 = "AccentSoft", BackgroundColor3 = "Accent" })
    Corner(versionChip, 4)
    titleLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        versionChip.Position = UDim2.new(0, 52 + titleLabel.TextBounds.X + 8, 0, 9)
    end)

    local authorLabel = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 52, 0, 25),
        Size = UDim2.new(0.5, 0, 0, 12), Text = "by " .. Window.Author,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = TopBar,
    })
    Bind(authorLabel, { TextColor3 = "SubText" })

    -- Right cluster: status • fps/ping • discord • minimize • close
    local rightRow = New("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6, Parent = TopBar,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
        }),
    })

    local statusPill = New("Frame", {
        BackgroundTransparency = 0.5, Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 1, ZIndex = 6, Parent = rightRow,
    })
    Bind(statusPill, { BackgroundColor3 = "Surface2" })
    Corner(statusPill, 11); Padding(statusPill, 0, 0, 9, 9)
    local dot = New("Frame", {
        BackgroundColor3 = Color3.fromRGB(70, 220, 130), Size = UDim2.new(0, 7, 0, 7),
        Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 7, Parent = statusPill,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    task.spawn(function() -- gentle pulse on the status dot
        while dot.Parent do
            Tween(dot, { BackgroundTransparency = 0.6 }, 0.9, Enum.EasingStyle.Sine)
            task.wait(0.95)
            Tween(dot, { BackgroundTransparency = 0 }, 0.9, Enum.EasingStyle.Sine)
            task.wait(0.95)
        end
    end)
    local statusText = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 13, 0, 0),
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        Text = "Online", Font = Enum.Font.GothamMedium, TextSize = 11,
        ZIndex = 7, Parent = statusPill,
    })
    Bind(statusText, { TextColor3 = "SubText" })

    local perfLabel = New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2,
        Text = "-- FPS  •  -- ms", Font = Enum.Font.GothamMedium, TextSize = 11,
        ZIndex = 6, Parent = rightRow,
    })
    Bind(perfLabel, { TextColor3 = "SubText" })

    local function topButton(text, order, accentBg, iconName)
        local b = New("TextButton", {
            Size = UDim2.new(0, accentBg and 0 or 26, 0, 26),
            AutomaticSize = accentBg and Enum.AutomaticSize.X or Enum.AutomaticSize.None,
            Text = accentBg and "" or text, Font = Enum.Font.GothamBold, TextSize = 12,
            AutoButtonColor = false, LayoutOrder = order, ZIndex = 6, Parent = rightRow,
        })
        Corner(b, accentBg and 8 or 7)
        if accentBg then
            -- gradient lives on the button bg; caption is a child label so the
            -- gradient can't tint the text (UIGradient recolors text otherwise)
            Bind(b, { BackgroundColor3 = "Accent" })
            Padding(b, 0, 0, 11, 11)
            local g = New("UIGradient", { Rotation = 90, Parent = b })
            Bind(g, { Color = "AccentSequence" })
            New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X, Text = text,
                Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = Color3.new(1, 1, 1), ZIndex = 7, Parent = b,
            })
        else
            Bind(b, { BackgroundColor3 = "Surface2", TextColor3 = "SubText" })
            -- prefer a lucide icon; keep the text glyph as fallback
            if iconName then
                local ic = IconLabel(iconName, 13, "SubText", b, {
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 7,
                })
                if ic then b.Text = "" end
            end
        end
        b.MouseEnter:Connect(function()
            Tween(b, { BackgroundColor3 = accentBg and Theme.AccentSoft or Theme.ElementHover }, 0.15)
        end)
        b.MouseLeave:Connect(function()
            Tween(b, { BackgroundColor3 = accentBg and Theme.Accent or Theme.Surface2 }, 0.15)
        end)
        b.MouseButton1Down:Connect(function() Tween(b, { Size = b.Size - UDim2.fromOffset(0, 2) }, 0.08) end)
        b.MouseButton1Up:Connect(function() Tween(b, { Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset, 0, 26) }, 0.08) end)
        return b
    end

    -- Discord button is optional: pass DiscordButton = false to hide it
    -- (e.g. when using Tab:AddDiscord instead)
    local discordBtn
    if cfg.Discord and cfg.DiscordButton ~= false then
        discordBtn = topButton("Discord", 3, true)
    end
    local minimizeBtn = topButton("—", 4, false, "minus")
    local closeBtn    = topButton("✕", 5, false, "x")

    -- Window:Tag({ Title = "BETA", Icon = "flame", Color = Color3 }) — topbar chip
    function Window:Tag(t)
        t = t or {}
        local chip = New("Frame", {
            BackgroundTransparency = t.Color and 0.15 or 0.5,
            Size = UDim2.new(0, 0, 0, 22), AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 0, ZIndex = 6, Parent = rightRow,
        })
        if t.Color then chip.BackgroundColor3 = t.Color
        else Bind(chip, { BackgroundColor3 = "Surface2" }) end
        Corner(chip, 11)
        local icon = t.Icon and IconLabel(t.Icon, 12, t.Color and Color3.new(1, 1, 1) or "AccentSoft", chip, {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), ZIndex = 7,
        })
        local lbl = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, icon and 25 or 9, 0, 0),
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            Text = t.Title or "Tag", Font = Enum.Font.GothamMedium, TextSize = 11,
            ZIndex = 7, Parent = chip,
        })
        if t.Color then lbl.TextColor3 = Color3.new(1, 1, 1)
        else Bind(lbl, { TextColor3 = "SubText" }) end
        Padding(chip, 0, 0, 0, 9)
        return { SetTitle = function(_, v) lbl.Text = v end }
    end

    if discordBtn then
        discordBtn.MouseButton1Click:Connect(function()
            local copied = pcall(function()
                (setclipboard or toclipboard)(Window.Discord)
            end)
            HadoUI:Notify({
                Title = "Discord",
                Content = copied and "Discord link copied to clipboard." or Window.Discord,
                Type = copied and "Success" or "Information", Duration = 4,
            })
        end)
    end

    --── Content: sidebar + pages ────────────────────────────────────────
    -- clipped so bottom-anchored children (profile card) can't ride up over
    -- the top bar while the window collapses during minimize
    local Content = New("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, TOPBAR_H),
        Size = UDim2.new(1, 0, 1, -TOPBAR_H), ClipsDescendants = true, Parent = Main,
    })

    local Sidebar = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, SIDEBAR_W, 1, 0), Parent = Content,
    })

    -- sliding selection pill sits behind the (transparent) tab buttons
    local PillHolder = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -70), Parent = Sidebar,
    })
    local Pill = New("Frame", {
        Size = UDim2.new(1, -22, 0, 32), Position = UDim2.fromOffset(12, 10),
        Visible = false, Parent = PillHolder,
    })
    Bind(Pill, { BackgroundColor3 = "Surface2" })
    Corner(Pill, 9); Stroke(Pill, "StrokeSoft", 1, 0.35)
    local pillBar = New("Frame", {
        Size = UDim2.new(0, 3, 0, 14), Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0, Parent = Pill,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    Bind(pillBar, { BackgroundColor3 = "Accent" })

    local TabList = New("ScrollingFrame", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -70), CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = Sidebar,
    }, {
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }),
        New("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10) }),
    })

    local function movePill(btn, instant)
        local s = math.max(Scale.Scale * popScale.Scale, 0.01)
        local y = (btn.AbsolutePosition.Y - TabList.AbsolutePosition.Y) / s
        local target = UDim2.fromOffset(12, y)
        Pill.Visible = true
        if instant then Pill.Position = target
        else Tween(Pill, { Position = target }, 0.3) end
    end

    -- profile card pinned to the bottom of the sidebar
    local Profile = New("Frame", {
        Position = UDim2.new(0, 12, 1, -60), Size = UDim2.new(1, -22, 0, 50), Parent = Sidebar,
    })
    Bind(Profile, { BackgroundColor3 = "Surface" })
    Corner(Profile, 10); Stroke(Profile, "StrokeSoft", 1, 0.35)
    local avatar = New("ImageLabel", {
        Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 34, 0, 34),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer and LocalPlayer.UserId or 1) .. "&w=48&h=48",
        Parent = Profile,
    })
    Bind(avatar, { BackgroundColor3 = "Surface2" })
    Corner(avatar, 8)
    local dispName = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 9),
        Size = UDim2.new(1, -58, 0, 14), Text = LocalPlayer and LocalPlayer.DisplayName or "Player",
        Font = Enum.Font.GothamBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Profile,
    })
    Bind(dispName, { TextColor3 = "Text" })
    local userName = New("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 26),
        Size = UDim2.new(1, -58, 0, 12), Text = "@" .. (LocalPlayer and LocalPlayer.Name or "player"),
        Font = Enum.Font.Gotham, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Profile,
    })
    Bind(userName, { TextColor3 = "SubText" })

    -- content sits on an inset card so the layout reads as two panels
    local ContentPanel = New("Frame", {
        BackgroundTransparency = 0.35, Position = UDim2.new(0, SIDEBAR_W, 0, 8),
        Size = UDim2.new(1, -SIDEBAR_W - 12, 1, -20), Parent = Content,
    })
    Bind(ContentPanel, { BackgroundColor3 = "Surface" })
    Corner(ContentPanel, 12); Stroke(ContentPanel, "StrokeSoft", 1, 0.5)

    local Pages = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true, Parent = ContentPanel,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Pages })

    --── FPS / Ping updater (single connection) ──────────────────────────
    local fps, acc = 60, 0
    local perfConn = RunService.RenderStepped:Connect(function(dt)
        fps = fps * 0.92 + (1 / math.max(dt, 1e-4)) * 0.08
        acc += dt
        if acc >= 0.5 then
            acc = 0
            local ping = ""
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
            end)
            perfLabel.Text = math.floor(fps + 0.5) .. " FPS  •  " .. (ping ~= "" and ping or "-- ms")
        end
    end)

    --── Persistence of window state ─────────────────────────────────────
    local saveQueued = false
    local function saveUIState()
        if saveQueued then return end
        saveQueued = true
        task.delay(0.6, function()
            saveQueued = false
            fs.writeJSON(HadoUI.Folder .. "/" .. Window.ConfigName .. "_ui.json", {
                X = Root.Position.X.Offset, Y = Root.Position.Y.Offset,
                W = Root.Size.X.Offset, H = Root.Size.Y.Offset,
                Scale = Window._userScale,
                AutoDPI = Window._autoDPI,
            })
        end)
    end
    Window._saveUIState = saveUIState

    --── Dragging (top bar) ──────────────────────────────────────────────
    do
        local dragging, dragInput, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Root.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        saveUIState()
                    end
                end)
            end
        end)
        TopBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local d = input.Position - dragStart
                Root.Position = UDim2.fromOffset(startPos.X.Offset + d.X, startPos.Y.Offset + d.Y)
            end
        end)
    end

    --── Resizing (all 4 edges + 4 corners) ──────────────────────────────
    do
        local MIN_W, MIN_H = 460, 320
        local function handle(name, pos, size, dirX, dirY)
            local h = New("Frame", {
                Name = name, BackgroundTransparency = 1, Position = pos, Size = size,
                ZIndex = 20, Active = true, Parent = Root,
            })
            local resizing, startMouse, startSize, startPos
            h.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    resizing = true
                    startMouse = input.Position
                    startSize = Root.Size
                    startPos = Root.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            resizing = false
                            saveUIState()
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if not resizing then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
                local d = (input.Position - startMouse)
                local newW, newH = startSize.X.Offset, startSize.Y.Offset
                local newX, newY = startPos.X.Offset, startPos.Y.Offset
                if dirX == 1 then
                    newW = math.max(MIN_W, startSize.X.Offset + d.X)
                elseif dirX == -1 then
                    newW = math.max(MIN_W, startSize.X.Offset - d.X)
                    newX = startPos.X.Offset + (startSize.X.Offset - newW)
                end
                if dirY == 1 then
                    newH = math.max(MIN_H, startSize.Y.Offset + d.Y)
                elseif dirY == -1 then
                    newH = math.max(MIN_H, startSize.Y.Offset - d.Y)
                    newY = startPos.Y.Offset + (startSize.Y.Offset - newH)
                end
                if not Window.Minimized then
                    Root.Size = UDim2.fromOffset(newW, newH)
                    Root.Position = UDim2.fromOffset(newX, newY)
                end
            end)
        end
        -- fatter, finger-friendly grab zones on touch devices
        local E = IS_MOBILE and 14 or 6         -- edge thickness
        local C = IS_MOBILE and 22 or 12        -- corner size
        local o = E / 2
        handle("Top",    UDim2.new(0, 10, 0, -o),  UDim2.new(1, -20, 0, E), 0, -1)
        handle("Bottom", UDim2.new(0, 10, 1, -o),  UDim2.new(1, -20, 0, E), 0, 1)
        handle("Left",   UDim2.new(0, -o, 0, 10),  UDim2.new(0, E, 1, -20), -1, 0)
        handle("Right",  UDim2.new(1, -o, 0, 10),  UDim2.new(0, E, 1, -20), 1, 0)
        handle("TL",     UDim2.new(0, -o, 0, -o),  UDim2.new(0, C, 0, C), -1, -1)
        handle("TR",     UDim2.new(1, -C + o, 0, -o),  UDim2.new(0, C, 0, C), 1, -1)
        handle("BL",     UDim2.new(0, -o, 1, -C + o),  UDim2.new(0, C, 0, C), -1, 1)
        handle("BR",     UDim2.new(1, -C + o, 1, -C + o),  UDim2.new(0, C, 0, C), 1, 1)
    end

    --── Open / close / minimize / toggle ────────────────────────────────
    local savedH = H
    function Window:Minimize(state)
        if state == nil then state = not Window.Minimized end
        Window.Minimized = state
        if state then
            savedH = Root.Size.Y.Offset
            Tween(Root, { Size = UDim2.fromOffset(Root.Size.X.Offset, TOPBAR_H + 2) }, 0.3)
        else
            Tween(Root, { Size = UDim2.fromOffset(Root.Size.X.Offset, savedH) }, 0.3)
        end
    end
    minimizeBtn.MouseButton1Click:Connect(function() Window:Minimize() end)

    --── Floating "open" pill, shown while the window is hidden ──────────
    local OpenBtn = New("TextButton", {
        Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.new(0, 0, 0, 40),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 0.1,
        Visible = false, ZIndex = 150, Parent = ScreenGui,
    })
    Bind(OpenBtn, { BackgroundColor3 = "Background" })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = OpenBtn })
    local obStroke = New("UIStroke", { Thickness = 1.5, Parent = OpenBtn })
    local obGrad = New("UIGradient", { Rotation = 45, Parent = obStroke })
    Bind(obGrad, { Color = "AccentSequence" })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 9), Parent = OpenBtn,
    })
    Padding(OpenBtn, 0, 0, 8, 14)
    local obIcon = New("Frame", { Size = UDim2.new(0, 26, 0, 26), LayoutOrder = 1, ZIndex = 151, Parent = OpenBtn })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = obIcon })
    Bind(obIcon, { BackgroundColor3 = "Accent" })
    local obIconGrad = New("UIGradient", { Rotation = 45, Parent = obIcon })
    Bind(obIconGrad, { Color = "AccentSequence" })
    if iconImage then
        New("ImageLabel", {
            BackgroundTransparency = 1, Image = iconImage,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 152, Parent = obIcon,
        }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    else
        New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "H",
            Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
            ZIndex = 152, Parent = obIcon,
        })
    end
    local obLabel = New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X, Text = "Open " .. Window.Name,
        Font = Enum.Font.GothamBold, TextSize = 12, LayoutOrder = 2,
        ZIndex = 151, Parent = OpenBtn,
    })
    Bind(obLabel, { TextColor3 = "Text" })

    -- draggable; a press that doesn't move reopens the window
    do
        local dragging, dragInput, dragStart, startPos, moved
        OpenBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging, moved = true, false
                dragStart = input.Position
                startPos = OpenBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if not moved then Window:Show() end
                    end
                end)
            end
        end)
        OpenBtn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local d = input.Position - dragStart
                if d.Magnitude > 5 then moved = true end
                OpenBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
    end

    function Window:Show()
        Window.Hidden = false
        Root.Visible = true
        OpenBtn.Visible = false
        popScale.Scale = 0.85
        Tween(popScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
    end

    function Window:Hide()
        Window.Hidden = true
        Tween(popScale, { Scale = 0.85 }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.18, function()
            if Window.Hidden then
                Root.Visible = false
                popScale.Scale = 1
                OpenBtn.Visible = true
            end
        end)
    end

    function Window:Toggle()
        if Window.Hidden then Window:Show() else Window:Hide() end
    end

    function Window:Destroy()
        perfConn:Disconnect()
        Root:Destroy()
    end

    closeBtn.MouseButton1Click:Connect(function()
        Window:Hide()
        HadoUI:Notify({
            Title = "Window hidden",
            Content = IS_MOBILE and "Tap the Open button to reopen."
                or ("Press " .. Window.ToggleKey.Name .. " to reopen."),
            Type = "Information", Duration = 4,
        })
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Window.ToggleKey then Window:Toggle() end
    end)

    --── Dialog / popup ──────────────────────────────────────────────────
    -- Window:Dialog({ Title, Content, Icon = "circle-alert",
    --                 Buttons = { { Title="Confirm", Variant="Primary", Callback=fn }, { Title="Cancel" } } })
    function Window:Dialog(dcfg)
        dcfg = dcfg or {}
        local overlay = New("TextButton", {
            Text = "", AutoButtonColor = false,
            BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 180, Parent = ScreenGui,
        })
        local card = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(340, 0), AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 181, Parent = overlay,
        })
        Bind(card, { BackgroundColor3 = "Surface" })
        Corner(card, 14); Stroke(card, "Stroke", 1, 0.15)
        local cardScale = New("UIScale", { Scale = 0.9, Parent = card })
        Padding(card, 18, 18, 18, 18)
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = card })

        -- header (icon + title)
        local header = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = 1, ZIndex = 182, Parent = card,
        })
        local hIcon = dcfg.Icon and IconLabel(dcfg.Icon, 18, "AccentSoft", header, {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), ZIndex = 183,
        })
        local hTitle = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, hIcon and 26 or 0, 0, 0),
            Size = UDim2.new(1, hIcon and -26 or 0, 1, 0), Text = dcfg.Title or "Dialog",
            Font = Enum.Font.GothamBold, TextSize = 14, RichText = true,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 183, Parent = header,
        })
        Bind(hTitle, { TextColor3 = "Text" })

        if dcfg.Content then
            local content = New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Text = dcfg.Content,
                Font = Enum.Font.Gotham, TextSize = 12.5, RichText = true, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 182, Parent = card,
            })
            Bind(content, { TextColor3 = "SubText" })
        end

        local closed = false
        local function close()
            if closed then return end
            closed = true
            Tween(overlay, { BackgroundTransparency = 1 }, 0.2)
            Tween(cardScale, { Scale = 0.9 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.2, function() overlay:Destroy() end)
        end

        -- buttons row
        local buttons = dcfg.Buttons or { { Title = "OK", Variant = "Primary" } }
        local row = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = 3, ZIndex = 182, Parent = card,
        }, {
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
            }),
        })
        for i, bcfg in ipairs(buttons) do
            local primary = (bcfg.Variant or (i == 1 and "Primary")) == "Primary"
            local btn = New("TextButton", {
                Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X,
                Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 183, Parent = row,
            })
            Corner(btn, 8); Padding(btn, 0, 0, 14, 14)
            if primary then
                Bind(btn, { BackgroundColor3 = "Accent" })
                local g = New("UIGradient", { Rotation = 90, Parent = btn })
                Bind(g, { Color = "AccentSequence" })
            else
                Bind(btn, { BackgroundColor3 = "Surface2" })
                Stroke(btn, "StrokeSoft", 1, 0.4)
            end
            local bl = New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X, Text = bcfg.Title or "OK",
                Font = Enum.Font.GothamBold, TextSize = 11.5, ZIndex = 184, Parent = btn,
            })
            if primary then bl.TextColor3 = Color3.new(1, 1, 1)
            else Bind(bl, { TextColor3 = "Text" }) end
            btn.MouseButton1Click:Connect(function()
                close()
                safeCallback(bcfg.Callback)
            end)
        end

        Tween(overlay, { BackgroundTransparency = 0.45 }, 0.25)
        Tween(cardScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        return { Close = close }
    end

    --── Tab system ──────────────────────────────────────────────────────
    local ELEMENT_H = 40

    local function styleElement(frame)
        Bind(frame, { BackgroundColor3 = "Element" })
        Corner(frame, 9)
        local st = Stroke(frame, "StrokeSoft", 1, 0.25)
        frame.MouseEnter:Connect(function()
            -- hover: lift the bg and warm the border toward the accent
            Tween(st, { Color = Theme.Accent, Transparency = 0.55 }, 0.18)
            if not frame:GetAttribute("NoHover") then
                Tween(frame, { BackgroundColor3 = Theme.ElementHover }, 0.18)
            end
        end)
        frame.MouseLeave:Connect(function()
            Tween(st, { Color = Theme.StrokeSoft, Transparency = 0.25 }, 0.18)
            Tween(frame, { BackgroundColor3 = Theme.Element }, 0.18)
        end)
    end

    -- gives an element :Lock(text) / :Unlock() with a dim overlay
    local function makeLockable(f, element, opts)
        local overlay, lockText
        function element:Lock(text)
            if not overlay then
                overlay = New("TextButton", {
                    Text = "", AutoButtonColor = false, BackgroundTransparency = 0.25,
                    Size = UDim2.new(1, 0, 1, 0), ZIndex = 12, Parent = f,
                })
                Bind(overlay, { BackgroundColor3 = "Element" })
                Corner(overlay, 9)
                local holder = New("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 13, Parent = overlay,
                }, {
                    New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6),
                    }),
                })
                IconLabel("lock", 13, "SubText", holder, { LayoutOrder = 1, ZIndex = 14 })
                lockText = New("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 16),
                    AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2,
                    Font = Enum.Font.GothamMedium, TextSize = 11.5, ZIndex = 14, Parent = holder,
                })
                Bind(lockText, { TextColor3 = "SubText" })
            end
            lockText.Text = text or (opts and opts.LockedTitle) or "Locked"
            overlay.Visible = true
        end
        function element:Unlock()
            if overlay then overlay.Visible = false end
        end
        if opts and opts.Locked then element:Lock() end
        return element
    end

    local function registerFlag(flag, element, default)
        if flag then
            HadoUI.Options[flag] = element
            HadoUI.Flags[flag] = default
        end
        element._default = default
    end

    function Window:AddTab(tabInfo)
        -- accepts AddTab("Name") or AddTab({ Name = "Name", Icon = "house" })
        local tabName = type(tabInfo) == "table" and (tabInfo.Name or tabInfo.Title or "Tab") or tostring(tabInfo)
        local tabIcon = type(tabInfo) == "table" and tabInfo.Icon or nil
        local Tab = { Name = tabName, Elements = {} }

        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, Parent = TabList,
        })
        local btnIcon = tabIcon and IconLabel(tabIcon, 16, "SubText", btn, {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
        })
        local textX = btnIcon and 36 or 14
        local btnLabel = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, textX, 0, 0),
            Size = UDim2.new(1, -textX, 1, 0), Text = tabName,
            Font = Enum.Font.GothamMedium, TextSize = 12.5,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })
        Bind(btnLabel, { TextColor3 = "SubText" })
        Tab.ButtonLabel = btnLabel
        Tab.ButtonIcon = btnIcon

        local page = New("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0), Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Pages,
        })
        Bind(page, { ScrollBarImageColor3 = "Accent" })
        local pageLayout = New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = page,
        })
        local pagePad = Padding(page, 12, 12, 14, 14)
        -- cap the content column (max ~780px, centered) so elements don't
        -- stretch absurdly wide when the window is maximized or resized large
        local MAX_COLUMN = 780
        page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local s = math.max(Scale.Scale * popScale.Scale, 0.01)
            local w = page.AbsoluteSize.X / s
            local side = math.max(14, math.floor((w - MAX_COLUMN) / 2))
            pagePad.PaddingLeft = UDim.new(0, side)
            pagePad.PaddingRight = UDim.new(0, side)
        end)
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
        end)

        Tab.Button, Tab.Page = btn, page

        local function select()
            Window.ActiveTab = Tab
            movePill(btn)
            for _, other in ipairs(Window.Tabs) do
                local active = other == Tab
                other.Page.Visible = active
                Tween(other.ButtonLabel, { TextColor3 = active and Theme.Text or Theme.SubText }, 0.2)
                if other.ButtonIcon then
                    Tween(other.ButtonIcon, { ImageColor3 = active and Theme.Accent or Theme.SubText }, 0.2)
                end
                if active then
                    other.Page.Position = UDim2.new(0, 0, 0, 10)
                    Tween(other.Page, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)
                end
            end
        end
        btn.MouseButton1Click:Connect(select)
        btn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then Tween(btnLabel, { TextColor3 = Theme.Text }, 0.15) end
        end)
        btn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then Tween(btnLabel, { TextColor3 = Theme.SubText }, 0.15) end
        end)

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then task.defer(select) end -- defer so layout has resolved
        Tab.Select = select

        ------------------------------------------------------------------
        -- Shared element scaffolding
        ------------------------------------------------------------------
        local function baseElement(height, noHover)
            local f = New("Frame", {
                Size = UDim2.new(1, 0, 0, height or ELEMENT_H),
                ClipsDescendants = true, Parent = page,
            })
            if noHover then f:SetAttribute("NoHover", true) end
            styleElement(f)
            return f
        end

        -- rowH: taller row when the element carries a description line
        local function rowH(opts) return (opts and opts.Description) and 56 or ELEMENT_H end

        local function elementTitle(parent, text, desc)
            -- fixed header height (not 1,0) so titles stay put when elements expand
            local l = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, desc and 10 or 0),
                Size = desc and UDim2.new(1, -140, 0, 14) or UDim2.new(1, -140, 0, ELEMENT_H),
                Text = text, Font = Enum.Font.GothamMedium, TextSize = 12.5,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
            })
            Bind(l, { TextColor3 = "Text" })
            if desc then
                local d = New("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 28),
                    Size = UDim2.new(1, -140, 0, 12), Text = desc,
                    Font = Enum.Font.Gotham, TextSize = 11,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
                })
                Bind(d, { TextColor3 = "SubText" })
            end
            return l
        end

        ------------------------------------------------------------------
        -- Section / Label / Paragraph / Divider
        ------------------------------------------------------------------
        function Tab:AddSection(text)
            local holder = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = page,
            })
            local dot = New("Frame", {
                Size = UDim2.new(0, 5, 0, 5), Position = UDim2.new(0, 1, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0, Parent = holder,
            }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            Bind(dot, { BackgroundColor3 = "Accent" })
            local lbl = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 13, 0, 0),
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X, Text = text:upper(),
                Font = Enum.Font.GothamBold, TextSize = 10.5,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = holder,
            })
            Bind(lbl, { TextColor3 = "AccentSoft" })
            local line = New("Frame", {
                BackgroundTransparency = 0.5, BorderSizePixel = 0,
                Position = UDim2.new(0, lbl.TextBounds.X + 23, 0.5, 0),
                Size = UDim2.new(1, -(lbl.TextBounds.X + 23), 0, 1), Parent = holder,
            })
            Bind(line, { BackgroundColor3 = "Stroke" })
            lbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
                line.Position = UDim2.new(0, lbl.TextBounds.X + 23, 0.5, 0)
                line.Size = UDim2.new(1, -(lbl.TextBounds.X + 23), 0, 1)
            end)
            return { SetText = function(_, t) lbl.Text = t:upper() end }
        end

        function Tab:AddDivider()
            New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8), Parent = page }, {
                Bind(New("Frame", {
                    BackgroundTransparency = 0.5, BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 1),
                }), { BackgroundColor3 = "Stroke" }),
            })
        end

        function Tab:AddLabel(text)
            local l = New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = page,
            })
            Bind(l, { TextColor3 = "SubText" })
            Padding(l, 0, 0, 4, 0)
            return { SetText = function(_, t) l.Text = t end }
        end

        function Tab:AddParagraph(opts)
            local f = baseElement(0, true)
            f.AutomaticSize = Enum.AutomaticSize.Y
            f.Size = UDim2.new(1, 0, 0, 0)
            local t = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 10),
                Size = UDim2.new(1, -24, 0, 15), Text = opts.Title or "Paragraph",
                Font = Enum.Font.GothamBold, TextSize = 12.5, RichText = true,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
            })
            Bind(t, { TextColor3 = "Text" })
            local c = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 28),
                Size = UDim2.new(1, -24, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Text = opts.Content or "", Font = Enum.Font.Gotham, TextSize = 12, RichText = true,
                TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top, Parent = f,
            })
            Bind(c, { TextColor3 = "SubText" })
            New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12),
                Position = UDim2.new(0, 0, 1, 0), Parent = c })
            return {
                SetTitle = function(_, v) t.Text = v end,
                SetContent = function(_, v) c.Text = v end,
            }
        end

        ------------------------------------------------------------------
        -- Button
        ------------------------------------------------------------------
        function Tab:AddButton(opts)
            local f = baseElement(rowH(opts))
            elementTitle(f, opts.Name or "Button", opts.Description)
            local chip = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X,
                Text = "", AutoButtonColor = false, Parent = f,
            })
            Bind(chip, { BackgroundColor3 = "Accent" })
            Corner(chip, 7); Padding(chip, 0, 0, 12, 12)
            local g = New("UIGradient", { Rotation = 90, Parent = chip })
            Bind(g, { Color = "AccentSequence" })
            New("TextLabel", { -- child label so the bg gradient doesn't tint the text
                BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X, Text = opts.ButtonText or "Execute",
                Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = chip,
            })
            chip.MouseEnter:Connect(function() Tween(chip, { BackgroundColor3 = Theme.AccentSoft }, 0.15) end)
            chip.MouseLeave:Connect(function() Tween(chip, { BackgroundColor3 = Theme.Accent }, 0.15) end)
            local clickTarget = New("TextButton", { -- whole row clickable too
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = f,
            })
            local function fire()
                Tween(chip, { Size = UDim2.new(0, 0, 0, 20) }, 0.08)
                task.delay(0.09, function() Tween(chip, { Size = UDim2.new(0, 0, 0, 24) }, 0.12) end)
                safeCallback(opts.Callback)
            end
            chip.MouseButton1Click:Connect(fire)
            clickTarget.MouseButton1Click:Connect(fire)
            return makeLockable(f, { Fire = fire }, opts)
        end

        ------------------------------------------------------------------
        -- Toggle
        ------------------------------------------------------------------
        function Tab:AddToggle(opts)
            local f = baseElement(rowH(opts))
            elementTitle(f, opts.Name or "Toggle", opts.Description)
            local state = opts.Default == true

            local track = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 38, 0, 20), Parent = f,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
            local trackStroke = Stroke(track, "StrokeSoft", 1, 0.3)
            local knob = New("Frame", {
                Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
            local hit = New("TextButton", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = f,
            })

            local element = {}
            local function render(instant)
                local props = {
                    BackgroundColor3 = state and Theme.Accent or Theme.Background,
                }
                local knobPos = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                if instant then
                    track.BackgroundColor3 = props.BackgroundColor3
                    knob.Position = knobPos
                    trackStroke.Color = state and Theme.Accent or Theme.StrokeSoft
                    trackStroke.Transparency = state and 0.35 or 0.3
                else
                    Tween(track, props, 0.2)
                    Tween(knob, { Position = knobPos }, 0.2, Enum.EasingStyle.Back)
                    -- accent glow ring while enabled
                    Tween(trackStroke, {
                        Color = state and Theme.Accent or Theme.StrokeSoft,
                        Transparency = state and 0.35 or 0.3,
                    }, 0.2)
                end
            end
            function element:Set(v)
                state = v == true
                if opts.Flag then HadoUI.Flags[opts.Flag] = state end
                render()
                safeCallback(opts.Callback, state)
            end
            function element:GetState() return state end
            hit.MouseButton1Click:Connect(function() element:Set(not state) end)

            registerFlag(opts.Flag, element, state)
            render(true)
            if state then safeCallback(opts.Callback, true) end
            return makeLockable(f, element, opts)
        end

        ------------------------------------------------------------------
        -- Slider
        ------------------------------------------------------------------
        function Tab:AddSlider(opts)
            local min, max = opts.Min or 0, opts.Max or 100
            local step = opts.Step or 1
            local suffix = opts.Suffix or ""
            local value = math.clamp(opts.Default or min, min, max)

            local descOff = opts.Description and 15 or 0
            local f = baseElement(52 + descOff, true)
            local title = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -100, 0, 15), Text = opts.Name or "Slider",
                Font = Enum.Font.GothamMedium, TextSize = 12.5,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
            })
            Bind(title, { TextColor3 = "Text" })
            if opts.Description then
                local d = New("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 24),
                    Size = UDim2.new(1, -100, 0, 12), Text = opts.Description,
                    Font = Enum.Font.Gotham, TextSize = 11,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
                })
                Bind(d, { TextColor3 = "SubText" })
            end
            -- current value shown in a small chip
            local valueLabel = New("TextLabel", {
                BackgroundTransparency = 0.4, AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 7), Size = UDim2.new(0, 0, 0, 17),
                AutomaticSize = Enum.AutomaticSize.X,
                Font = Enum.Font.GothamBold, TextSize = 11, Parent = f,
            })
            Bind(valueLabel, { TextColor3 = "AccentSoft", BackgroundColor3 = "Surface2" })
            Corner(valueLabel, 6); Padding(valueLabel, 0, 0, 7, 7)

            local bar = New("Frame", {
                Position = UDim2.new(0, 12, 0, 34 + descOff), Size = UDim2.new(1, -24, 0, 6), Parent = f,
            })
            Bind(bar, { BackgroundColor3 = "Background" }) -- darker inset so the track reads clearly
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
            local fill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), Parent = bar })
            Bind(fill, { BackgroundColor3 = "Accent" })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
            local fg = New("UIGradient", { Parent = fill })
            Bind(fg, { Color = "AccentSequence" })
            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 3, Parent = bar,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
            Shadow(knob, 10, 0.6)

            local element = {}
            local function render(instant)
                local a = (value - min) / math.max(max - min, 1e-9)
                local target = UDim2.new(a, 0, 1, 0)
                local kTarget = UDim2.new(a, 0, 0.5, 0)
                if instant then fill.Size, knob.Position = target, kTarget
                else Tween(fill, { Size = target }, 0.1); Tween(knob, { Position = kTarget }, 0.1) end
                local shown = math.floor(value / step + 0.5) * step
                if step >= 1 then shown = math.floor(shown + 0.5) end
                valueLabel.Text = tostring(shown) .. suffix
            end
            function element:Set(v)
                value = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
                if opts.Flag then HadoUI.Flags[opts.Flag] = value end
                render()
                safeCallback(opts.Callback, value)
            end

            local sliding = false
            local function applyFromX(x)
                local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                element:Set(min + a * (max - min))
            end
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    applyFromX(input.Position.X)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then sliding = false end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                    applyFromX(input.Position.X)
                end
            end)
            -- widen hitbox
            New("TextButton", { BackgroundTransparency = 1, Text = "",
                Position = UDim2.new(0, 0, 0, -8), Size = UDim2.new(1, 0, 0, 22), Parent = bar,
            }).InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    applyFromX(input.Position.X)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then sliding = false end
                    end)
                end
            end)

            registerFlag(opts.Flag, element, value)
            if opts.Flag then HadoUI.Flags[opts.Flag] = value end
            render(true)
            return makeLockable(f, element, opts)
        end

        ------------------------------------------------------------------
        -- Dropdown (single + multi share one builder)
        ------------------------------------------------------------------
        local function buildDropdown(opts, multi)
            local options = opts.Options or {}
            local selected = multi and {} or opts.Default
            if multi then
                for _, v in ipairs(opts.Default or {}) do selected[v] = true end
            end

            local LIST_MAX = 150
            local baseH = rowH(opts)
            local f = baseElement(baseH, true)
            f.ClipsDescendants = true
            elementTitle(f, opts.Name or "Dropdown", opts.Description)

            local valueBtn = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, (baseH - 24) / 2),
                Size = UDim2.new(0, 150, 0, 24), Text = "", AutoButtonColor = false, Parent = f,
            })
            Bind(valueBtn, { BackgroundColor3 = "Surface2" })
            Corner(valueBtn, 7); Stroke(valueBtn, "StrokeSoft", 1, 0.4)
            local valueText = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 9, 0, 0),
                Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.Gotham, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = valueBtn,
            })
            Bind(valueText, { TextColor3 = "SubText" })
            local arrow = New("TextLabel", {
                BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -7, 0.5, 0), Size = UDim2.new(0, 12, 0, 12),
                Text = "▾", Font = Enum.Font.GothamBold, TextSize = 11, Parent = valueBtn,
            })
            Bind(arrow, { TextColor3 = "AccentSoft" })

            -- search box (auto-appears for long lists, or force with Search = true)
            local function hasSearch()
                return opts.Search == true or (opts.Search ~= false and #options >= 8)
            end
            local searchHolder = New("Frame", {
                Position = UDim2.new(0, 10, 0, baseH + 2), Size = UDim2.new(1, -20, 0, 26),
                Visible = false, Parent = f,
            })
            Bind(searchHolder, { BackgroundColor3 = "Surface2" })
            Corner(searchHolder, 7); Stroke(searchHolder, "StrokeSoft", 1, 0.4)
            local searchIcon = IconLabel("search", 12, "SubText", searchHolder, {
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0),
            })
            local searchBox = New("TextBox", {
                BackgroundTransparency = 1, Position = UDim2.new(0, searchIcon and 26 or 9, 0, 0),
                Size = UDim2.new(1, searchIcon and -34 or -18, 1, 0), Text = "",
                PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = searchHolder,
            })
            Bind(searchBox, { TextColor3 = "Text", PlaceholderColor3 = "SubText" })

            local listFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1, BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, baseH + 2), Size = UDim2.new(1, -20, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, Parent = f,
            })
            Bind(listFrame, { ScrollBarImageColor3 = "Accent" })
            local listLayout = New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = listFrame,
            })
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
            end)

            local open = false
            local element = {}
            local optionButtons = {}

            local function displayText()
                if multi then
                    local picked = {}
                    for _, opt in ipairs(options) do
                        if selected[opt] then table.insert(picked, opt) end
                    end
                    return #picked > 0 and table.concat(picked, ", ") or "None"
                end
                return selected ~= nil and tostring(selected) or "None"
            end

            local function currentValue()
                if not multi then return selected end
                local picked = {}
                for _, opt in ipairs(options) do
                    if selected[opt] then table.insert(picked, opt) end
                end
                return picked
            end

            local function refreshVisuals()
                valueText.Text = displayText()
                for opt, btn in pairs(optionButtons) do
                    local on = multi and selected[opt] == true or selected == opt
                    Tween(btn.Label, { TextColor3 = on and Theme.Text or Theme.SubText }, 0.15)
                    Tween(btn.Check, { BackgroundTransparency = on and 0 or 1 }, 0.15)
                    Tween(btn.Frame, { BackgroundTransparency = on and 0.4 or 1 }, 0.15)
                end
            end

            local function applyFilter()
                local q = searchBox.Text:lower()
                for opt, b in pairs(optionButtons) do
                    b.Frame.Visible = (q == "" or tostring(opt):lower():find(q, 1, true) ~= nil)
                end
            end
            searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)

            local function setOpen(v)
                open = v
                local withSearch = hasSearch()
                local searchOff = withSearch and 30 or 0
                searchHolder.Visible = withSearch
                listFrame.Position = UDim2.new(0, 10, 0, baseH + 2 + searchOff)
                local listH = math.min(#options * 27 + 4, LIST_MAX)
                Tween(f, { Size = UDim2.new(1, 0, 0, open and (baseH + 6 + listH + searchOff) or baseH) }, 0.25)
                Tween(arrow, { Rotation = open and 180 or 0 }, 0.25)
                listFrame.Size = UDim2.new(1, -20, 0, listH)
                if not open and searchBox.Text ~= "" then searchBox.Text = "" end
            end

            local function rebuild()
                for _, b in pairs(optionButtons) do b.Frame:Destroy() end
                optionButtons = {}
                for i, opt in ipairs(options) do
                    local ob = New("TextButton", {
                        Size = UDim2.new(1, -4, 0, 24), Text = "", AutoButtonColor = false,
                        BackgroundTransparency = 1, LayoutOrder = i, Parent = listFrame,
                    })
                    Bind(ob, { BackgroundColor3 = "Surface2" })
                    Corner(ob, 6)
                    local check = New("Frame", {
                        Size = UDim2.new(0, 5, 0, 12), Position = UDim2.new(0, 4, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Parent = ob,
                    })
                    Bind(check, { BackgroundColor3 = "Accent" })
                    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = check })
                    local ol = New("TextLabel", {
                        BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0), Text = tostring(opt),
                        Font = Enum.Font.Gotham, TextSize = 11.5,
                        TextXAlignment = Enum.TextXAlignment.Left, Parent = ob,
                    })
                    Bind(ol, { TextColor3 = "SubText" })
                    optionButtons[opt] = { Frame = ob, Label = ol, Check = check }
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt] or nil
                        else
                            selected = opt
                            setOpen(false)
                        end
                        if opts.Flag then HadoUI.Flags[opts.Flag] = currentValue() end
                        refreshVisuals()
                        safeCallback(opts.Callback, currentValue())
                    end)
                end
                listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
                refreshVisuals()
            end

            valueBtn.MouseButton1Click:Connect(function() setOpen(not open) end)

            function element:Set(v)
                if multi then
                    selected = {}
                    for _, opt in ipairs(type(v) == "table" and v or { v }) do selected[opt] = true end
                else
                    selected = v
                end
                if opts.Flag then HadoUI.Flags[opts.Flag] = currentValue() end
                refreshVisuals()
                safeCallback(opts.Callback, currentValue())
            end
            function element:Refresh(newOptions, keep)
                options = newOptions or {}
                if not keep then
                    if multi then selected = {} else selected = nil end
                end
                rebuild()
            end

            registerFlag(opts.Flag, element, currentValue())
            if opts.Flag then HadoUI.Flags[opts.Flag] = currentValue() end
            rebuild()
            return makeLockable(f, element, opts)
        end

        function Tab:AddDropdown(opts) return buildDropdown(opts, false) end
        function Tab:AddMultiDropdown(opts) return buildDropdown(opts, true) end

        ------------------------------------------------------------------
        -- Keybind
        ------------------------------------------------------------------
        function Tab:AddKeybind(opts)
            local key = opts.Default -- Enum.KeyCode or nil
            local f = baseElement(rowH(opts))
            elementTitle(f, opts.Name or "Keybind", opts.Description)
            local chip = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X,
                Text = key and key.Name or "None", Font = Enum.Font.GothamBold, TextSize = 11,
                AutoButtonColor = false, Parent = f,
            })
            Bind(chip, { BackgroundColor3 = "Surface2", TextColor3 = "AccentSoft" })
            Corner(chip, 7); Stroke(chip, "StrokeSoft", 1, 0.4); Padding(chip, 0, 0, 10, 10)

            local listening = false
            local element = {}
            function element:Set(newKey)
                key = newKey
                chip.Text = key and key.Name or "None"
                if opts.Flag then HadoUI.Flags[opts.Flag] = key and key.Name or "None" end
                safeCallback(opts.ChangedCallback, key)
            end
            chip.MouseButton1Click:Connect(function()
                listening = true
                chip.Text = "..."
            end)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        element:Set(nil)
                    else
                        element:Set(input.KeyCode)
                    end
                    return
                end
                if gpe or listening then return end
                if key and input.KeyCode == key then
                    safeCallback(opts.Callback, key)
                end
            end)

            registerFlag(opts.Flag, element, key and key.Name or "None")
            if opts.Flag then HadoUI.Flags[opts.Flag] = key and key.Name or "None" end
            return makeLockable(f, element, opts)
        end

        ------------------------------------------------------------------
        -- Color Picker
        ------------------------------------------------------------------
        function Tab:AddColorPicker(opts)
            local color = opts.Default or Theme.Accent
            local h, s, v = color:ToHSV()

            local EXPAND = 128
            local baseH = rowH(opts)
            local f = baseElement(baseH, true)
            f.ClipsDescendants = true
            elementTitle(f, opts.Name or "Color", opts.Description)

            local swatch = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, (baseH - 24) / 2),
                Size = UDim2.new(0, 40, 0, 24), Text = "", AutoButtonColor = false,
                BackgroundColor3 = color, Parent = f,
            })
            Corner(swatch, 7); Stroke(swatch, "StrokeSoft", 1, 0.3)

            -- SV square
            local sv = New("ImageButton", {
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                Position = UDim2.new(0, 12, 0, baseH + 4), Size = UDim2.new(1, -52, 0, 112),
                AutoButtonColor = false, Parent = f,
            })
            Corner(sv, 6)
            New("Frame", { -- white -> transparent (saturation)
                Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0, Parent = sv,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 6) }),
                New("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
                    }),
                }),
            })
            New("Frame", { -- transparent -> black (value)
                Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0, Parent = sv,
            }, {
                New("UICorner", { CornerRadius = UDim.new(0, 6) }),
                New("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
                    }),
                }),
            })
            local svCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5, Parent = sv,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
            New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.4, Parent = svCursor })

            -- Hue bar
            local hue = New("ImageButton", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, baseH + 4),
                Size = UDim2.new(0, 14, 0, 112), AutoButtonColor = false,
                BackgroundColor3 = Color3.new(1, 1, 1), Parent = f,
            })
            Corner(hue, 6)
            local hueSeq = {}
            for i = 0, 6 do
                table.insert(hueSeq, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
            end
            New("UIGradient", { Color = ColorSequence.new(hueSeq), Rotation = 90, Parent = hue })
            local hueCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(1, 4, 0, 4), BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 5, Parent = hue,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueCursor })

            local open = false
            local element = {}
            local function render()
                color = Color3.fromHSV(h, s, v)
                swatch.BackgroundColor3 = color
                sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                hueCursor.Position = UDim2.new(0.5, 0, h, 0)
            end
            local function push()
                if opts.Flag then HadoUI.Flags[opts.Flag] = "#" .. color:ToHex() end
                safeCallback(opts.Callback, color)
            end
            function element:Set(c)
                if typeof(c) == "string" then c = Color3.fromHex(c) end
                h, s, v = c:ToHSV()
                render(); push()
            end
            function element:GetColor() return color end

            swatch.MouseButton1Click:Connect(function()
                open = not open
                Tween(f, { Size = UDim2.new(1, 0, 0, open and (baseH + EXPAND) or baseH) }, 0.25)
            end)

            local function bindPad(pad, onMove)
                local held = false
                pad.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        held = true
                        onMove(input.Position)
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then held = false end
                        end)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if held and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        onMove(input.Position)
                    end
                end)
            end
            bindPad(sv, function(p)
                s = math.clamp((p.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
                v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
                render(); push()
            end)
            bindPad(hue, function(p)
                h = math.clamp((p.Y - hue.AbsolutePosition.Y) / math.max(hue.AbsoluteSize.Y, 1), 0, 1)
                render(); push()
            end)

            registerFlag(opts.Flag, element, "#" .. color:ToHex())
            if opts.Flag then HadoUI.Flags[opts.Flag] = "#" .. color:ToHex() end
            render()
            return makeLockable(f, element, opts)
        end

        ------------------------------------------------------------------
        -- Input box
        ------------------------------------------------------------------
        function Tab:AddInput(opts)
            local f = baseElement(rowH(opts))
            elementTitle(f, opts.Name or "Input", opts.Description)
            local boxHolder = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 150, 0, 24), Parent = f,
            })
            Bind(boxHolder, { BackgroundColor3 = "Surface2" })
            Corner(boxHolder, 7)
            local boxStroke = Stroke(boxHolder, "StrokeSoft", 1, 0.4)
            local box = New("TextBox", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 9, 0, 0),
                Size = UDim2.new(1, -18, 1, 0), Text = opts.Default or "",
                PlaceholderText = opts.Placeholder or "...", Font = Enum.Font.Gotham,
                TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false, Parent = boxHolder,
            })
            Bind(box, { TextColor3 = "Text", PlaceholderColor3 = "SubText" })
            box.Focused:Connect(function()
                Tween(boxStroke, { Color = Theme.Accent, Transparency = 0 }, 0.15)
            end)
            box.FocusLost:Connect(function(enterPressed)
                Tween(boxStroke, { Color = Theme.StrokeSoft, Transparency = 0.4 }, 0.15)
                if opts.Flag then HadoUI.Flags[opts.Flag] = box.Text end
                safeCallback(opts.Callback, box.Text, enterPressed)
            end)

            local element = {}
            function element:Set(text)
                box.Text = tostring(text)
                if opts.Flag then HadoUI.Flags[opts.Flag] = box.Text end
                safeCallback(opts.Callback, box.Text, false)
            end
            function element:GetText() return box.Text end

            registerFlag(opts.Flag, element, box.Text)
            if opts.Flag then HadoUI.Flags[opts.Flag] = box.Text end
            return makeLockable(f, element, opts)
        end

        ------------------------------------------------------------------
        -- Discord server card (live member/online counts via Discord API)
        ------------------------------------------------------------------
        function Tab:AddDiscord(opts)
            opts = opts or {}
            local invite = tostring(opts.Invite or ""):gsub("^.*/", "") -- accepts code or full URL
            local link = "https://discord.gg/" .. invite

            local f = baseElement(64, true)

            -- server icon (real icon loads async; letter placeholder until then)
            local iconHolder = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 40), Parent = f,
            })
            Bind(iconHolder, { BackgroundColor3 = "Surface2" })
            Corner(iconHolder, 11); Stroke(iconHolder, "StrokeSoft", 1, 0.4)
            local iconLetter = New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "D",
                Font = Enum.Font.GothamBlack, TextSize = 16, Parent = iconHolder,
            })
            Bind(iconLetter, { TextColor3 = "AccentSoft" })

            local nameL = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 62, 0, 13),
                Size = UDim2.new(1, -160, 0, 16), Text = opts.Title or "Discord Server",
                Font = Enum.Font.GothamBold, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
            })
            Bind(nameL, { TextColor3 = "Text" })

            local countL = New("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.new(0, 62, 0, 33),
                Size = UDim2.new(1, -160, 0, 14), RichText = true,
                Text = "Fetching server info...", Font = Enum.Font.Gotham, TextSize = 11.5,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
            })
            Bind(countL, { TextColor3 = "SubText" })

            -- join button
            local joinBtn = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X,
                Text = "", AutoButtonColor = false, Parent = f,
            })
            Bind(joinBtn, { BackgroundColor3 = "Accent" })
            Corner(joinBtn, 8); Padding(joinBtn, 0, 0, 13, 13)
            local jg = New("UIGradient", { Rotation = 90, Parent = joinBtn })
            Bind(jg, { Color = "AccentSequence" })
            New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X, Text = opts.ButtonText or "Join",
                Font = Enum.Font.GothamBold, TextSize = 11.5,
                TextColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = joinBtn,
            })
            joinBtn.MouseEnter:Connect(function() Tween(joinBtn, { BackgroundColor3 = Theme.AccentSoft }, 0.15) end)
            joinBtn.MouseLeave:Connect(function() Tween(joinBtn, { BackgroundColor3 = Theme.Accent }, 0.15) end)
            joinBtn.MouseButton1Click:Connect(function()
                local copied = pcall(function() (setclipboard or toclipboard)(link) end)
                HadoUI:Notify({
                    Title = nameL.Text,
                    Content = copied and "Invite link copied to clipboard." or link,
                    Type = "Success", Icon = "link",
                })
            end)

            -- live stats (refreshes periodically while the UI exists)
            local function refresh()
                local res = httpRequest({
                    Url = "https://discord.com/api/v10/invites/" .. invite .. "?with_counts=true",
                    Method = "GET",
                    Headers = { ["Accept"] = "application/json" },
                })
                if not (res and res.Body) then
                    countL.Text = "discord.gg/" .. invite
                    return false
                end
                local ok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if not (ok and data and data.guild) then
                    countL.Text = "discord.gg/" .. invite
                    return false
                end
                nameL.Text = data.guild.name or nameL.Text
                local online = formatCount(data.approximate_presence_count)
                local total  = formatCount(data.approximate_member_count)
                countL.Text = string.format(
                    '<font color="#57F287">●</font> %s Online   <font color="#9BA1AD">●</font> %s Members',
                    online, total
                )
                if data.guild.icon and not iconHolder:FindFirstChildOfClass("ImageLabel") then
                    local img = fetchWebImage(
                        "https://cdn.discordapp.com/icons/" .. data.guild.id .. "/" .. data.guild.icon .. ".png?size=128",
                        "discord_" .. data.guild.id .. ".png"
                    )
                    if img then
                        iconLetter.Visible = false
                        New("ImageLabel", {
                            BackgroundTransparency = 1, Image = img,
                            Size = UDim2.new(1, 0, 1, 0), ZIndex = 3, Parent = iconHolder,
                        }, { New("UICorner", { CornerRadius = UDim.new(0, 11) }) })
                    end
                end
                return true
            end
            task.spawn(function()
                refresh()
                while task.wait(opts.RefreshInterval or 120) do
                    if not f.Parent then break end
                    refresh()
                end
            end)

            return { Refresh = refresh }
        end

        return Tab
    end

    --── Config system ───────────────────────────────────────────────────
    function Window:SaveConfig(name)
        name = name or "default"
        fs.ensure()
        local ok = fs.writeJSON(HadoUI.Folder .. "/configs/" .. Window.ConfigName .. "_" .. name .. ".json", HadoUI.Flags)
        HadoUI:Notify({
            Title = ok and "Config saved" or "Save failed",
            Content = ok and ('Saved as "' .. name .. '".') or "This executor has no file access.",
            Type = ok and "Success" or "Error",
        })
    end

    function Window:LoadConfig(name)
        name = name or "default"
        local data = fs.readJSON(HadoUI.Folder .. "/configs/" .. Window.ConfigName .. "_" .. name .. ".json")
        if not data then
            HadoUI:Notify({ Title = "Load failed", Content = 'No config named "' .. name .. '".', Type = "Error" })
            return
        end
        for flag, value in pairs(data) do
            local el = HadoUI.Options[flag]
            if el and el.Set then
                pcall(function()
                    if type(value) == "string" and value:sub(1, 1) == "#" and #value == 7 then
                        el:Set(Color3.fromHex(value))
                    elseif type(value) == "string" and Enum.KeyCode[value] and flag:lower():find("key") then
                        el:Set(Enum.KeyCode[value])
                    else
                        el:Set(value)
                    end
                end)
            end
        end
        HadoUI:Notify({ Title = "Config loaded", Content = ('Loaded "' .. name .. '".'), Type = "Success" })
    end

    function Window:ResetConfig()
        for flag, el in pairs(HadoUI.Options) do
            if el.Set and el._default ~= nil then
                pcall(function()
                    local d = el._default
                    if type(d) == "string" and d:sub(1, 1) == "#" and #d == 7 then
                        el:Set(Color3.fromHex(d))
                    elseif type(d) == "string" and d ~= "None" and Enum.KeyCode[d] and flag:lower():find("key") then
                        el:Set(Enum.KeyCode[d])
                    else
                        el:Set(d)
                    end
                end)
            end
        end
        HadoUI:Notify({ Title = "Config reset", Content = "All options restored to defaults.", Type = "Warning" })
    end

    --── Live style setters ──────────────────────────────────────────────
    local transparencyTargets = { Main }
    function Window:SetTransparency(a) -- 0..0.6
        a = math.clamp(a, 0, 0.6)
        for _, obj in ipairs(transparencyTargets) do
            obj.BackgroundTransparency = a
        end
        wash.BackgroundTransparency = a
    end

    function Window:SetScale(mult)
        Window._userScale = math.clamp(mult, 0.6, 1.4)
        applyScale(true)
        saveUIState()
    end

    function Window:SetTheme(name)
        local base = Themes[name]
        rebuildTheme(name, (base and base.DefaultAccent) or Theme.Accent)
        ApplyTheme()
        refreshWash()
    end

    function Window:SetAccent(color)
        rebuildTheme(Theme == nil and "Purple" or (Window._themeName or "Purple"), color)
        ApplyTheme()
        refreshWash()
    end

    --── Prebuilt Settings tab ───────────────────────────────────────────
    function Window:AddSettingsTab()
        local tab = Window:AddTab({ Name = "Settings", Icon = "settings" })

        tab:AddSection("Interface")
        tab:AddSlider({
            Name = "UI Scale", Min = 60, Max = 140, Default = math.floor(Window._userScale * 100),
            Suffix = "%", Flag = "_UIScale",
            Callback = function(v) Window:SetScale(v / 100) end,
        })
        tab:AddToggle({
            Name = "Auto DPI Scaling", Description = "Automatically match UI size to your screen resolution",
            Default = Window._autoDPI, Flag = "_UIAutoDPI",
            Callback = function(v)
                Window._autoDPI = v
                applyScale(true)
                saveUIState()
            end,
        })
        tab:AddSlider({
            Name = "Background Transparency", Min = 0, Max = 60, Default = 0, Suffix = "%",
            Flag = "_UITransparency",
            Callback = function(v) Window:SetTransparency(v / 100) end,
        })
        tab:AddToggle({
            Name = "Acrylic Blur", Flag = "_UIBlur", Default = false,
            Callback = function(v) SetBlur(v) end,
        })
        local themeNames = {}
        for k in pairs(Themes) do table.insert(themeNames, k) end
        table.sort(themeNames)
        tab:AddDropdown({
            Name = "Theme", Options = themeNames, Default = "Purple", Flag = "_UITheme",
            Callback = function(v)
                Window._themeName = v
                Window:SetTheme(v)
            end,
        })
        tab:AddColorPicker({
            Name = "Accent Color", Default = Theme.Accent, Flag = "_UIAccent",
            Callback = function(c) Window:SetAccent(c) end,
        })
        tab:AddKeybind({
            Name = "Toggle UI Key", Default = Window.ToggleKey, Flag = "_UIToggleKey",
            ChangedCallback = function(k) if k then Window.ToggleKey = k end end,
        })

        tab:AddSection("Configuration")
        local configName = "default"
        local function listConfigs()
            local names = {}
            pcall(function()
                if listfiles then
                    for _, p in ipairs(listfiles(HadoUI.Folder .. "/configs")) do
                        local n = p:match("[/\\]" .. Window.ConfigName .. "_(.+)%.json$")
                        if n then table.insert(names, n) end
                    end
                end
            end)
            table.sort(names)
            return names
        end
        local nameInput = tab:AddInput({
            Name = "Config Name", Default = "default", Placeholder = "config name",
            Callback = function(t) configName = (t ~= "" and t or "default") end,
        })
        local savedDropdown = tab:AddDropdown({
            Name = "Saved Configs", Description = "Pick an existing config to use",
            Options = listConfigs(),
            Callback = function(v)
                if v and v ~= "" then
                    configName = v
                    nameInput:Set(v)
                end
            end,
        })
        tab:AddButton({ Name = "Save Config", ButtonText = "Save",
            Callback = function()
                Window:SaveConfig(configName)
                savedDropdown:Refresh(listConfigs())
            end })
        tab:AddButton({ Name = "Load Config", ButtonText = "Load",
            Callback = function() Window:LoadConfig(configName) end })
        tab:AddButton({ Name = "Reset Config", ButtonText = "Reset",
            Callback = function() Window:ResetConfig() end })

        tab:AddSection("About")
        tab:AddParagraph({
            Title = Window.Name .. " " .. Window.VersionTag,
            Content = "Built on HadoUI v" .. HadoUI.Version .. " by " .. Window.Author
                .. (IS_MOBILE and ". Tap the Open button to toggle the window."
                    or (". Press " .. Window.ToggleKey.Name .. " to toggle the window.")),
        })
        return tab
    end

    --── Loader (plays once, then reveals the window) ────────────────────
    local function playLoader(done)
        local loader = New("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = 150, Parent = ScreenGui,
        })
        Tween(loader, { BackgroundTransparency = 0.35 }, 0.3)

        local card = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(240, 0), ClipsDescendants = true, ZIndex = 151, Parent = loader,
        })
        Bind(card, { BackgroundColor3 = "Background" })
        Corner(card, 14); Stroke(card, "Stroke", 1, 0.1); Shadow(card, 60, 0.35)
        Tween(card, { Size = UDim2.fromOffset(240, 210) }, 0.4, Enum.EasingStyle.Back)

        -- glowing H badge
        local badge = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 28),
            Size = UDim2.fromOffset(64, 64), ZIndex = 152, Parent = card,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = badge })
        Bind(badge, { BackgroundColor3 = "Accent" })
        local bg = New("UIGradient", { Rotation = 45, Parent = badge })
        Bind(bg, { Color = "AccentSequence" })
        local glow = New("ImageLabel", {
            BackgroundTransparency = 1, Image = "rbxassetid://5028857084",
            ImageTransparency = 0.3, Size = UDim2.new(1, 55, 1, 55),
            Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 151, Parent = badge,
        })
        Bind(glow, { ImageColor3 = "Accent" })
        task.spawn(function() -- breathing glow
            while glow.Parent do
                Tween(glow, { ImageTransparency = 0.65, Size = UDim2.new(1, 40, 1, 40) }, 0.8, Enum.EasingStyle.Sine)
                task.wait(0.85)
                Tween(glow, { ImageTransparency = 0.3, Size = UDim2.new(1, 55, 1, 55) }, 0.8, Enum.EasingStyle.Sine)
                task.wait(0.85)
            end
        end)
        if iconImage then
            New("ImageLabel", {
                BackgroundTransparency = 1, Image = iconImage, Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 153, Parent = badge,
            }, { New("UICorner", { CornerRadius = UDim.new(0, 12) }) })
        else
            New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "H",
                Font = Enum.Font.GothamBlack, TextSize = 30, TextColor3 = Color3.new(1, 1, 1),
                ZIndex = 153, Parent = badge,
            })
        end

        local nameL = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 104),
            Size = UDim2.new(1, 0, 0, 18), Text = Window.Name,
            Font = Enum.Font.GothamBold, TextSize = 15, ZIndex = 152, Parent = card,
        })
        Bind(nameL, { TextColor3 = "Text" })
        local statusL = New("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 124),
            Size = UDim2.new(1, 0, 0, 14), Text = "Initializing...",
            Font = Enum.Font.Gotham, TextSize = 11, ZIndex = 152, Parent = card,
        })
        Bind(statusL, { TextColor3 = "SubText" })

        local barBack = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 162),
            Size = UDim2.new(1, -56, 0, 5), ZIndex = 152, Parent = card,
        })
        Bind(barBack, { BackgroundColor3 = "Surface2" })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barBack })
        local barFill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), ZIndex = 153, Parent = barBack })
        Bind(barFill, { BackgroundColor3 = "Accent" })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = barFill })
        local bfg = New("UIGradient", { Parent = barFill })
        Bind(bfg, { Color = "AccentSequence" })

        task.spawn(function()
            local steps = {
                { 0.35, "Loading interface..." },
                { 0.65, "Preparing controls..." },
                { 0.90, "Almost ready..." },
                { 1.00, "Done" },
            }
            for _, stepInfo in ipairs(steps) do
                Tween(barFill, { Size = UDim2.new(stepInfo[1], 0, 1, 0) }, 0.45, Enum.EasingStyle.Quad)
                statusL.Text = stepInfo[2]
                task.wait(0.42)
            end
            task.wait(0.15)
            Tween(card, { Size = UDim2.fromOffset(240, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            Tween(loader, { BackgroundTransparency = 1 }, 0.35)
            task.wait(0.35)
            loader:Destroy()
            done()
        end)
    end

    playLoader(function()
        Window:Show()
    end)

    return Window
end

getgenv().HadoUI = HadoUI
return HadoUI
