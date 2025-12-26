debugX = true

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "CFRAME X V1",
	Icon = 0,
	LoadingTitle = "Cframe X V1",
	LoadingSubtitle = "LX0",
	Theme = "Amethyst",
	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false,
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
		Note = "Tip: Keys are located inside the code",
		FileName = "KeyCframexunique",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"Cframexxx", "xl192"}
	}
})

local Tab = Window:CreateTab("Main", 14213647544)
Tab:CreateSection("CFrame")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local speed = 0

Tab:CreateSlider({
	Name = "CFrame Speed Slider",
	Range = {0, 100},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 0,
	Flag = "Slider1",
	Callback = function(Value)
		speed = Value
	end
})

RunService.RenderStepped:Connect(function(dt)
	if speed <= 0 then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not hrp or not hum then return end
	local dir = hum.MoveDirection
	if dir.Magnitude > 0 then
		hrp.CFrame = hrp.CFrame + (dir * speed * dt)
	end
end)

Rayfield:LoadConfiguration()
