local P, T, C, U, L = 1537690962, game:GetService("TeleportService"), game:GetService("CoreGui"), game:GetService("UserInputService"), game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")

local CFG_FILE = "uze9r_reconnect_cfg.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/uzer271/user271-reconnect/refs/heads/main/reconnect.lua"

local Config = {
	AutoReconnect = true,
	SameServer = true,
	TimerEnabled = false,
	TimerHours = 3,
	WalkSpeed = 16,
	ShowMobileBtn = false,
	PosXScale = 0.5,
	PosXOffset = -118,
	PosYScale = 0.2,
	PosYOffset = 0,
	MobXScale = 0.5,
	MobXOffset = -55,
	MobYScale = 0.08,
	MobYOffset = 0
}

local function canFS()
	return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
end

local function loadConfig()
	if not canFS() then return end
	pcall(function()
		if isfile(CFG_FILE) then
			local decoded = HttpService:JSONDecode(readfile(CFG_FILE))
			if type(decoded) == "table" then
				if type(decoded.AutoReconnect) == "boolean" then Config.AutoReconnect = decoded.AutoReconnect end
				if type(decoded.SameServer) == "boolean" then Config.SameServer = decoded.SameServer end
				if type(decoded.TimerEnabled) == "boolean" then Config.TimerEnabled = decoded.TimerEnabled end
				if type(decoded.TimerHours) == "number" then
					Config.TimerHours = math.clamp(math.floor(decoded.TimerHours), 1, 24)
				end
				if type(decoded.WalkSpeed) == "number" then
					Config.WalkSpeed = math.clamp(math.floor(decoded.WalkSpeed), 1, 90)
				end
				if type(decoded.ShowMobileBtn) == "boolean" then Config.ShowMobileBtn = decoded.ShowMobileBtn end
				if type(decoded.PosXScale) == "number" then Config.PosXScale = decoded.PosXScale end
				if type(decoded.PosXOffset) == "number" then Config.PosXOffset = decoded.PosXOffset end
				if type(decoded.PosYScale) == "number" then Config.PosYScale = decoded.PosYScale end
				if type(decoded.PosYOffset) == "number" then Config.PosYOffset = decoded.PosYOffset end
				if type(decoded.MobXScale) == "number" then Config.MobXScale = decoded.MobXScale end
				if type(decoded.MobXOffset) == "number" then Config.MobXOffset = decoded.MobXOffset end
				if type(decoded.MobYScale) == "number" then Config.MobYScale = decoded.MobYScale end
				if type(decoded.MobYOffset) == "number" then Config.MobYOffset = decoded.MobYOffset end
			end
		end
	end)
end

local function saveConfig()
	if not canFS() then return end
	pcall(function()
		writefile(CFG_FILE, HttpService:JSONEncode(Config))
	end)
end

loadConfig()

local R = false
local elapsed = 0
local menuOpen = true

local function applyWalkSpeed()
	pcall(function()
		local char = L.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.WalkSpeed ~= Config.WalkSpeed then
			hum.WalkSpeed = Config.WalkSpeed
		end
	end)
end

L.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = Config.WalkSpeed
	end
end)
applyWalkSpeed()

local g = (gethui and gethui()) or C
if g:FindFirstChild("U271") then g.U271:Destroy() end

local sg = Instance.new("ScreenGui", g)
sg.Name = "U271"
sg.ResetOnSpawn = false

local grayBtn = Color3.fromRGB(68, 72, 82)
local grayBtnActive = Color3.fromRGB(92, 97, 110)
local grayBtnDark = Color3.fromRGB(54, 58, 66)
local grayBorder = Color3.fromRGB(130, 136, 150)

local function addStroke(inst, thickness)
	local s = Instance.new("UIStroke", inst)
	s.Color = grayBorder
	s.Thickness = thickness or 1.2
	return s
end

-- Компактная мобильная кнопка "Natro reconnect"
local mobBtn = Instance.new("TextButton", sg)
mobBtn.Name = "NatroReconnectBtn"
mobBtn.Size = UDim2.new(0, 110, 0, 26)
mobBtn.Position = UDim2.new(Config.MobXScale, Config.MobXOffset, Config.MobYScale, Config.MobYOffset)
mobBtn.BackgroundColor3 = Color3.fromRGB(42, 45, 53)
mobBtn.Text = "Natro reconnect"
mobBtn.TextColor3 = Color3.fromRGB(235, 238, 245)
mobBtn.Font = Enum.Font.GothamBold
mobBtn.TextSize = 11
mobBtn.Visible = Config.ShowMobileBtn
