-- 📜 Локальный скрипт: Панель с ESP, Полётом и Слоу-мо
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 🟩 GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HackerPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 320)
frame.Position = UDim2.new(0.5, -150, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
title.Text = "💻 Хакерская панель"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.Font = Enum.Font.Code
title.TextSize = 18
title.Parent = frame

local function createButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(0, 255, 0)
	btn.Font = Enum.Font.Code
	btn.TextSize = 16
	btn.Parent = frame
	return btn
end

-- ✨ Кнопки
local espButton = createButton("🟢 Включить ESP", 40)
local flyButton = createButton("✈️ Включить полёт", 90)
local slowmoButton = createButton("⏳ Включить слоу-мо", 140)

-- 📡 ESP
local espEnabled = false
local highlights = {}

local function toggleESP(state)
	espEnabled = state
	if espEnabled then
		espButton.Text = "🔴 Выключить ESP"
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(0, 255, 0)
				highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
				highlight.Adornee = plr.Character
				highlight.Parent = plr.Character
				highlights[plr] = highlight
			end
		end
	else
		espButton.Text = "🟢 Включить ESP"
		for plr, highlight in pairs(highlights) do
			if highlight then highlight:Destroy() end
		end
		highlights = {}
	end
end

Players.PlayerAdded:Connect(function(plr)
	if espEnabled then
		plr.CharacterAdded:Connect(function(char)
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(0, 255, 0)
			highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
			highlight.Adornee = char
			highlight.Parent = char
			highlights[plr] = highlight
		end)
	end
end)

espButton.MouseButton1Click:Connect(function()
	toggleESP(not espEnabled)
end)

-- ✈️ Полёт
local flying = false
local flySpeed = 50
local flyControl = {W = 0, A = 0, S = 0, D = 0}

local function startFlying()
	local char = player.Character
	if not char then return end
	local root = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then humanoid.PlatformStand = true end

	RunService.Heartbeat:Connect(function()
		if flying then
			local cam = workspace.CurrentCamera
			local moveDir = (cam.CFrame.LookVector * flyControl.W + cam.CFrame.RightVector * flyControl.D
				- cam.CFrame.LookVector * flyControl.S - cam.CFrame.RightVector * flyControl.A)
			root.Velocity = moveDir * flySpeed
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then flyControl.W = 1 end
	if key == Enum.KeyCode.S then flyControl.S = 1 end
	if key == Enum.KeyCode.A then flyControl.A = 1 end
	if key == Enum.KeyCode.D then flyControl.D = 1 end
	if key == Enum.KeyCode.Space then flyControl.Space = 1 end
	if key == Enum.KeyCode.LeftShift then flyControl.Shift = 1 end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	local key = input.KeyCode
	if key == Enum.KeyCode.W then flyControl.W = 0 end
	if key == Enum.KeyCode.S then flyControl.S = 0 end
	if key == Enum.KeyCode.A then flyControl.A = 0 end
	if key == Enum.KeyCode.D then flyControl.D = 0 end
	if key == Enum.KeyCode.Space then flyControl.Space = 0 end
	if key == Enum.KeyCode.LeftShift then flyControl.Shift = 0 end
end)

flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		flyButton.Text = "✈️ Выключить полёт"
		startFlying()
	else
		flyButton.Text = "✈️ Включить полёт"
		local char = player.Character
		if char and char:FindFirstChildWhichIsA("Humanoid") then
			char:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		end
	end
end)

-- ⏳ Слоу-мо
local slowmoOn = false
slowmoButton.MouseButton1Click:Connect(function()
	slowmoOn = not slowmoOn
	if slowmoOn then
		slowmoButton.Text = "⏳ Выключить слоу-мо"
		Lighting.ClockTime = 0
		game:GetService("TweenService"):Create(Lighting, TweenInfo.new(0), {ClockTime = 0}):Play()
		RunService:Set3dRenderingEnabled(true)
		game:GetService("RunService"):BindToRenderStep("SlowMo", Enum.RenderPriority.Camera.Value + 1, function()
			game:GetService("RunService").RenderStepped:Wait()
			task.wait(0.05) -- эффект замедления
		end)
	else
		slowmoButton.Text = "⏳ Включить слоу-мо"
		RunService:UnbindFromRenderStep("SlowMo")
	end
end)
