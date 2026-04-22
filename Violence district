local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- КОНФИГУРАЦИЯ
local Config = {
    SpeedEnabled = false,
    DefaultSpeed = 16, -- Переменная для хранения обычной скорости
    ESPEnabled = false,
    FOVEnabled = false,
    Fullbright = false,
    Visible = true,
    Binds = {
        Menu = Enum.KeyCode.Insert,
        Speed = Enum.KeyCode.Z,
        ESP = Enum.KeyCode.X,
        FOV = Enum.KeyCode.J,
        Dash = Enum.KeyCode.V,
        Bright = Enum.KeyCode.B
    }
}

-- ГУИ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Xeno_V8_Final"
ScreenGui.DisplayOrder = 2147483647
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 320)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner", Main)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "XENO GHOST V8"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main
Instance.new("UICorner", Title)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.Text = "×"
Close.TextSize = 25
Close.TextColor3 = Color3.new(1, 0, 0.2)
Close.BackgroundTransparency = 1
Close.Parent = Main

local List = Instance.new("UIListLayout", Main)
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

-- Функция для кнопок
local function createBtn(name, key, defaultColor)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    b.Text = name .. " [" .. key.Name .. "]"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.Parent = Main
    Instance.new("UICorner", b)
    return b
end

local bSpeed = createBtn("Speed Hack", Config.Binds.Speed)
local bESP = createBtn("Visuals ESP", Config.Binds.ESP)
local bFOV = createBtn("Wide Vision", Config.Binds.FOV)
local bDash = createBtn("Back Dash", Config.Binds.Dash)
local bBright = createBtn("Fullbright", Config.Binds.Bright)

-- ЛОГИКА ФУНКЦИЙ
local function doDash()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 7)
    end
end

local function toggleBright()
    Config.Fullbright = not Config.Fullbright
    if Config.Fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
    end
end

-- ESP
local function applyESP(obj, color)
    if not Config.ESPEnabled then return end
    local h = obj:FindFirstChild("XenoHighlight") or Instance.new("Highlight")
    h.Name = "XenoHighlight"
    h.FillColor = color
    h.FillTransparency = 0.5
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
end

-- ЦИКЛ ОБНОВЛЕНИЯ
RunService.RenderStepped:Connect(function()
    -- Speed
    if Config.SpeedEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 19 -- Твоя скорость при чите
    end
    
    -- FOV
    Camera.FieldOfView = Config.FOVEnabled and 90 or 70

    -- Player ESP
    if Config.ESPEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local isK = p.Team and (p.Team.Name:lower():find("killer") or p.Team.Name:lower():find("murder")) 
                local color = (isK or p.TeamColor == BrickColor.new("Bright red")) and Color3.new(1, 0, 0) or Color3.new(0, 0.5, 1)
                applyESP(p.Character, color)
            end
        end
    end
end)

-- СКАНЕР МИРА
task.spawn(function()
    while true do
        if Config.ESPEnabled then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Window" then applyESP(obj, Color3.new(0, 1, 1))
                elseif obj.Name == "Palletwrong" or obj.Name:find("Pallet") then applyESP(obj, Color3.new(0, 1, 0))
                elseif obj.Name == "Generator" then applyESP(obj, Color3.new(1, 1, 0)) end
            end
        end
        task.wait(4)
    end
end)

-- ОБРАБОТКА ВВОДА
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    
    if i.KeyCode == Config.Binds.Menu then
        Config.Visible = not Config.Visible
        Main.Visible = Config.Visible
        
    elseif i.KeyCode == Config.Binds.Speed then
        local hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if hum then
            Config.SpeedEnabled = not Config.SpeedEnabled
            
            if Config.SpeedEnabled then
                -- Запоминаем текущую скорость перед включением
                Config.DefaultSpeed = hum.WalkSpeed
                hum.WalkSpeed = 19
            else
                -- Возвращаем сохраненную скорость при выключении
                hum.WalkSpeed = Config.DefaultSpeed
            end
            
            bSpeed.BackgroundColor3 = Config.SpeedEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(30, 30, 45)
        end
        
    elseif i.KeyCode == Config.Binds.Dash then
        doDash()
    elseif i.KeyCode == Config.Binds.Bright then
        toggleBright()
        bBright.BackgroundColor3 = Config.Fullbright and Color3.fromRGB(200, 200, 0) or Color3.fromRGB(30, 30, 45)
    elseif i.KeyCode == Config.Binds.FOV then
        Config.FOVEnabled = not Config.FOVEnabled
        bFOV.BackgroundColor3 = Config.FOVEnabled and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 45)
    elseif i.KeyCode == Config.Binds.ESP then
        Config.ESPEnabled = not Config.ESPEnabled
        bESP.BackgroundColor3 = Config.ESPEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(30, 30, 45)
    end
end)

Close.MouseButton1Click:Connect(function() Main.Visible = false end)
