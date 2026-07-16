--[[  Hado Hub — your script hub, built on HadoUI.
      Repo: https://github.com/Hado-k/Hado-Hub
      One-shot loader:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Hado-k/Hado-Hub/main/Hado.lua"))()
      Edit the Name/Version/features below; wire your functions into the Callbacks. ]]

-- use the library if it's already loaded, otherwise fetch it from GitHub
local HadoUI = getgenv().HadoUI
    or loadstring(game:HttpGet("https://raw.githubusercontent.com/Hado-k/Hado-Hub/main/HadoUI.lua"))()
assert(HadoUI, "Failed to load HadoUI library")

local Window = HadoUI:CreateWindow({
    Name       = "Hado Hub",
    Version    = "v1.0",
    Author     = "Hado",
    Discord    = "https://discord.gg/x2RtUZb6d9",
    DiscordButton = false, -- the Main tab has the live Discord card instead
    ConfigName = "HadoHub",
    ToggleKey  = Enum.KeyCode.RightShift,
})

Window:Tag({ Title = "BETA", Icon = "flame" })

--// Main ------------------------------------------------------------------
local Main = Window:AddTab({ Name = "Main", Icon = "house" })
Main:AddParagraph({
    Title = "Welcome",
    Content = "This hub is built on HadoUI. Add your own features to each tab and wire them through the Callback functions.",
})
Main:AddSection("Community")
Main:AddDiscord({ Invite = "x2RtUZb6d9" })

Main:AddSection("Showcase")
Main:AddButton({
    Name = "Open Dialog", Description = "Confirmation popup example",
    Callback = function()
        Window:Dialog({
            Title = "Reset progress?",
            Content = "This will reset all your farm progress. This action cannot be undone.",
            Icon = "circle-alert",
            Buttons = {
                { Title = "Reset", Variant = "Primary", Callback = function()
                    HadoUI:Notify({ Title = "Reset", Content = "Progress reset.", Type = "Warning", Icon = "rotate-ccw" })
                end },
                { Title = "Cancel" },
            },
        })
    end,
})
Main:AddToggle({
    Name = "Premium Feature", Description = "Unlocks with a key",
    Locked = true, LockedTitle = "Premium only",
})
Main:AddDropdown({
    Name = "Searchable Dropdown",
    Options = { "Ak-47", "M4A1", "AWP", "Deagle", "Glock", "USP-S", "MP5", "P90", "Nova", "XM1014", "Negev", "M249" },
    Callback = function(v) print("[Hado] weapon:", v) end,
})

--// Player ----------------------------------------------------------------
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })
PlayerTab:AddSection("Character")
PlayerTab:AddSlider({
    Name = "Walk Speed", Description = "How fast your character moves", Min = 16, Max = 200, Default = 16, Flag = "WalkSpeed",
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})
PlayerTab:AddSlider({
    Name = "Jump Power", Min = 50, Max = 300, Default = 50, Flag = "JumpPower",
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end,
})

--// Visuals ---------------------------------------------------------------
local Visuals = Window:AddTab({ Name = "Visuals", Icon = "eye" })
Visuals:AddSection("ESP")

local Players = game:GetService("Players")
local ESP = {
    Enabled = false,
    Color = Color3.fromRGB(122, 44, 255),
    Connections = {},
}

local function espApply(character)
    if not (ESP.Enabled and character) then return end
    local h = character:FindFirstChild("HadoESP") or Instance.new("Highlight")
    h.Name = "HadoESP"
    h.FillColor = ESP.Color
    h.OutlineColor = ESP.Color
    h.FillTransparency = 0.65
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- visible through walls
    h.Parent = character
end

local function espWatch(player)
    if player == Players.LocalPlayer then return end
    espApply(player.Character)
    table.insert(ESP.Connections, player.CharacterAdded:Connect(function(char)
        task.wait(0.5) -- let the character build
        espApply(char)
    end))
end

local function espSet(enabled)
    ESP.Enabled = enabled
    if enabled then
        for _, plr in ipairs(Players:GetPlayers()) do espWatch(plr) end
        table.insert(ESP.Connections, Players.PlayerAdded:Connect(espWatch))
    else
        for _, c in ipairs(ESP.Connections) do c:Disconnect() end
        table.clear(ESP.Connections)
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            local h = char and char:FindFirstChild("HadoESP")
            if h then h:Destroy() end
        end
    end
end

Visuals:AddToggle({
    Name = "Player ESP", Description = "Highlight players through walls", Flag = "ESP",
    Callback = espSet,
})
Visuals:AddColorPicker({
    Name = "ESP Color", Default = ESP.Color, Flag = "ESPColor",
    Callback = function(color)
        ESP.Color = color
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            local h = char and char:FindFirstChild("HadoESP")
            if h then h.FillColor = color; h.OutlineColor = color end
        end
    end,
})

--// Settings (prebuilt) ---------------------------------------------------
Window:AddSettingsTab()

task.delay(2.6, function()
    HadoUI:Notify({ Title = "Hado Hub", Content = "Loaded successfully. Welcome, " .. game.Players.LocalPlayer.Name .. "!", Type = "Success", Duration = 5 })
end)

print("[Hado] Hado Hub loaded")
