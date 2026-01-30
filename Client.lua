local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Конфигурация и Состояние
local ScriptSettings = {
    WalkSpeed = 16,
    FlySpeed = 50,
    Noclip = false,
    FlyEnabled = false,
    SpeedEnabled = false,
    InfJump = false,
    Fullbright = false,
    EspPlayers = false,
    EspComputer = false,
    ShowDistance = false,
    ShowProgress = false,
    FieldOfView = 70,
    AntiAFK = true,
    AutoInteract = false,
    InstantInteraction = false,
    Theme = "Default"
}

-- Сервисы
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

-- Переменные
local CachedObjects = {Computers = {}}
local OriginalHoldDurations = {}

-- Anti-AFK
for i,v in pairs(getconnections(LP.Idled)) do
    v:Disable()
end

-- Информация об игре
local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

-- Создание окна
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

-- Вкладки
local InfoTab = Window:CreateTab("Инфо", "info")
local PlayerTab = Window:CreateTab("Игрок", "user")
local VisualsTab = Window:CreateTab("Визуалы", "eye")
local MiscTab = Window:CreateTab("Разное", "plus-circle")
local SettingsTab = Window:CreateTab("Настройки", "settings")

-- --- СИСТЕМА ESP ---
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
            local settingActive = (name == "Компьютер") and ScriptSettings.EspComputer or ScriptSettings.EspPlayers
            
            highlight.Enabled = settingActive
            billboard.Enabled = settingActive
            
            if settingActive and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local root = LP.Character.HumanoidRootPart
                local distance = (targetPart.Position - root.Position).Magnitude
                
                local finalString = name
                if ScriptSettings.ShowDistance then
                    finalString = finalString .. string.format(" [%dм]", math.floor(distance))
                end
                
                if isComputer and ScriptSettings.ShowProgress then
                    local prog = object:GetAttribute("Progress") or 0
                    local maxVal = (prog > 101) and 400 or 100
                    local percentage = math.clamp(math.floor((prog / maxVal) * 100), 0, 100)
                    finalString = finalString .. string.format("\nПрогресс: %d%%", percentage)
                end
                label.Text = finalString
            end
            task.wait(0.5)
        end
    end)
end

-- Кэширование
local function RefreshMapCache()
    table.clear(CachedObjects.Computers)
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:GetAttribute("Progress") ~= nil or obj.Name == "Meshes/t_Cube") then
            local target = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
            if target and not table.find(CachedObjects.Computers, target) then
                table.insert(CachedObjects.Computers, target)
            end
        end
    end
end

-- --- ВКЛАДКИ ---
InfoTab:CreateParagraph({Title = "CoolHub Info", Content = "👤 Автор: coolguis119\n🎮 Игра: " .. gameName})

-- Игрок
PlayerTab:CreateInput({
    Name = "Скорость бега",
    PlaceholderText = "16",
    Flag = "WalkSpeedInput",
    Callback = function(Text)
        ScriptSettings.WalkSpeed = tonumber(Text) or 16
    end,
})

PlayerTab:CreateToggle({
    Name = "Включить Скорость",
    CurrentValue = false,
    Flag = "SpeedEnabled",
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

PlayerTab:CreateToggle({
    Name = "Noclip (Сквозь стены)",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(v)
        ScriptSettings.Noclip = v
        if v then
            RunService:BindToRenderStep("NoclipLoop", 1, function()
                if LP.Character then
                    for _, p in pairs(LP.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
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
    Flag = "InfJump",
    Callback = function(v) ScriptSettings.InfJump = v end
})

-- Визуалы
VisualsTab:CreateToggle({
    Name = "ESP Игроков",
    CurrentValue = false,
    Flag = "EspPlayers",
    Callback = function(v) ScriptSettings.EspPlayers = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Компьютеров",
    CurrentValue = false,
    Flag = "EspComputers",
    Callback = function(v) 
        ScriptSettings.EspComputer = v 
        if v then RefreshMapCache() end
    end
})

VisualsTab:CreateToggle({
    Name = "Fullbright (Свет)",
    CurrentValue = false,
    Flag = "Fullbright",
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
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.GlobalShadows = true
        end
    end
})

-- Разное
MiscTab:CreateSlider({
    Name = "Field of View (FOV)",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FOV",
    Callback = function(v)
        ScriptSettings.FieldOfView = v
        workspace.CurrentCamera.FieldOfView = v
    end
})

MiscTab:CreateToggle({
    Name = "Instant Interaction (Мгновенно)",
    CurrentValue = false,
    Flag = "InstantInteraction",
    Callback = function(v)
        ScriptSettings.InstantInteraction = v
        if v then
            task.spawn(function()
                while ScriptSettings.InstantInteraction do
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            if not OriginalHoldDurations[obj] then
                                OriginalHoldDurations[obj] = obj.HoldDuration
                            end
                            obj.HoldDuration = 0
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for obj, duration in pairs(OriginalHoldDurations) do
                if obj and obj.Parent then
                    obj.HoldDuration = duration
                end
            end
        end
    end
})

MiscTab:CreateToggle({
    Name = "Auto Interact (Авто-E)",
    CurrentValue = false,
    Flag = "AutoInteract",
    Callback = function(v)
        ScriptSettings.AutoInteract = v
        task.spawn(function()
            while ScriptSettings.AutoInteract do
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (LP.Character.HumanoidRootPart.Position - obj.Parent.Position).Magnitude
                            if dist < 10 then
                                fireproximityprompt(obj)
                            end
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end
})

MiscTab:CreateButton({
    Name = "Clear Barriers (Барьеры)",
    Callback = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Barriers" then obj:Destroy() end
        end
        Rayfield:Notify({Title = "CoolHub", Content = "Барьеры удалены!", Duration = 3})
    end
})

-- Настройки
SettingsTab:CreateToggle({Name = "Показывать Дистанцию", Flag = "ShowDist", Callback = function(v) ScriptSettings.ShowDistance = v end})
SettingsTab:CreateToggle({Name = "Показывать Прогресс %", Flag = "ShowProg", Callback = function(v) ScriptSettings.ShowProgress = v end})

-- Прыжок
UserInputService.JumpRequest:Connect(function()
    if ScriptSettings.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Основной цикл
task.spawn(function()
    while true do
        RefreshMapCache()
        if ScriptSettings.EspPlayers then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then ApplyESP(p.Character, Color3.fromRGB(255, 80, 80), p.Name, false) end
            end
        end
        if ScriptSettings.EspComputer then
            for _, obj in pairs(CachedObjects.Computers) do ApplyESP(obj, Color3.fromRGB(0, 255, 150), "Компьютер", true) end
        end
        
        -- Детектор убийцы
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:find("Killer") or (p.Character and p.Character:FindFirstChild("Knife")) then
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 50 then
                        Rayfield:Notify({Title = "ВНИМАНИЕ!", Content = "Убийца близко! ("..math.floor(dist).."м)", Duration = 1})
                    end
                end
            end
        end
        
        task.wait(1)
    end
end)

Rayfield:LoadConfiguration()
-- Применение FOV после загрузки конфига
workspace.CurrentCamera.FieldOfView = ScriptSettings.FieldOfView
