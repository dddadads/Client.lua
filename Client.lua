-- 📜 Хакерская панель GUI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ⚙ Настройки
local speedBoost = 50
local jumpBoost = 150
local noclipOn = false
local speedOn = false
local menuOpen = false

-- 🟩 GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HackerPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- 📦 Панель
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0.5, -160, 0.5, -200)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- 🟢 Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.new(0, 0.2, 0)
title.Text = "💻 HACKER PANEL 💻"
title.TextColor3 = Color3.new(0, 1, 0)
title.Font = Enum.Font.Code
title.TextSize = 22
title.Parent = frame

-- 🌌 Фон с 0 и 1
local bg = Instance.new("TextLabel")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Text = ""
bg.TextColor3 = Color3.new(0, 1, 0)
bg.Font = Enum.Font.Code
bg.TextSize = 14
bg.TextTransparency = 0.85
bg.ZIndex = 0
bg.Parent = frame

task.spawn(function()
	while true do
		local t = ""
		for i = 1, 500 do
			t = t .. math.random(0, 1)
		end
		bg.Text = t
		task.wait(0.1)
	end
end)

-- 🧰 Функция создания кнопок
local yOffset = 50
local function createButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, yOffset)
	btn.BackgroundColor3 = Color3.new(0, 0.2, 0)
	btn.TextColor3 = Color3.new(0, 1, 0)
	btn.Font = Enum.Font.Code
	btn.TextSize = 20
	btn.Text = text
	btn.AutoButtonColor = true
	btn.ZIndex = 1
	btn.Parent = frame

	btn.MouseButton1Click:Connect(callback)

	yOffset = yOffset + 50
	return btn
end

-- ⚡ Скорость
createButton("🚀 Скорость", function()
	speedOn = not speedOn
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = speedOn and speedBoost or 16
	end
end)

-- 🧱 Ноуклип
createButton("🧱 Ноуклип", function()
	noclipOn = not noclipOn
end)

RunService.Stepped:Connect(function()
	if noclipOn and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- 🦘 Прыжок
createButton("🦘 Высокий прыжок", function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.JumpPower = jumpBoost
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- 💰 Монеты
local moneyBox = Instance.new("TextBox")
moneyBox.Size = UDim2.new(1, -20, 0, 35)
moneyBox.Position = UDim2.new(0, 10, 0, yOffset)
moneyBox.PlaceholderText = "💰 Кол-во монет"
moneyBox.BackgroundColor3 = Color3.new(0, 0.2, 0)
moneyBox.TextColor3 = Color3.new(0, 1, 0)
moneyBox.Font = Enum.Font.Code
moneyBox.TextSize = 18
moneyBox.Parent = frame

yOffset = yOffset + 45

createButton("Выдать монеты", function()
	local amount = tonumber(moneyBox.Text)
	if amount then
		local args = { "Money", amount }
		game:GetService("ReplicatedStorage"):WaitForChild("ClaimReward"):FireServer(unpack(args))
	end
end)

-- 🧭 Toggle G
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.G then
		menuOpen = not menuOpen
		frame.Visible = menuOpen
	end
end)

-- ♻ Сброс при респавне
player.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.WalkSpeed = 16
	hum.JumpPower = 50
	speedOn = false
	noclipOn = false
end)

-- 📌 Пример: как добавить новую кнопку позже
--[[
createButton("🌟 Новая функция", function()
	print("Сюда вставляешь код своей функции")
end)
]]
