local ReplicatedStorage = game:GetService("ReplicatedStorage")
local labEvent = ReplicatedStorage:WaitForChild("LabEvent")
local player = game.Players.LocalPlayer

-- === GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "ScienceGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 160)
frame.Position = UDim2.new(1, -260, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "🔬 Лаборатория"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local box = Instance.new("TextBox")
box.PlaceholderText = "Введите ник"
box.Size = UDim2.new(1, -20, 0, 40)
box.Position = UDim2.new(0, 10, 0, 40)
box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.SourceSans
box.TextSize = 18
box.Parent = frame

local killBtn = Instance.new("TextButton")
killBtn.Text = "☠️ УБИТЬ"
killBtn.Size = UDim2.new(1, -20, 0, 40)
killBtn.Position = UDim2.new(0, 10, 0, 90)
killBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
killBtn.TextColor3 = Color3.new(1, 1, 1)
killBtn.Font = Enum.Font.SourceSansBold
killBtn.TextSize = 18
killBtn.Parent = frame

killBtn.MouseButton1Click:Connect(function()
    local name = box.Text
    if name ~= "" then
        labEvent:FireServer("KillPlayer", name)
    end
end)

-- Кнопка убить себя
local suicide = Instance.new("TextButton")
suicide.Text = "💀 Убить себя"
suicide.Size = UDim2.new(1, -20, 0, 30)
suicide.Position = UDim2.new(0, 10, 0, 135)
suicide.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
suicide.TextColor3 = Color3.new(1, 1, 1)
suicide.Font = Enum.Font.SourceSansBold
suicide.TextSize = 18
suicide.Parent = frame

suicide.MouseButton1Click:Connect(function()
    labEvent:FireServer("KillSelf")
end)
