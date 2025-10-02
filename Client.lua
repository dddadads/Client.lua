-- 📜 Локальный скрипт: Меню + Скорость + Ноуклип + Прыжок + Монеты

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- ⚙ Настройки
local boostedSpeed = 50
local normalSpeed = 16
local jumpPower = 150
local normalJump = 50

local speedOn = false
local noclipOn = false
local jumpOn = false
local menuOpen = false
local minimized = false

-- 🧱 GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 📦 Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 340)
frame.Position = UDim2.new(0.5, -130, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- 🔹 Верхняя панель
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙️ Меню"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- 🔸 Кнопки управления окном
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

-- 🟡 Кнопка скорости
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(1, -20, 0, 50)
speedButton.Position = UDim2.new(0, 10, 0, 50)
speedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.Font = Enum.Font.SourceSansBold
speedButton.TextSize = 20
speedButton.Text = "Включить скорость"
speedButton.Parent = frame

-- 🧱 Кнопка ноуклипа
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1, -20, 0, 50)
noclipButton.Position = UDim2.new(0, 10, 0, 110)
noclipButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
noclipButton.TextColor3 = Color3.new(1, 1, 1)
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.TextSize = 20
noclipButton.Text = "Включить ноуклип"
noclipButton.Parent = frame

-- 🦘 Кнопка высокого прыжка
local jumpButton = Instance.new("TextButton")
jumpButton.Size = UDim2.new(1, -20, 0, 50)
jumpButton.Position = UDim2.new(0, 10, 0, 170)
jumpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpButton.TextColor3 = Color3.new(1, 1, 1)
jumpButton.Font = Enum.Font.SourceSansBold
jumpButton.TextSize = 20
jumpButton.Text = "Включить высокий прыжок"
jumpButton.Parent = frame

-- 💰 Поле ввода для монет
local moneyBox = Instance.new("TextBox")
moneyBox.Size = UDim2.new(1, -20, 0, 40)
moneyBox.Position = UDim2.new(0, 10, 0, 230)
moneyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
moneyBox.TextColor3 = Color3.new(1, 1, 1)
moneyBox.Font = Enum.Font.SourceSansBold
moneyBox.TextSize = 20
moneyBox.PlaceholderText = "Введите кол-во монет"
moneyBox.Text = ""
moneyBox.Parent = frame

local giveMoneyButton = Instance.new("TextButton")
giveMoneyButton.Size = UDim2.new(1, -20, 0, 50)
giveMoneyButton.Position = UDim2.new(0, 10, 0, 280)
giveMoneyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
giveMoneyButton.TextColor3 = Color3.new(1, 1, 1)
giveMoneyButton.Font = Enum.Font.SourceSansBold
giveMoneyButton.TextSize = 20
giveMoneyButton.Text = "Выдать монеты"
giveMoneyButton.Parent = frame

-- 🌀 Функции
local function setSpeed(isBoosted)
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid.WalkSpeed = isBoosted and boostedSpeed or normalSpeed
	end
end

local function setJump(isBoosted)
	local character = player.Character
	if character and character:FindFirstChild("Humanoid") then
		character.Humanoid.UseJumpPower = true
		character.Humanoid.JumpPower = isBoosted and jumpPower or normalJump
	end
end

local function toggleNoclip(state)
	noclipOn = state
	noclipButton.Text = noclipOn and "Выключить ноуклип" or "Включить ноуклип"
end

RunService.Stepped:Connect(function()
	if noclipOn then
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

-- 🎛 Управление
UserInputService.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.G then
		menuOpen = not menuOpen
		frame.Visible = menuOpen
	end
end)

speedButton.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	setSpeed(speedOn)
	speedButton.Text = speedOn and "Выключить скорость" or "Включить скорость"
end)

noclipButton.MouseButton1Click:Connect(function()
	toggleNoclip(not noclipOn)
end)

jumpButton.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	setJump(jumpOn)
	jumpButton.Text = jumpOn and "Выключить высокий прыжок" or "Включить высокий прыжок"
end)

giveMoneyButton.MouseButton1Click:Connect(function()
	local amount = tonumber(moneyBox.Text)
	if amount and amount > 0 then
		local args = {"Money", amount}
		local event = ReplicatedStorage:FindFirstChild("ClaimReward")
		if event then
			event:FireServer(unpack(args))
		end
	end
end)

-- 🧭 Кнопки окна
minimizeBtn.MouseButton1Click:Connect(function()
	if not minimized then
		frame.Size = UDim2.new(0, 260, 0, 30)
		minimized = true
	end
end)

maximizeBtn.MouseButton1Click:Connect(function()
	if minimized then
		frame.Size = UDim2.new(0, 260, 0, 340)
		minimized = false
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	menuOpen = false
end)

-- ♻ Сброс
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = normalSpeed
	humanoid.JumpPower = normalJump
	speedOn = false
	noclipOn = false
	jumpOn = false
	speedButton.Text = "Включить скорость"
	noclipButton.Text = "Включить ноуклип"
	jumpButton.Text = "Включить высокий прыжок"
end)
