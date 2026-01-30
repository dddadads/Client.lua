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
    EspEscape = false, 
    EspLocker = false,
    EspBallPit = false,
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

-- Сохранение стандартных настроек освещения для отката
local DefaultLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Переменные для Fly
local FlyBV, FlyBG

-- Поиск информации об игре
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
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
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

-- --- УЛУЧШЕННАЯ СИСТЕМА ESP ---
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
            if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
                task.wait(1)
            else
                local root = LP.Character.HumanoidRootPart
                local distance = (targetPart.Position - root.Position).Magnitude
                
                local finalString = name
                if ScriptSettings.ShowDistance then
                    finalString = finalString .. string.format(" [%dм]", math.floor(distance))
                end
                
                if isComputer and ScriptSettings.ShowProgress then
                    local prog = object:GetAttribute("Progress") or 0
                    -- Фикс 75%: Если значение больше 105, значит максимум 400
                    local maxVal = (prog > 105) and 400 or 100
                    
                    local percentage = math.clamp(math.floor((prog / maxVal) * 100), 0, 100)
                    finalString = finalString .. string.format("\nПрогресс: %d%%", percentage)
                end
                
                label.Text = finalString
            end
            task.wait(0.3)
        end
    end)
end

-- --- ФУНКЦИИ ИГРОКА ---
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

-- Бесконечные прыжки
UserInputService.JumpRequest:Connect(function()
    if ScriptSettings.InfJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- --- ВКЛАДКА ИНФО ---
local InfoParagraph = InfoTab:CreateParagraph({Title = "Статус CoolHub", Content = "Загрузка данных сервера..."})
task.spawn(function()
    while true do
        pcall(function()
            local content = string.format(
                "👤 Автор: coolguis119\n🎮 Игра: %s\n🎮 Игроков: %d/%d\n🆔 Сервер: %s",
                gameName, #Players:GetPlayers(), Players.MaxPlayers, game.JobId:sub(1,8)
            )
            InfoParagraph:Set({Title = "Статус CoolHub", Content = content})
        end)
        task.wait(3)
    end
end)

-- --- ВКЛАДКА ИГРОК ---
PlayerTab:CreateToggle({
    Name = "Noclip (Сквозь стены)",
    CurrentValue = false,
    Flag = "NoclipFlag",
    Callback = function(Value)
        ScriptSettings.Noclip = Value
        if Value then
            RunService:BindToRenderStep("NoclipLoop", 1, function()
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    if LP.Character.Humanoid.Health > 0 then
                        for _, part in pairs(LP.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
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
    Name = "Скорость Бега",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WS_Slider",
    Callback = function(v) ScriptSettings.WalkSpeed = v end
})

PlayerTab:CreateToggle({
    Name = "Активировать Скорость",
    CurrentValue = false,
    Flag = "WS_Toggle",
    Callback = function(Value)
        ScriptSettings.SpeedEnabled = Value
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
    Name = "Полет (Fly)",
    CurrentValue = false,
    Flag = "Fly_Toggle",
    Callback = function(v) 
        ScriptSettings.Fly = v 
        ToggleFly(v)
    end
})

-- --- ВКЛАДКА ВИЗУАЛЫ ---
VisualsTab:CreateToggle({
    Name = "ESP Игроков",
    CurrentValue = false,
    Flag = "ESP_Players",
    Callback = function(v) ScriptSettings.EspPlayers = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Компьютеров",
    CurrentValue = false,
    Flag = "ESP_Computers",
    Callback = function(v) ScriptSettings.EspComputer = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Выхода (Escape)",
    CurrentValue = false,
    Flag = "ESP_Escape",
    Callback = function(v) ScriptSettings.EspEscape = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Шкафчиков",
    CurrentValue = false,
    Flag = "ESP_Lockers",
    Callback = function(v) ScriptSettings.EspLocker = v end
})

VisualsTab:CreateToggle({
    Name = "ESP Ям с шариками",
    CurrentValue = false,
    Flag = "ESP_BallPits",
    Callback = function(v) ScriptSettings.EspBallPit = v end
})

VisualsTab:CreateToggle({
    Name = "Super Fullbright (Ночное зрение)",
    CurrentValue = false,
    Flag = "FullbrightFlag",
    Callback = function(v)
        ScriptSettings.Fullbright = v
        if v then
            task.spawn(function()
                while ScriptSettings.Fullbright do
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    task.wait(0.5)
                end
            end)
        else
            Lighting.Ambient = DefaultLighting.Ambient
            Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.ClockTime = DefaultLighting.ClockTime
            Lighting.FogEnd = DefaultLighting.FogEnd
            Lighting.GlobalShadows = DefaultLighting.GlobalShadows
        end
    end
})

-- Цикл обновления ESP
task.spawn(function()
    while true do
        if ScriptSettings.EspPlayers then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    ApplyESP(p.Character, Color3.fromRGB(255, 80, 80), p.Name, false)
                end
            end
        end
        
        if ScriptSettings.EspComputer then
            for _, obj in pairs(workspace:GetDescendants()) do
                if (obj.Name == "Meshes/t_Cube" or obj:GetAttribute("Progress")) and obj.Parent:IsA("Model") then
                    ApplyESP(obj.Parent, Color3.fromRGB(0, 255, 150), "Компьютер", true)
                end
            end
        end

        if ScriptSettings.EspEscape then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Escape" or obj.Name == "EscapeDoor" or obj.Name == "Exit" then
                    local target = obj:IsA("Model") and obj or obj.Parent
                    ApplyESP(target, Color3.fromRGB(255, 255, 0), "ВЫХОД", false)
                end
            end
        end

        if ScriptSettings.EspLocker then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Locker" or obj.Name == "Closet" then
                    local target = obj:IsA("Model") and obj or obj.Parent
                    ApplyESP(target, Color3.fromRGB(150, 150, 150), "Шкафчик", false)
                end
            end
        end

        if ScriptSettings.EspBallPit then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "BallPit" or obj.Name == "Ball Pit" then
                    local target = obj:IsA("Model") and obj or obj.Parent
                    ApplyESP(target, Color3.fromRGB(255, 100, 255), "Яма с шариками", false)
                end
            end
        end
        task.wait(2)
    end
end)

-- --- НАСТРОЙКИ ---
SettingsTab:CreateToggle({
    Name = "Показывать Дистанцию",
    CurrentValue = false,
    Flag = "Dist_Toggle",
    Callback = function(v) ScriptSettings.ShowDistance = v end
})

SettingsTab:CreateToggle({
    Name = "Прогресс Компьютеров",
    CurrentValue = false,
    Flag = "Prog_Toggle",
    Callback = function(v) ScriptSettings.ShowProgress = v end
})

SettingsTab:CreateButton({
    Name = "Выгрузить Скрипт",
    Callback = function()
        ScriptSettings.Noclip = false
        ScriptSettings.Fly = false
        ScriptSettings.InfJump = false
        ScriptSettings.Fullbright = false
        ToggleFly(false)
        RunService:UnbindFromRenderStep("NoclipLoop")
        Rayfield:Destroy()
    end
})

-- Управление полетом
RunService.RenderStepped:Connect(function()
    if ScriptSettings.Fly and FlyBV and FlyBG and LP.Character then
        local cam = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end

        FlyBV.Velocity = moveDir * (ScriptSettings.FlySpeed * 50)
        FlyBG.CFrame = cam
    end
end)

Rayfield:Notify({
    Title = "CoolHub",
    Content = "Canvas обновлен: добавлены шкафчики и бассейны!",
    Duration = 5,
    Image = 4483362458,
})
