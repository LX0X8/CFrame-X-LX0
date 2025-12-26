debugX = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "CFRAME X V1",
	Icon = 0,
	LoadingTitle = "Cframe X V1",
	LoadingSubtitle = "LX0",
	Theme = "Amethyst",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "CframeXfileholder",
		FileName = "MainSaveCFrameX"
	},
	Discord = {
		Enabled = false,
		Invite = "noinvitelink",
		RememberJoins = true
	},
	KeySystem = true,
	KeySettings = {
		Title = "CFrame X | Enter your key",
		Subtitle = "CFrameX Keys",
		Note = "Keys are in the script",
		FileName = "KeyCframexunique",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"Cframexxx", "xl192"}
	}
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speed = 0
local flySpeed = 50
local flyEnabled = false
local noclipEnabled = false
local fullbright = false

local espEnabled = false
local espBoxes = true
local espNames = true
local espTracers = false
local espTeamCheck = true
local espColor = Color3.fromRGB(255, 0, 0)

local MainTab = Window:CreateTab("Main", 14213647544)
local VisualTab = Window:CreateTab("Visuals", 4483362458)

MainTab:CreateSection("Movement")

MainTab:CreateSlider({
	Name = "CFrame Walk Speed",
	Range = {0, 120},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 0,
	Flag = "WalkSpeed",
	Callback = function(v)
		speed = v
	end
})

MainTab:CreateToggle({
	Name = "Enable Fly",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(v)
		flyEnabled = v
	end
})

MainTab:CreateSlider({
	Name = "Fly Speed",
	Range = {0, 200},
	Increment = 1,
	Suffix = "Fly",
	CurrentValue = 50,
	Flag = "FlySpeed",
	Callback = function(v)
		flySpeed = v
	end
})

MainTab:CreateToggle({
	Name = "CFrame Noclip",
	CurrentValue = false,
	Flag = "NoclipToggle",
	Callback = function(v)
		noclipEnabled = v
	end
})

MainTab:CreateSection("ESP")

MainTab:CreateToggle({
	Name = "ESP Enabled",
	CurrentValue = false,
	Flag = "ESPEnabled",
	Callback = function(v)
		espEnabled = v
		if not v then
			for _,data in pairs(_G.__CFrameX_ESP or {}) do
				if data.Clear then
					data:Clear()
				end
			end
			_G.__CFrameX_ESP = {}
		end
	end
})

MainTab:CreateToggle({
	Name = "Boxes",
	CurrentValue = true,
	Flag = "ESPBoxes",
	Callback = function(v)
		espBoxes = v
	end
})

MainTab:CreateToggle({
	Name = "Names",
	CurrentValue = true,
	Flag = "ESPNames",
	Callback = function(v)
		espNames = v
	end
})

MainTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = false,
	Flag = "ESPTracers",
	Callback = function(v)
		espTracers = v
	end
})

MainTab:CreateToggle({
	Name = "Team Check",
	CurrentValue = true,
	Flag = "ESPTeam",
	Callback = function(v)
		espTeamCheck = v
	end
})

MainTab:CreateColorPicker({
	Name = "ESP Color",
	CurrentValue = espColor,
	Flag = "ESPColor",
	Callback = function(c)
		espColor = c
	end
})

VisualTab:CreateSection("Visuals")

VisualTab:CreateSlider({
	Name = "FOV",
	Range = {70, 120},
	Increment = 1,
	Suffix = "FOV",
	CurrentValue = 70,
	Flag = "FOV",
	Callback = function(v)
		if camera then
			camera.FieldOfView = v
		end
	end
})

VisualTab:CreateToggle({
	Name = "FullBright",
	CurrentValue = false,
	Flag = "FullBright",
	Callback = function(v)
		fullbright = v
		if v then
			Lighting.Brightness = 3
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
		else
			Lighting.Brightness = 1
			Lighting.ClockTime = 12
			Lighting.FogEnd = 1000
		end
	end
})

local function getChar()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	return char, hrp, hum
end

local function isSameTeam(p)
	if not espTeamCheck then return false end
	if not p.Team or not player.Team then return false end
	return p.Team == player.Team
end

local DrawingAvailable = false
pcall(function()
	if type(Drawing) == "table" and Drawing.new then
		DrawingAvailable = true
	end
end)

_G.__CFrameX_ESP = _G.__CFrameX_ESP or {}

local function createDrawingForPlayer(plr)
	if not DrawingAvailable then
		return nil
	end
	local data = {}
	data.box = Drawing.new("Square")
	data.box.Visible = false
	data.box.Filled = false
	data.box.Thickness = 2
	data.name = Drawing.new("Text")
	data.name.Size = 16
	data.name.Center = true
	data.name.Outline = true
	data.tracer = Drawing.new("Line")
	data.tracer.Thickness = 1.5
	data.Clear = function(self)
		if self.box then pcall(function() self.box:Remove() end) end
		if self.name then pcall(function() self.name:Remove() end) end
		if self.tracer then pcall(function() self.tracer:Remove() end) end
	end
	return data
end

local billboardCache = {}

local function createBillboard(plr)
	if not plr.Character then return end
	local head = plr.Character:FindFirstChild("Head")
	if not head then return end
	if billboardCache[plr] and billboardCache[plr].Parent then return billboardCache[plr] end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0,100,0,40)
	gui.Adornee = head
	gui.AlwaysOnTop = true
	gui.Name = "CFrameXBillboard"
	local frame = Instance.new("Frame", gui)
	frame.BackgroundTransparency = 0.35
	frame.Size = UDim2.new(1,0,1,0)
	frame.BorderSizePixel = 0
	local txt = Instance.new("TextLabel", frame)
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.Text = plr.Name
	txt.Font = Enum.Font.SourceSansBold
	txt.TextSize = 16
	txt.TextStrokeTransparency = 0
	txt.TextColor3 = espColor
	gui.Parent = plr:FindFirstChildOfClass("PlayerGui") or player:FindFirstChildOfClass("PlayerGui")
	billboardCache[plr] = gui
	return gui
end

Players.PlayerRemoving:Connect(function(p)
	if _G.__CFrameX_ESP and _G.__CFrameX_ESP[p] and _G.__CFrameX_ESP[p].Clear then
		_G.__CFrameX_ESP[p]:Clear()
		_G.__CFrameX_ESP[p] = nil
	end
	if billboardCache[p] then
		pcall(function() billboardCache[p]:Destroy() end)
		billboardCache[p] = nil
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local char, hrp, hum = getChar()
	if not hrp or not hum then return end

	if noclipEnabled then
		for _,v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end

	if speed > 0 and not flyEnabled then
		local dir = hum.MoveDirection
		if dir.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + (dir * speed * dt)
		end
	end

	if flyEnabled then
		hum:ChangeState(Enum.HumanoidStateType.Physics)
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
		if move.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + (move.Unit * flySpeed * dt)
		end
	else
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end

	if espEnabled then
		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character.Parent and plr.Character:FindFirstChild("HumanoidRootPart") then
				if espTeamCheck and isSameTeam(plr) then
					if _G.__CFrameX_ESP[plr] and _G.__CFrameX_ESP[plr].Clear then
						_G.__CFrameX_ESP[plr]:Clear()
						_G.__CFrameX_ESP[plr] = nil
					end
					if billboardCache[plr] then
						pcall(function() billboardCache[plr]:Destroy() end)
						billboardCache[plr] = nil
					end
					continue
				end
				local head = plr.Character:FindFirstChild("Head")
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if head and root then
					if DrawingAvailable then
						if not _G.__CFrameX_ESP[plr] then
							_G.__CFrameX_ESP[plr] = createDrawingForPlayer(plr)
						end
						local data = _G.__CFrameX_ESP[plr]
						local topPos, topVis = camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
						local bottomPos, bottomVis = camera:WorldToViewportPoint(root.Position - Vector3.new(0,1,0))
						local onScreen = topVis or bottomVis
						if onScreen then
							local height = math.abs(topPos.Y - bottomPos.Y)
							if height < 8 then height = 8 end
							local width = math.clamp(height/2, 6, 300)
							local x = topPos.X - (width/2)
							local y = topPos.Y - (height/2)
							if espBoxes and data.box then
								data.box.Visible = true
								data.box.Position = Vector2.new(x, y)
								data.box.Size = Vector2.new(width, height)
								data.box.Color = espColor
							else
								if data.box then data.box.Visible = false end
							end
							if espNames and data.name then
								data.name.Visible = true
								data.name.Position = Vector2.new(topPos.X, topPos.Y - (height/2) - 10)
								data.name.Text = plr.Name
								data.name.Color = espColor
							else
								if data.name then data.name.Visible = false end
							end
							if espTracers and data.tracer then
								data.tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
								data.tracer.To = Vector2.new(topPos.X, topPos.Y)
								data.tracer.Color = espColor
								data.tracer.Visible = true
							else
								if data.tracer then data.tracer.Visible = false end
							end
						else
							if data then
								if data.box then data.box.Visible = false end
								if data.name then data.name.Visible = false end
								if data.tracer then data.tracer.Visible = false end
							end
						end
					else
						if espNames then
							createBillboard(plr)
							if billboardCache[plr] and billboardCache[plr]:FindFirstChildOfClass("Frame") then
								local frame = billboardCache[plr]:FindFirstChildOfClass("Frame")
								if frame and frame:FindFirstChildOfClass("TextLabel") then
									frame:FindFirstChildOfClass("TextLabel").TextColor3 = espColor
								end
							end
						else
							if billboardCache[plr] then
								pcall(function() billboardCache[plr]:Destroy() end)
								billboardCache[plr] = nil
							end
						end
					end
				end
			else
				if _G.__CFrameX_ESP[plr] and _G.__CFrameX_ESP[plr].Clear then
					_G.__CFrameX_ESP[plr]:Clear()
					_G.__CFrameX_ESP[plr] = nil
				end
				if billboardCache[plr] then
					pcall(function() billboardCache[plr]:Destroy() end)
					billboardCache[plr] = nil
				end
			end
		end
	else
		for _,data in pairs(_G.__CFrameX_ESP) do
			if data.Clear then data:Clear() end
		end
		_G.__CFrameX_ESP = {}
		for _,gui in pairs(billboardCache) do
			pcall(function() gui:Destroy() end)
		end
		billboardCache = {}
	end
end)

Rayfield:LoadConfiguration()
