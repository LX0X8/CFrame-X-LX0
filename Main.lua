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
	if not c then return end
	local hrp = c:FindFirstChild("HumanoidRootPart")
	local hum = c:FindFirstChildOfClass("Humanoid")
	return c, hrp, hum
end

local MovementTab = Window:CreateTab("Movement", 14213647544)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)

local speedEnabled = false
local speedValue = 0
local speedOverride = false

MovementTab:CreateSection("CFrame Speed")

MovementTab:CreateToggle({
	Name = "Enable Speed",
	CurrentValue = false,
	Callback = function(v)
		speedEnabled = v
	end
})

MovementTab:CreateSlider({
	Name = "Speed",
	Range = {0,300},
	Increment = 1,
	CurrentValue = 0,
	Callback = function(v)
		speedValue = v
	end
})

MovementTab:CreateToggle({
	Name = "Override Max Speed (3000)",
	CurrentValue = false,
	Callback = function(v)
		speedOverride = v
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
			for _,d in pairs(espCache) do
				if d.h then d.h:Destroy() end
				if d.g then d.g:Destroy() end
			end
			table.clear(espCache)
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
		camera.FieldOfView = v
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
	local char = plr.Character
	if not char then return end

	local h = Instance.new("Highlight")
	h.FillColor = Color3.fromRGB(255,0,0)
	h.OutlineColor = Color3.fromRGB(255,0,0)
	h.FillTransparency = 0.5
	h.Adornee = char
	h.Parent = char

	local head = char:FindFirstChild("Head")
	local g
	if head then
		g = Instance.new("BillboardGui")
		g.Size = UDim2.new(0,200,0,40)
		g.StudsOffset = Vector3.new(0,2.5,0)
		g.AlwaysOnTop = true
		g.Adornee = head
		local t = Instance.new("TextLabel", g)
		t.Size = UDim2.new(1,0,1,0)
		t.BackgroundTransparency = 1
		t.Text = plr.Name
		t.TextColor3 = Color3.fromRGB(255,0,0)
		t.TextStrokeTransparency = 0
		t.Font = Enum.Font.SourceSansBold
		t.TextSize = 18
		g.Parent = player:WaitForChild("PlayerGui")
	end

	espCache[plr] = {h = h, g = g}
end

local function removeESP(plr)
	local d = espCache[plr]
	if not d then return end
	if d.h then d.h:Destroy() end
	if d.g then d.g:Destroy() end
	espCache[plr] = nil
end

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function(dt)
	local char, hrp, hum = getChar()
	if hrp and hum then
		if noclipEnabled then
			for _,p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
		end

		if speedEnabled and not flyEnabled then
			local dir = hum.MoveDirection
			if dir.Magnitude > 0 then
				local mult = speedOverride and 10 or 1
				hrp.CFrame += dir * speedValue * mult * dt
			end
		end

		if flyEnabled and flySpeed > 0 then
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
			if move.Magnitude > 0 then
				hrp.CFrame += move.Unit * flySpeed * dt
			end
		end
	end

	if espEnabled then
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
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
