-- 🌌 Хакерская панель Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HackerPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.Text = "💻 Hacker Panel"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.Font = Enum.Font.Code
title.TextSize = 18
title.Parent = frame

-- Кнопки
local function createButton(name, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(0, 255, 0)
	btn.Font = Enum.Font.Code
	btn.TextSize = 16
	btn.Parent = frame
	return btn
end

local y = 40
local buttons = {}

-- ✨ Супер прыжок
buttons.superJump = createButton("🦘 Супер прыжок", y)
y = y + 40
buttons.superJump.MouseButton1Click:Connect(function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = 200
	end
end)

-- ✨ Сброс прыжка
buttons.resetJump = createButton("♻️ Сброс прыжка", y)
y = y + 40
buttons.resetJump.MouseButton1Click:Connect(function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.JumpPower = 50
	end
end)

-- ✨ Добавить монеты
buttons.addMoney = createButton("💸 Добавить монеты", y)
y = y + 40
buttons.addMoney.MouseButton1Click:Connect(function()
	local args = {"Money", 1000000000}
	ReplicatedStorage:WaitForChild("ClaimReward"):FireServer(unpack(args))
end)

-- ✈️ Полёт
local flyBtn = createButton("✈️ Полёт", y)
y = y + 40
local flying = false
local flySpeed = 50
local flyControl = {W=0,A=0,S=0,D=0}

local function startFlying()
	local char = player.Character
	if not char then return end
	local root = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then humanoid.PlatformStand = true end

	RunService.Heartbeat:Connect(function()
		if flying then
			local cam = workspace.CurrentCamera
			local moveDir = (cam.CFrame.LookVector*flyControl.W + cam.CFrame.RightVector*flyControl.D
				- cam.CFrame.LookVector*flyControl.S - cam.CFrame.RightVector*flyControl.A)
			root.Velocity = moveDir*flySpeed + Vector3.new(0, flyControl.Space*flySpeed,0)
		end
	end)
end

flyBtn.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		flyBtn.Text = "✈️ Выключить полёт"
		startFlying()
	else
		flyBtn.Text = "✈️ Включить полёт"
		local char = player.Character
		if char and char:FindFirstChildWhichIsA("Humanoid") then
			char:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W then flyControl.W = 1 end
	if input.KeyCode == Enum.KeyCode.S then flyControl.S = 1 end
	if input.KeyCode == Enum.KeyCode.A then flyControl.A = 1 end
	if input.KeyCode == Enum.KeyCode.D then flyControl.D = 1 end
	if input.KeyCode == Enum.KeyCode.Space then flyControl.Space = 1 end
	if input.KeyCode == Enum.KeyCode.LeftShift then flyControl.Space = -1 end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.W then flyControl.W = 0 end
	if input.KeyCode == Enum.KeyCode.S then flyControl.S = 0 end
	if input.KeyCode == Enum.KeyCode.A then flyControl.A = 0 end
	if input.KeyCode == Enum.KeyCode.D then flyControl.D = 0 end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then flyControl.Space = 0 end
end)

-- 📊 Панель игроков (ник + HP + расстояние)
local infoFrame = Instance.new("ScrollingFrame")
infoFrame.Size = UDim2.new(1, -20, 0, 120)
infoFrame.Position = UDim2.new(0, 10, 0, y)
infoFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
infoFrame.BorderColor3 = Color3.fromRGB(0,255,0)
infoFrame.ScrollBarThickness = 5
infoFrame.Parent = frame

local function updatePlayerInfo()
	infoFrame:ClearAllChildren()
	local yOffset = 0
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
			if hum then
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -10, 0, 20)
				lbl.Position = UDim2.new(0, 5, 0, yOffset)
				lbl.BackgroundTransparency = 1
				lbl.TextColor3 = Color3.fromRGB(0,255,0)
				lbl.Font = Enum.Font.Code
				lbl.TextSize = 14
				local dist = (player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
				lbl.Text = plr.Name.." | HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth).." | "..math.floor(dist).." studs"
				lbl.Parent = infoFrame
				yOffset = yOffset + 22
			end
		end
	end
end

RunService.RenderStepped:Connect(updatePlayerInfo)
