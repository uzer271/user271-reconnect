local P, T, C, U, L = 1537690962, game:GetService("TeleportService"), game:GetService("CoreGui"), game:GetService("UserInputService"), game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")

local CFG_FILE = "uze9r_reconnect_cfg.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/uzer271/user271-reconnect/refs/heads/main/reconnect.lua"

local Config = {
	AutoReconnect = true,
	SameServer = true,
	TimerEnabled = false,
	TimerHours = 3,
	PosXScale = 0.5,
	PosXOffset = -116,
	PosYScale = 0.2,
	PosYOffset = 0
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
				if type(decoded.PosXScale) == "number" then Config.PosXScale = decoded.PosXScale end
				if type(decoded.PosXOffset) == "number" then Config.PosXOffset = decoded.PosXOffset end
				if type(decoded.PosYScale) == "number" then Config.PosYScale = decoded.PosYScale end
				if type(decoded.PosYOffset) == "number" then Config.PosYOffset = decoded.PosYOffset end
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

local g = (gethui and gethui()) or C
if g:FindFirstChild("U271") then g.U271:Destroy() end

local sg = Instance.new("ScreenGui", g)
sg.Name = "U271"
sg.ResetOnSpawn = false

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 232, 0, 224)
f.Position = UDim2.new(Config.PosXScale, Config.PosXOffset, Config.PosYScale, Config.PosYOffset)
f.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
f.BorderSizePixel = 0
f.Active = true
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local top = Instance.new("TextLabel", f)
top.Size = UDim2.new(1, -30, 0, 28)
top.Position = UDim2.new(0, 8, 0, 0)
top.BackgroundTransparency = 1
top.Text = "@uze9r reconnect"
top.TextColor3 = Color3.new(1, 1, 1)
top.Font = Enum.Font.GothamBold
top.TextSize = 12
top.TextXAlignment = Enum.TextXAlignment.Left
top.Active = true

local x = Instance.new("TextButton", f)
x.Size = UDim2.new(0, 20, 0, 20)
x.Position = UDim2.new(1, -24, 0, 4)
x.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
x.Text = "×"
x.TextColor3 = Color3.new(1, 1, 1)
x.Font = Enum.Font.GothamBold
Instance.new("UICorner", x).CornerRadius = UDim.new(0, 5)
x.MouseButton1Click:Connect(function() sg:Destroy() end)

local st = Instance.new("TextLabel", f)
st.Size = UDim2.new(1, -16, 0, 18)
st.Position = UDim2.new(0, 8, 0, 28)
st.BackgroundTransparency = 1
st.Text = Config.AutoReconnect and "Status: Active" or "Status: Disabled"
st.TextColor3 = Config.AutoReconnect and Color3.fromRGB(140, 220, 160) or Color3.fromRGB(235, 130, 135)
st.Font = Enum.Font.Gotham
st.TextSize = 11
st.TextXAlignment = Enum.TextXAlignment.Left

local function mk(y, txt, col, w, xPos)
	local b = Instance.new("TextButton", f)
	b.Size = w or UDim2.new(1, -16, 0, 26)
	b.Position = UDim2.new(0, xPos or 8, 0, y)
	b.BackgroundColor3 = col
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 11
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local b1 = mk(49, "", Color3.fromRGB(45, 140, 80))
local b2 = mk(79, "", Color3.fromRGB(40, 45, 58))
local b3 = mk(109, "Test Error", Color3.fromRGB(175, 105, 35))

local tToggle = mk(139, "", Color3.fromRGB(55, 60, 75), UDim2.new(0, 118, 0, 26), 8)
local tMinus = mk(139, "-", Color3.fromRGB(40, 45, 58), UDim2.new(0, 26, 0, 26), 130)

local tVal = Instance.new("TextLabel", f)
tVal.Size = UDim2.new(0, 40, 0, 26)
tVal.Position = UDim2.new(0, 160, 0, 139)
tVal.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
tVal.Text = Config.TimerHours .. "h"
tVal.TextColor3 = Color3.new(1, 1, 1)
tVal.Font = Enum.Font.GothamBold
tVal.TextSize = 11
Instance.new("UICorner", tVal).CornerRadius = UDim.new(0, 6)

local tPlus = mk(139, "+", Color3.fromRGB(40, 45, 58), UDim2.new(0, 26, 0, 26), 204)

local tInfo = Instance.new("TextLabel", f)
tInfo.Size = UDim2.new(1, -16, 0, 16)
tInfo.Position = UDim2.new(0, 8, 0, 169)
tInfo.BackgroundTransparency = 1
tInfo.Text = ""
tInfo.TextColor3 = Color3.fromRGB(175, 182, 198)
tInfo.Font = Enum.Font.Gotham
tInfo.TextSize = 10
tInfo.TextXAlignment = Enum.TextXAlignment.Left

local function fmtTime(sec)
	sec = math.max(0, math.floor(sec))
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = sec % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function refreshTimerUI()
	tVal.Text = Config.TimerHours .. "h"
	if Config.TimerEnabled then
		tToggle.Text = "Timer: ON"
		tToggle.BackgroundColor3 = Color3.fromRGB(52, 115, 195)
		local left = math.max(0, Config.TimerHours * 3600 - elapsed)
		tInfo.Text = "Next rejoin in: " .. fmtTime(left)
	else
		tToggle.Text = "Timer: OFF"
		tToggle.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
		tInfo.Text = "Timer: OFF (" .. Config.TimerHours .. "h)"
	end
end

local function refreshMainUI()
	b1.Text = Config.AutoReconnect and "Auto-Reconnect: ON" or "Auto-Reconnect: OFF"
	b1.BackgroundColor3 = Config.AutoReconnect and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(140, 55, 65)
	b2.Text = Config.SameServer and "Server: Same" or "Server: Random"
	if not R then
		st.Text = Config.AutoReconnect and "Status: Active" or "Status: Disabled"
		st.TextColor3 = Config.AutoReconnect and Color3.fromRGB(140, 220, 160) or Color3.fromRGB(235, 130, 135)
	end
	refreshTimerUI()
end

refreshMainUI()

local function queueNextRun()
	local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
	if type(qot) == "function" then
		pcall(function()
			qot('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
		end)
	end
end

local function rejoin(force)
	if (not force and not Config.AutoReconnect) or R then return end
	R = true
	saveConfig()
	queueNextRun()
	st.Text = "Status: Rejoining..."
	st.TextColor3 = Color3.fromRGB(255, 205, 90)
	while task.wait(2) do
		pcall(function()
			if Config.SameServer and #game.Players:GetPlayers() > 1 then
				T:TeleportToPlaceInstance(P, game.JobId, L)
			else
				T:Teleport(P, L)
			end
		end)
	end
end

b1.MouseButton1Click:Connect(function()
	Config.AutoReconnect = not Config.AutoReconnect
	saveConfig()
	refreshMainUI()
end)

b2.MouseButton1Click:Connect(function()
	Config.SameServer = not Config.SameServer
	saveConfig()
	refreshMainUI()
end)

b3.MouseButton1Click:Connect(function()
	st.Text = "Test: Error 277!"
	st.TextColor3 = Color3.fromRGB(255, 185, 85)
	pcall(function()
		local o = C:FindFirstChild("RobloxPromptGui") and C.RobloxPromptGui:FindFirstChild("promptOverlay")
		if o then
			local m = Instance.new("TextLabel", o)
			m.Name = "TestErr"
			m.Size = UDim2.new(0, 300, 0, 80)
			m.Position = UDim2.new(0.5, -150, 0.5, -40)
			m.BackgroundColor3 = Color3.fromRGB(45, 48, 56)
			m.Text = "Disconnected (Error 277)"
			m.TextColor3 = Color3.new(1, 1, 1)
			m.Font = Enum.Font.GothamBold
			m.TextSize = 14
		end
	end)
	task.wait(0.7)
	rejoin(true)
end)

tToggle.MouseButton1Click:Connect(function()
	Config.TimerEnabled = not Config.TimerEnabled
	elapsed = 0
	saveConfig()
	refreshTimerUI()
end)

tMinus.MouseButton1Click:Connect(function()
	if Config.TimerHours > 1 then
		Config.TimerHours -= 1
		elapsed = 0
		saveConfig()
		refreshTimerUI()
	end
end)

tPlus.MouseButton1Click:Connect(function()
	if Config.TimerHours < 24 then
		Config.TimerHours += 1
		elapsed = 0
		saveConfig()
		refreshTimerUI()
	end
end)

-- Dragging (Mouse + Touch) + saving position
local dragging, dragInput, dragStart, startPos
top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = f.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				Config.PosXScale = f.Position.X.Scale
				Config.PosXOffset = f.Position.X.Offset
				Config.PosYScale = f.Position.Y.Scale
				Config.PosYOffset = f.Position.Y.Offset
				saveConfig()
			end
		end)
	end
end)

top.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

U.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Disconnect watch + timer loop
task.spawn(function()
	while task.wait(1) do
		if Config.AutoReconnect and not R then
			pcall(function()
				local o = C:FindFirstChild("RobloxPromptGui") and C.RobloxPromptGui:FindFirstChild("promptOverlay")
				if o and o:FindFirstChild("ErrorPrompt") then
					rejoin(false)
				end
			end)
		end

		if Config.TimerEnabled and not R then
			elapsed += 1
			local limit = Config.TimerHours * 3600
			if elapsed >= limit then
				elapsed = 0
				refreshTimerUI()
				rejoin(true)
			else
				refreshTimerUI()
			end
		end
	end
end)
