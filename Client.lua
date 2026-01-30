local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Конфигурация и Состояние
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
    ShowDistance = false,
    ShowProgress = false,
    Theme = "Default"
}

-- Сервисы
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

-- Сохранение стандартных настроек освещения
local DefaultLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Переменные
local FlyBV, FlyBG
local CachedObjects = {Computers = {}}

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
            local settingActive = false
            if name == "Компьютер" then settingActive = ScriptSettings.EspComputer
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

-- Функция кэширования объектов
local function RefreshMapCache()
    table.clear(CachedObjects.Computers)

    for _, obj in pairs(workspace:GetDescendants()) do
        -- Поиск компьютеров
        if (obj:GetAttribute("Progress") ~= nil or obj.Name == "Meshes/t_Cube") then
            local target = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
            if target and not table.find(CachedObjects.Computers, target) then
                table.insert(CachedObjects.Computers, target)
            end
        end
    end
end

-- --- ФУНКЦИИ ИГРОКА ---
UserInputService.JumpRequest:Connect(function()
    if ScriptSettings.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- --- ВКЛАДКИ ---
local InfoParagraph = InfoTab:CreateParagraph({Title = "Статус CoolHub", Content = "Загрузка..."})
task.spawn(function()
    while true do
        pcall(function()
            InfoParagraph:Set({Title = "Статус CoolHub", Content = string.format("👤 Автор: coolguis119\n🎮 Игра: %s\n👥 Игроков: %d", gameName, #Players:GetPlayers())})
        end)
        task.wait(5)
    end
end)

PlayerTab:CreateInput({
    Name = "Установить Скорость",
    PlaceholderText = "Введите число (напр. 50)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            ScriptSettings.WalkSpeed = num
            Rayfield:Notify({Title = "Скорость", Content = "Установлено: " .. num, Duration = 2})
        else
            Rayfield:Notify({Title = "Ошибка", Content = "Введите корректное число!", Duration = 2})
        end
    end,
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

PlayerTab:CreateButton({
    Name = "Clear Barriers (Удалить барьеры)",
    Callback = function()
        local found = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Barriers" and (obj:IsA("Folder") or obj:IsA("Model")) then
                obj:Destroy()
                found = true
            end
        end
        if found then
            Rayfield:Notify({Title = "Успех", Content = "Все папки Barriers удалены!", Duration = 3})
        else
            Rayfield:Notify({Title = "Инфо", Content = "Папки Barriers не найдены.", Duration = 3})
        end
    end
})

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

-- Цикл ESP
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

        task.wait(10)
    end
end)

SettingsTab:CreateToggle({Name = "Дистанция", CurrentValue = false, Callback = function(v) ScriptSettings.ShowDistance = v end})
SettingsTab:CreateToggle({Name = "Прогресс %", CurrentValue = false, Callback = function(v) ScriptSettings.ShowProgress = v end})

SettingsTab:CreateButton({
    Name = "Обновить Кэш (Поиск объектов)",
    Callback = function() RefreshMapCache() end
})

Rayfield:Notify({
    Title = "CoolHub",
    Content = "Функции обновлены: добавлен ввод скорости и удаление барьеров.",
    Duration = 5
})
