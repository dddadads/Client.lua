-- 🌌 Панель хакера Roblox (улучшенная)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Создание основного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerPanel"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Фон с 0 и 1
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.Position = UDim2.new(0, 0, 0, 0)
Background.BackgroundColor3 = Color3.new(0, 0, 0)
Background.BorderSizePixel = 0
Background.ZIndex = 0
Background.Parent = ScreenGui

-- Эффект анимированного 0 1
local function createBinary()
	for i = 1, 200 do
		local txt = Instance.new("TextLabel")
		txt.Text = math.random(0,1)
		txt.TextColor3 = Color3.fromRGB(0, 255, 0)
		txt.Font = Enum.Font.Code
		txt.TextSize = 20
		txt.BackgroundTransparency = 1
		txt.Position = UDim2.new(math.random(), 0, math.random(), 0)
		txt.Parent = Background
		txt.ZIndex = 0

		task.spawn(function()
			while true do
				txt.Text = math.random(0,1)
				task.wait(0.1 + math.random() * 0.2)
			end
		end)
	end
end
createBinary()

-- Панель
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 250, 0, 300)
Panel.Position = UDim2.new(0, 20, 0.5, -150)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Panel.BorderColor3 = Color3.fromRGB(0, 255, 0)
Panel.ZIndex = 1
Panel.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Panel)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🧠 Hacker Panel"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.Code
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = Panel

-- 📌 Функции кнопок
local function createButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, #Panel:GetChildren() * 35)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(0, 255, 0)
	btn.Font = Enum.Font.Code
	btn.TextSize = 18
	btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
	btn.Parent = Panel

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 5)

	btn.MouseButton1Click:Connect(callback)
end

-- ✨ Функции
createButton("💸 +Монеты", function()
	local args = {"Money", 1000000000000}
	game:GetService("ReplicatedStorage"):WaitForChild("ClaimReward"):FireServer(unpack(args))
end)

createButton("🦘 Супер прыжок", function()
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = 200
	end
end)

createButton("👻 Невидимость (только клиент)", function()
	for _, part in ipairs(player.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		elseif part:IsA("Decal") then
			part.Transparency = 1
		end
	end
end)

createButton("♻️ Ресет прыжка", function()
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.JumpPower = 50
	end
end)
