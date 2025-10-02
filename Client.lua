-- 📜 Локальный скрипт: Расширяемое dev-меню

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- ⚙ Настройки
local settings = {
	Speed = {On = false, Boost = 50, Normal = 16},
	Jump = {On = false, Boost = 150, Normal = 50},
	Noclip = {On = false},
	Menu = {Open = false, Minimized = false},
}

-- 🧱 GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 340)
frame.Position = UDim2.new(0.5, -130, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Верхняя панель
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙️ Dev Menu"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Верхние кнопки управления
local function createTopButton(text, xOffset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 25, 1, 0)
	btn.Position = UDim2.new(1, xOffset, 0, 0)
	btn.BackgroundTransparency = 1
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	btn.Parent = titleBar
	return btn
end

local minimizeBtn = createTopButton("–", -75)
local maximizeBtn = createTopButton("□", -50)
local closeBtn = createTopButton("X", -25)

-- 📌 Таблица функций меню
local menuFunctions = {
	{
		Name = "Скорость",
		Desc = "Включить/Выключить скорость",
		Callback = function()
			settings.Speed.On = not settings.Speed.On
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.WalkSpeed = settings.Speed.On and settings.Speed.Boost or settings.Speed.Normal
			end
		end,
		ButtonText = function() return settings.Speed.On and "Выключить скорость" or "Включить скорость" end
	},
	{
		Name = "Высокий прыжок",
		Desc = "Вкл/Выкл высокий прыжок",
		Callback = function()
			settings.Jump.On = not settings.Jump.On
			local char = player.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid.UseJumpPower = true
				char.Humanoid.JumpPower = settings.Jump.On and settings.Jump.Boost or settings.Jump.Normal
			end
		end,
		ButtonText = function() return settings.Jump.On and "Выключить прыжок" or "Включить прыжок" end
	},
	{
		Name = "Ноуклип",
		Desc = "Вкл/Выкл ноуклип",
		Callback = function()
			settings.Noclip.On = not settings.Noclip.On
		end,
		ButtonText = function() return settings.Noclip.On and "Выключить ноуклип" or "Включить ноуклип" end
	},
	{
		Name = "Выдать монеты",
		Desc = "Вводи число и выдай",
		Callback = function()
			local amount = tonumber(moneyBox.Text)
			if amount and amount > 0 then
				local event = ReplicatedStorage:FindFirstChild("ClaimReward")
				if event then
					event:FireServer("Money", amount)
				end
			end
		end,
		IsTextBox = true,
		TextBoxPlaceholder = "Введите кол-во монет",
		ButtonText = function() return "Выдать монеты" end
	},
}

-- 🧱 Создаём кнопки из таблицы
local startY = 50
local buttonHeight = 50
local moneyBox

for i, func in ipairs(menuFunctions) do
	if func.IsTextBox then
		moneyBox = Instance.new("TextBox")
		moneyBox.Size = UDim2.new(1, -20, 0, 40)
		moneyBox.Position = UDim2.new(0, 10, 0, startY)
		moneyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		moneyBox.TextColor3 = Color3.new(1, 1, 1)
		moneyBox.Font = Enum.Font.SourceSansBold
		moneyBox.TextSize = 20
		moneyBox.PlaceholderText = func.TextBoxPlaceholder or ""
		moneyBox.Text = ""
		moneyBox.Parent = frame
		startY = startY + 45
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, buttonHeight)
	btn.Position = UDim2.new(0, 10, 0, startY)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	btn.Text = func.ButtonText()
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		func.Callback()
		btn.Text = func.ButtonText()
	end)

	startY = startY + buttonHeight + 10
end

-- Ноуклип цикл
RunService.Stepped:Connect(function()
	if settings.Noclip.On then
		local char = player.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- G — открыть/закрыть меню
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.G then
		settings.Menu.Open = not settings.Menu.Open
		frame.Visible = settings.Menu.Open
	end
end)

-- Верхние кнопки
minimizeBtn.MouseButton1Click:Connect(function()
	if not settings.Menu.Minimized then
		frame.Size = UDim2.new(0, 260, 0, 30)
		settings.Menu.Minimized = true
	end
end)

maximizeBtn.MouseButton1Click:Connect(function()
	if settings.Menu.Minimized then
		frame.Size = UDim2.new(0, 260, 0, 340)
		settings.Menu.Minimized = false
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	settings.Menu.Open = false
end)

-- Сброс при спавне
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = settings.Speed.Normal
	humanoid.JumpPower = settings.Jump.Normal
	settings.Speed.On = false
	settings.Jump.On = false
	settings.Noclip.On = false
end)
