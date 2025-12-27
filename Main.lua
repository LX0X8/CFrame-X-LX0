local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "CFRAME X V5",
	Theme = "Amethyst",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "CframeX",
		FileName = "MainV5"
	}
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getChar()
	local c = player.Character
	if not c then return nil,nil,nil end
	return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
end

local MovementTab = Window:CreateTab("Movement", 14213647544)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)

local speedEnabled = false
local speedValue = 0
local speedOverride = false
local speedSliderContainer
local speedSlider

MovementTab:CreateSection("CFrame Speed")
MovementTab:CreateToggle({
	Name = "Enable Speed",
	CurrentValue = false,
	Callback = function(v)
		speedEnabled = v
	end
})

local function createSpeedSlider(max)
	if speedSliderContainer then
		pcall(function() speedSliderContainer:Destroy() end)
	end
	speedValue = math.clamp(speedValue, 0, max)
	speedSliderContainer = MovementTab:CreateSlider({
		Name = "Speed",
		Range = {0, max},
		Increment = 1,
		CurrentValue = speedValue,
		Callback = function(v)
			speedValue = v
		end
	})
end

createSpeedSlider(300)

MovementTab:CreateToggle({
	Name = "Override Max Speed (3000)",
	CurrentValue = false,
	Callback = function(v)
		speedOverride = v
		if v then
			createSpeedSlider(3000)
		else
			createSpeedSlider(300)
		end
	end
})

local flyEnabled = false
local flySpeed = 0

MovementTab:CreateSection("CFrame Fly")
MovementTab:CreateToggle({
	Name = "Enable Fly",
	CurrentValue = false,
	Callback = function(v)
		flyEnabled = v
	end
})
MovementTab:CreateSlider({
	Name = "Fly Speed",
	Range = {0,300},
	Increment = 1,
	CurrentValue = 0,
	Callback = function(v)
		flySpeed = v
	end
})

local noclipEnabled = false

MovementTab:CreateSection("Noclip")
MovementTab:CreateToggle({
	Name = "Enable Noclip",
	CurrentValue = false,
	Callback = function(v)
		noclipEnabled = v
	end
})

local espEnabled = false
local espTeamCheck = true
local espCache = {}

ESPTab:CreateSection("Highlight ESP")
ESPTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = false,
	Callback = function(v)
		espEnabled = v
		if not v then
			for p,data in pairs(espCache) do
				if data.highlight and data.highlight.Parent then pcall(function() data.highlight:Destroy() end) end
				if data.name and data.name.Parent then pcall(function() data.name:Destroy() end) end
			end
			espCache = {}
		end
	end
})
ESPTab:CreateToggle({
	Name = "Team Check",
	CurrentValue = true,
	Callback = function(v)
		espTeamCheck = v
	end
})

VisualTab:CreateSection("Camera & Lighting")
VisualTab:CreateSlider({
	Name = "FOV",
	Range = {70,120},
	Increment = 1,
	CurrentValue = 70,
	Callback = function(v)
		if camera then camera.FieldOfView = v end
	end
})
VisualTab:CreateToggle({
	Name = "FullBright",
	CurrentValue = false,
	Callback = function(v)
		if v then
			Lighting.Brightness = 3
			Lighting.ClockTime = 14
			Lighting.FogEnd = 1e6
		else
			Lighting.Brightness = 1
			Lighting.ClockTime = 12
			Lighting.FogEnd = 1000
		end
	end
})

local function createESP(plr)
	if espCache[plr] then return end
	if not plr.Character or not plr.Character.Parent then return end
	local highlight
	pcall(function()
		highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255,0,0)
		highlight.OutlineColor = Color3.fromRGB(255,0,0)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Adornee = plr.Character
		highlight.Parent = plr.Character
	end)
	local nameGui
	local head = plr.Character:FindFirstChild("Head")
	if head then
		pcall(function()
			nameGui = Instance.new("BillboardGui")
			nameGui.Size = UDim2.new(0,200,0,40)
			nameGui.StudsOffset = Vector3.new(0,2.5,0)
			nameGui.AlwaysOnTop = true
			nameGui.Adornee = head
			local txt = Instance.new("TextLabel", nameGui)
			txt.Size = UDim2.new(1,0,1,0)
			txt.BackgroundTransparency = 1
			txt.Text = plr.Name
			txt.TextColor3 = Color3.fromRGB(255,0,0)
			txt.TextStrokeTransparency = 0
			txt.Font = Enum.Font.SourceSansBold
			txt.TextSize = 18
			nameGui.Parent = player:FindFirstChildOfClass("PlayerGui")
		end)
	end
	espCache[plr] = {highlight = highlight, name = nameGui}
end

local function removeESP(plr)
	local data = espCache[plr]
	if not data then return end
	if data.highlight and data.highlight.Parent then pcall(function() data.highlight:Destroy() end) end
	if data.name and data.name.Parent then pcall(function() data.name:Destroy() end) end
	espCache[plr] = nil
end

Players.PlayerRemoving:Connect(function(p)
	removeESP(p)
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.2)
		if espEnabled then
			removeESP(p)
			createESP(p)
		end
	end)
end)

for _,p in ipairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function()
		task.wait(0.2)
		if espEnabled then
			removeESP(p)
			createESP(p)
		end
	end)
end

RunService.RenderStepped:Connect(function(dt)
	local char, hrp, hum = getChar()
	if hrp and hum then
		if noclipEnabled then
			for _,part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					pcall(function()
						part.CanCollide = false
					end)
				end
			end
		end
		if speedEnabled and speedValue > 0 and not flyEnabled then
			local dir = hum.MoveDirection
			if dir.Magnitude > 0 then
				hrp.CFrame = hrp.CFrame + (dir * speedValue * dt)
			end
		end
		if flyEnabled and flySpeed > 0 then
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
			if move.Magnitude > 0 then
				hrp.CFrame = hrp.CFrame + (move.Unit * flySpeed * dt)
			end
		end
	end
	if espEnabled then
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character.Parent then
				if espTeamCheck and plr.Team == player.Team then
					removeESP(plr)
				else
					createESP(plr)
				end
			else
				removeESP(plr)
			end
		end
	end
end)

Rayfield:LoadConfiguration()
