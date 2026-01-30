local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration and State
local ScriptSettings = {
    WalkSpeed = 16,
    FlySpeed = 1,
    Noclip = false,
    Fly = false,
    SpeedEnabled = false,
    InfJump = false,
    Fullbright = false,
    EspPlayers = false,
    EspComputer = false,
    EspEscape = false, 
    ShowDistance = false,
    ShowProgress = false,
    Theme = "Default"
}

-- Services
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

-- Save Default Lighting
local DefaultLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Variables
local FlyBV, FlyBG
local CachedObjects = {Computers = {}, Escapes = {}}

-- Get Game Info
local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "CoolHub | Five Nights: Hunted",
    Icon = 0,
    LoadingTitle = "CoolHub Loading...",
    LoadingSubtitle = "by coolguis119",
    Theme = ScriptSettings.Theme,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CoolHub_FNH",
        FileName = "Config"
    }
})

-- Tabs
local InfoTab = Window:CreateTab("Инфо", "info")
local PlayerTab = Window:CreateTab("Игрок", "user")
local VisualsTab = Window:CreateTab("Визуалы", "eye")
local SettingsTab = Window:CreateTab("Настройки", "settings")

-- --- OPTIMIZED ESP SYSTEM ---
local function ApplyESP(object, color, name, isComputer)
    if not object or object:FindFirstChild("Enhanced_ESP") then return end
    
    local targetPart = object:IsA("Model") and (object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")) or object
    if not targetPart then return end

    local folder = Instance.new("Folder")
    folder.Name = "Enhanced_ESP"
    folder.Parent = object

    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = object
    highlight.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = targetPart
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Text = name
    label.Parent = billboard

    task.spawn(function()
        while object and object.Parent and folder.Parent do
            local settingActive = false
            if name == "Компьютер" then settingActive = ScriptSettings.EspComputer
            elseif name == "ВЫХОД" then settingActive = ScriptSettings.EspEscape
            else settingActive = ScriptSettings.EspPlayers end

            if not settingActive then
                highlight.Enabled = false
                billboard.Enabled = false
            else
                highlight.Enabled = true
                billboard.Enabled = true
                
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LP.Character.HumanoidRootPart
                    local distance = (targetPart.Position - root.Position).Magnitude
                    
                    local finalString = name
                    if ScriptSettings.ShowDistance then
                        finalString = finalString .. string.format(" [%dм]", math.floor(distance))
                    end
                    
                    if isComputer and ScriptSettings.ShowProgress then
                        local prog = object:GetAttribute("Progress") or 0
                        -- Fix for 75% issue: 400 is max progress in FNH
                        local maxVal = (prog > 101) and 400 or 100
                        local percentage = math.clamp(math.floor((prog / maxVal) * 100), 0, 100)
                        finalString = finalString .. string.format("\nПрогресс: %d%%", percentage)
                    end
                    label.Text = finalString
                end
            end
            task.wait(0.5)
        end
    end)
end

-- Map Caching Function
local function RefreshMapCache()
    table.clear(CachedObjects.Computers)
    table.clear(CachedObjects.Escapes)

    -- Trying to find the "карта" folder safely
    local map = workspace:FindFirstChild("карта") or workspace:FindFirstChild("Map")
    if map then
        -- Computers in Task folder
        local taskFolder = map:FindFirstChild("Task")
        if taskFolder then
            for _, obj in pairs(taskFolder:GetChildren()) do
                table.insert(CachedObjects.Computers, obj)
            end
        end
        -- Escapes in Escapes folder
        local escapesFolder = map:FindFirstChild("Escapes")
        if escapesFolder then
            for _, obj in pairs(escapesFolder:GetChildren()) do
                if obj:IsA("Model") then
                    table.insert(CachedObjects.Escapes, obj)
                end
            end
        end
    end
end

-- --- PLAYER FUNCTIONS ---
local function ToggleFly(state)
    if state then
        local character = LP.Character
        if not character then return end
        local root = character:WaitForChild("HumanoidRootPart")
        FlyBV = Instance.new("BodyVelocity", root)
        FlyBG = Instance.new("BodyGyro", root)
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBV.Velocity = Vector3.zero
        character.Humanoid.PlatformStand = true
    else
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = false
        end
    end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if ScriptSettings.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- --- INFO TAB ---
local InfoParagraph = InfoTab:CreateParagraph({Title = "Статус CoolHub", Content = "Загрузка..."})
task.spawn(function()
    while true do
        pcall(function()
            InfoParagraph:Set({Title = "Статус CoolHub", Content = string.format("👤 Автор: coolguis119\n🎮 Игра: %s\n👥 Игроков: %d", gameName, #Players:GetPlayers())})
        end)
        task.wait(5)
    end
end)

-- --- PLAYER TAB ---
PlayerTab:CreateToggle({
    Name = "Noclip (Сквозь стены)",
    CurrentValue = false,
    Flag = "NoclipFlag",
    Callback = function(Value)
        ScriptSettings.Noclip = Value
        if Value then
            RunService:BindToRenderStep("NoclipLoop", 1, function()
                if LP.Character then
                    for _, part in pairs(LP.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("NoclipLoop")
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Бесконечные Прыжки",
    CurrentValue = false,
    Flag = "InfJumpFlag",
    Callback = function(v) ScriptSettings.InfJump = v end
})

PlayerTab:CreateSlider({
    Name = "Скорость",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) ScriptSettings.WalkSpeed = v end
})

PlayerTab:CreateToggle({
    Name = "Включить Скорость",
    CurrentValue = false,
    Callback = function(v)
        ScriptSettings.SpeedEnabled = v
        task.spawn(function()
            while ScriptSettings.SpeedEnabled do
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    LP.Character.Humanoid.WalkSpeed = ScriptSettings.WalkSpeed
                end
                task.wait(0.1)
            end
        end)
    end
})

-- --- VISUALS TAB ---
VisualsTab:CreateToggle({
    Name = "ESP Игроков",
    CurrentValue = false,
    Callback = function(v) ScriptSettings.EspPlayers = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Компьютеров",
    CurrentValue = false,
    Callback = function(v) 
        ScriptSettings.EspComputer = v 
        if v then RefreshMapCache() end
    end
})

VisualsTab:CreateToggle({
    Name = "ESP Выходов",
    CurrentValue = false,
    Callback = function(v) 
        ScriptSettings.EspEscape = v 
        if v then RefreshMapCache() end
    end
})

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        ScriptSettings.Fullbright = v
        if v then
            task.spawn(function()
                while ScriptSettings.Fullbright do
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.GlobalShadows = false
                    task.wait(1)
                end
            end)
        else
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.ClockTime = DefaultLighting.ClockTime
            Lighting.GlobalShadows = DefaultLighting.GlobalShadows
        end
    end
})

-- Optimized ESP Loop
task.spawn(function()
    while true do
        -- Auto-refresh cache every 10 seconds to detect new round objects
        RefreshMapCache()
        
        -- Players update
        if ScriptSettings.EspPlayers then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then ApplyESP(p.Character, Color3.fromRGB(255, 80, 80), p.Name, false) end
            end
        end
        
        -- Computers update
        if ScriptSettings.EspComputer then
            for _, obj in pairs(CachedObjects.Computers) do ApplyESP(obj, Color3.fromRGB(0, 255, 150), "Компьютер", true) end
        end

        -- Escapes update
        if ScriptSettings.EspEscape then
            for _, obj in pairs(CachedObjects.Escapes) do ApplyESP(obj, Color3.fromRGB(255, 255, 0), "ВЫХОД", false) end
        end

        task.wait(10)
    end
end)

-- --- SETTINGS TAB ---
SettingsTab:CreateToggle({Name = "Дистанция", CurrentValue = false, Callback = function(v) ScriptSettings.ShowDistance = v end})
SettingsTab:CreateToggle({Name = "Прогресс %", CurrentValue = false, Callback = function(v) ScriptSettings.ShowProgress = v end})

SettingsTab:CreateButton({
    Name = "Обновить Кэш Карты Вручную",
    Callback = function() RefreshMapCache() end
})

Rayfield:Notify({
    Title = "CoolHub",
    Content = "ESP настроен под структуру Task/Escapes. Ошибка 75% исправлена.",
    Duration = 5
})
