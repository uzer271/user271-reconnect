local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PLACE_ID = 1537690962
local OWNER_HANDLE = "@uze9r"
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("Uze9rReconnectGui")
if old then
	old:Destroy()
end

-- State
local autoReconnect = true
local sameServer = true
local timerEnabled = false
local timerHours = 3
local elapsedSeconds = 0
local isRejoining = false

local autoDigEnabled = false
local autoTokensEnabled = false
local autoGlitterEnabled = false
local glitterMinutes = 15
local glitterElapsedSeconds = 0

local speedEnabled = false
local moveSpeed = 35
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50
local mobileBtnVisible = false

local DEFAULT_W = 292
local DEFAULT_H = 314
local menuWidth = DEFAULT_W
local menuHeight = DEFAULT_H

local currentTab = "Main"
local copyResetToken = 0

local flyBV = nil
local flyBG = nil

local sg = Instance.new("ScreenGui")
sg.Name = "Uze9rReconnectGui"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999999
sg.Parent = pg

local f = Instance.new("Frame")
f.Name = "MainFrame"
f.Size = UDim2.new(0, menuWidth, 0, menuHeight)
f.Position = UDim2.new(0.5, -math.floor(menuWidth / 2), 0.2, 0)
f.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
f.BorderSizePixel = 0
f.ZIndex = 1
f.Parent = sg
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Thickness = 2.2
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = f

-- Header
local top = Instance.new("TextLabel")
top.Size = UDim2.new(1, -68, 0, 28)
top.Position = UDim2.new(0, 8, 0, 0)
top.BackgroundTransparency = 1
top.Text = "@uze9r reconnect"
top.TextColor3 = Color3.new(1, 1, 1)
top.Font = Enum.Font.GothamBold
top.TextSize = 12
top.TextXAlignment = Enum.TextXAlignment.Left
top.Active = true
top.ZIndex = 3
top.Parent = f

local verLabel = Instance.new("TextLabel")
verLabel.Size = UDim2.new(0, 34, 0, 28)
verLabel.Position = UDim2.new(1, -60, 0, 0)
verLabel.BackgroundTransparency = 1
verLabel.Text = "0.9V"
verLabel.TextColor3 = Color3.fromRGB(165, 175, 195)
verLabel.Font = Enum.Font.GothamBold
verLabel.TextSize = 11
verLabel.TextXAlignment = Enum.TextXAlignment.Right
verLabel.Active = true
verLabel.ZIndex = 3
verLabel.Parent = f

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 22, 0, 22)
x.Position = UDim2.new(1, -26, 0, 3)
x.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
x.BorderSizePixel = 0
x.Text = "×"
x.TextColor3 = Color3.new(1, 1, 1)
x.Font = Enum.Font.GothamBold
x.TextSize = 14
x.ZIndex = 5
x.Parent = f
Instance.new("UICorner", x).CornerRadius = UDim.new(0, 5)

-- Mobile floating toggle button ("Natro reconnect") with bold white stroke
local mobileBtn = Instance.new("TextButton")
mobileBtn.Name = "NatroMobileBtn"
mobileBtn.Size = UDim2.new(0, 118, 0, 32)
mobileBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
mobileBtn.BackgroundColor3 = Color3.fromRGB(28, 31, 40)
mobileBtn.BorderSizePixel = 0
mobileBtn.Text = "Natro reconnect"
mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.TextSize = 11
mobileBtn.Visible = false
mobileBtn.ZIndex = 10
mobileBtn.Parent = sg
Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(0, 8)

local mobileStroke = Instance.new("UIStroke")
mobileStroke.Color = Color3.fromRGB(255, 255, 255)
mobileStroke.Thickness = 2.2
mobileStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mobileStroke.Parent = mobileBtn

local function bindTap(btn, callback)
	local debounce = false
	local function trigger()
		if debounce then
			return
		end
		debounce = true
		callback()
		task.delay(0.12, function()
			debounce = false
		end)
	end
	btn.Activated:Connect(trigger)
	btn.MouseButton1Click:Connect(trigger)
end

local function setCharacterCollision(canCollide)
	local char = lp.Character
	if not char then
		return
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = canCollide
		end
	end
end

local function stopFly()
	if flyBV then
		flyBV:Destroy()
		flyBV = nil
	end
	if flyBG then
		flyBG:Destroy()
		flyBG = nil
	end
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
	end
end

local function startFly()
	stopFly()
	local char = lp.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then
		return
	end

	hum.PlatformStand = true

	flyBG = Instance.new("BodyGyro")
	flyBG.P = 9e4
	flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBG.CFrame = root.CFrame
	flyBG.Parent = root

	flyBV = Instance.new("BodyVelocity")
	flyBV.Velocity = Vector3.zero
	flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBV.Parent = root
end

local function useGlitterItem()
	pcall(function()
		local events = ReplicatedStorage:FindFirstChild("Events")
		local actEvent = events and events:FindFirstChild("PlayerActivesCommand")
		if actEvent and actEvent:IsA("RemoteEvent") then
			actEvent:FireServer({ Name = "Glitter" })
			return
		end

		for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("RemoteEvent") and (obj.Name == "PlayerActivesCommand" or obj.Name == "UseItem" or obj.Name == "ItemCommand") then
				obj:FireServer({ Name = "Glitter" })
				obj:FireServer("Glitter")
			end
		end
	end)
end

bindTap(x, function()
	if mobileBtnVisible then
		f.Visible = false
	else
		flyEnabled = false
		noclipEnabled = false
		stopFly()
		setCharacterCollision(true)
		sg:Destroy()
	end
end)

bindTap(mobileBtn, function()
	f.Visible = not f.Visible
end)

-- Left Sidebar for Tabs
local SIDEBAR_W = 62
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -54)
sidebar.Position = UDim2.new(0, 6, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(19, 21, 27)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = f
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local function mkSideTab(yPos, txt)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 28)
	b.Position = UDim2.new(0, 4, 0, yPos)
	b.BackgroundColor3 = Color3.fromRGB(40, 45, 58)
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.ZIndex = 4
	b.Parent = sidebar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end

local tabMainBtn = mkSideTab(6, "Main")
local tabFarmBtn = mkSideTab(38, "Farm")
local tabMiscBtn = mkSideTab(70, "Misc")

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -(SIDEBAR_W + 14), 1, -54)
contentArea.Position = UDim2.new(0, SIDEBAR_W + 10, 0, 30)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 2
contentArea.Parent = f

local function mkContainer()
	local c = Instance.new("Frame")
	c.Size = UDim2.new(1, 0, 1, 0)
	c.BackgroundTransparency = 1
	c.BorderSizePixel = 0
	c.ZIndex = 3
	c.Parent = contentArea
	return c
end

local mainContainer = mkContainer()
local farmContainer = mkContainer()
local miscContainer = mkContainer()
farmContainer.Visible = false
miscContainer.Visible = false

-- Bottom Owner Button
local ownerBtn = Instance.new("TextButton")
ownerBtn.Name = "OwnerBtn"
ownerBtn.Size = UDim2.new(1, -16, 0, 18)
ownerBtn.Position = UDim2.new(0, 8, 1, -21)
ownerBtn.BackgroundTransparency = 1
ownerBtn.BorderSizePixel = 0
ownerBtn.Text = "Owner: " .. OWNER_HANDLE
ownerBtn.TextColor3 = Color3.fromRGB(165, 175, 195)
ownerBtn.Font = Enum.Font.GothamSemibold
ownerBtn.TextSize = 11
ownerBtn.TextXAlignment = Enum.TextXAlignment.Left
ownerBtn.ZIndex = 5
ownerBtn.Parent = f

local function mkBtn(parent, y, xScale, xOff, wScale, wOff, txt, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, wOff, 0, 24)
	b.Position = UDim2.new(xScale, xOff, 0, y)
	b.BackgroundColor3 = col
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 10
	b.ZIndex = 5
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

-- ==================== MAIN TAB ====================
local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -6, 0, 18)
st.Position = UDim2.new(0, 2, 0, 2)
st.BackgroundTransparency = 1
st.Text = "Status: Active"
st.TextColor3 = Color3.fromRGB(140, 220, 160)
st.Font = Enum.Font.Gotham
st.TextSize = 11
st.TextXAlignment = Enum.TextXAlignment.Left
st.ZIndex = 4
st.Parent = mainContainer

local b1 = mkBtn(mainContainer, 24, 0, 2, 1, -4, "Auto-Reconnect: ON", Color3.fromRGB(45, 140, 80))
local b2 = mkBtn(mainContainer, 52, 0, 2, 1, -4, "Server: Same", Color3.fromRGB(40, 45, 58))
local b3 = mkBtn(mainContainer, 80, 0, 2, 1, -4, "Test Error", Color3.fromRGB(175, 105, 35))

local tToggle = mkBtn(mainContainer, 108, 0, 2, 0.52, -4, "Timer: OFF", Color3.fromRGB(55, 60, 75))
local tMinus = mkBtn(mainContainer, 108, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))

local tVal = Instance.new("TextLabel")
tVal.Size = UDim2.new(0.20, -2, 0, 24)
tVal.Position = UDim2.new(0.66, 2, 0, 108)
tVal.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
tVal.BorderSizePixel = 0
tVal.Text = "3h"
tVal.TextColor3 = Color3.new(1, 1, 1)
tVal.Font = Enum.Font.GothamBold
tVal.TextSize = 11
tVal.ZIndex = 4
tVal.Parent = mainContainer
Instance.new("UICorner", tVal).CornerRadius = UDim.new(0, 6)

local tPlus = mkBtn(mainContainer, 108, 0.86, 2, 0.14, -4, "+", Color3.fromRGB(40, 45, 58))

local tInfo = Instance.new("TextLabel")
tInfo.Size = UDim2.new(1, -6, 0, 16)
tInfo.Position = UDim2.new(0, 2, 0, 136)
tInfo.BackgroundTransparency = 1
tInfo.Text = "Timer: OFF (3h)"
tInfo.TextColor3 = Color3.fromRGB(175, 182, 198)
tInfo.Font = Enum.Font.Gotham
tInfo.TextSize = 10
tInfo.TextXAlignment = Enum.TextXAlignment.Left
tInfo.ZIndex = 4
tInfo.Parent = mainContainer

-- ==================== FARM TAB ====================
local farmTitle = Instance.new("TextLabel")
farmTitle.Size = UDim2.new(1, -6, 0, 18)
farmTitle.Position = UDim2.new(0, 2, 0, 2)
farmTitle.BackgroundTransparency = 1
farmTitle.Text = "Bee Swarm Auto-Farm"
farmTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
farmTitle.Font = Enum.Font.GothamSemibold
farmTitle.TextSize = 11
farmTitle.TextXAlignment = Enum.TextXAlignment.Left
farmTitle.ZIndex = 4
farmTitle.Parent = farmContainer

local autoDigBtn = mkBtn(farmContainer, 24, 0, 2, 1, -4, "Auto-Dig: OFF", Color3.fromRGB(55, 60, 75))
local autoTokensBtn = mkBtn(farmContainer, 52, 0, 2, 1, -4, "Auto-Collect Tokens: OFF", Color3.fromRGB(55, 60, 75))

local glitterTitle = Instance.new("TextLabel")
glitterTitle.Size = UDim2.new(1, -6, 0, 16)
glitterTitle.Position = UDim2.new(0, 2, 0, 82)
glitterTitle.BackgroundTransparency = 1
glitterTitle.Text = "Auto-Glitter / Reglitter (15 - 60m)"
glitterTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
glitterTitle.Font = Enum.Font.GothamSemibold
glitterTitle.TextSize = 10
glitterTitle.TextXAlignment = Enum.TextXAlignment.Left
glitterTitle.ZIndex = 4
glitterTitle.Parent = farmContainer

local glitterToggleBtn = mkBtn(farmContainer, 100, 0, 2, 0.52, -4, "Auto-Glitter: OFF", Color3.fromRGB(55, 60, 75))
local glitterMinusBtn = mkBtn(farmContainer, 100, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))
local glitterValBtn = mkBtn(farmContainer, 100, 0.66, 2, 0.20, -2, "15m", Color3.fromRGB(32, 35, 44))
glitterValBtn.Font = Enum.Font.GothamBold
local glitterPlusBtn = mkBtn(farmContainer, 100, 0.86, 2, 0.14, -4, "+", Color3.fromRGB(40, 45, 58))

local useGlitterNowBtn = mkBtn(farmContainer, 128, 0, 2, 1, -4, "Use Glitter Now", Color3.fromRGB(52, 115, 195))

local glitterInfo = Instance.new("TextLabel")
glitterInfo.Size = UDim2.new(1, -6, 0, 16)
glitterInfo.Position = UDim2.new(0, 2, 0, 156)
glitterInfo.BackgroundTransparency = 1
glitterInfo.Text = "Auto-Glitter: OFF (15m)"
glitterInfo.TextColor3 = Color3.fromRGB(175, 182, 198)
glitterInfo.Font = Enum.Font.Gotham
glitterInfo.TextSize = 10
glitterInfo.TextXAlignment = Enum.TextXAlignment.Left
glitterInfo.ZIndex = 4
glitterInfo.Parent = farmContainer

-- ==================== MISC TAB ====================
local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -6, 0, 15)
speedTitle.Position = UDim2.new(0, 2, 0, 0)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "Player movespeed (1 - 100)"
speedTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
speedTitle.Font = Enum.Font.GothamSemibold
speedTitle.TextSize = 10
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.ZIndex = 4
speedTitle.Parent = miscContainer

local speedToggleBtn = mkBtn(miscContainer, 17, 0, 2, 0.52, -4, "Speed: OFF", Color3.fromRGB(55, 60, 75))
local speedMinusBtn = mkBtn(miscContainer, 17, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))
local speedValBtn = mkBtn(miscContainer, 17, 0.66, 2, 0.20, -2, tostring(moveSpeed), Color3.fromRGB(32, 35, 44))
speedValBtn.Font = Enum.Font.GothamBold
local speedPlusBtn = mkBtn(miscContainer, 17, 0.86, 2, 0.14, -4, "+", Color3.fromRGB(40, 45, 58))

-- Fly + Noclip row
local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, -6, 0, 15)
flyTitle.Position = UDim2.new(0, 2, 0, 45)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "Fly, Noclip & Fly speed (1 - 150)"
flyTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
flyTitle.Font = Enum.Font.GothamSemibold
flyTitle.TextSize = 10
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.ZIndex = 4
flyTitle.Parent = miscContainer

local flyToggleBtn = mkBtn(miscContainer, 62, 0, 2, 0.50, -3, "Fly: OFF", Color3.fromRGB(55, 60, 75))
local noclipToggleBtn = mkBtn(miscContainer, 62, 0.50, 2, 0.50, -4, "Noclip: OFF", Color3.fromRGB(55, 60, 75))

local flySpeedLbl = Instance.new("TextLabel")
flySpeedLbl.Size = UDim2.new(0.52, -4, 0, 24)
flySpeedLbl.Position = UDim2.new(0, 2, 0, 90)
flySpeedLbl.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
flySpeedLbl.BorderSizePixel = 0
flySpeedLbl.Text = "Fly speed"
flySpeedLbl.TextColor3 = Color3.fromRGB(200, 206, 220)
flySpeedLbl.Font = Enum.Font.GothamSemibold
flySpeedLbl.TextSize = 10
flySpeedLbl.ZIndex = 4
flySpeedLbl.Parent = miscContainer
Instance.new("UICorner", flySpeedLbl).CornerRadius = UDim.new(0, 6)

local flyMinusBtn = mkBtn(miscContainer, 90, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))
local flyValBtn = mkBtn(miscContainer, 90, 0.66, 2, 0.20, -2, tostring(flySpeed), Color3.fromRGB(32, 35, 44))
flyValBtn.Font = Enum.Font.GothamBold
local flyPlusBtn = mkBtn(miscContainer, 90, 0.86, 2, 0.14, -4, "+", Color3.fromRGB(40, 45, 58))

-- Mobile Button toggle
local mobToggleBtn = mkBtn(miscContainer, 118, 0, 2, 1, -4, "Show mobile button: OFF", Color3.fromRGB(55, 60, 75))

-- Menu Size controls (Width & Height)
local sizeTitle = Instance.new("TextLabel")
sizeTitle.Size = UDim2.new(1, -6, 0, 15)
sizeTitle.Position = UDim2.new(0, 2, 0, 146)
sizeTitle.BackgroundTransparency = 1
sizeTitle.Text = "Menu Size (Width / Height)"
sizeTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
sizeTitle.Font = Enum.Font.GothamSemibold
sizeTitle.TextSize = 10
sizeTitle.TextXAlignment = Enum.TextXAlignment.Left
sizeTitle.ZIndex = 4
sizeTitle.Parent = miscContainer

local wLabel = Instance.new("TextLabel")
wLabel.Size = UDim2.new(0.46, -4, 0, 24)
wLabel.Position = UDim2.new(0, 2, 0, 163)
wLabel.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
wLabel.BorderSizePixel = 0
wLabel.Text = "W: " .. menuWidth
wLabel.TextColor3 = Color3.new(1, 1, 1)
wLabel.Font = Enum.Font.GothamBold
wLabel.TextSize = 10
wLabel.ZIndex = 4
wLabel.Parent = miscContainer
Instance.new("UICorner", wLabel).CornerRadius = UDim.new(0, 6)

local wMinusBtn = mkBtn(miscContainer, 163, 0.46, 2, 0.27, -3, "-W", Color3.fromRGB(40, 45, 58))
local wPlusBtn = mkBtn(miscContainer, 163, 0.73, 2, 0.27, -4, "+W", Color3.fromRGB(40, 45, 58))

local hLabel = Instance.new("TextLabel")
hLabel.Size = UDim2.new(0.46, -4, 0, 24)
hLabel.Position = UDim2.new(0, 2, 0, 191)
hLabel.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
hLabel.BorderSizePixel = 0
hLabel.Text = "H: " .. menuHeight
hLabel.TextColor3 = Color3.new(1, 1, 1)
hLabel.Font = Enum.Font.GothamBold
hLabel.TextSize = 10
hLabel.ZIndex = 4
hLabel.Parent = miscContainer
Instance.new("UICorner", hLabel).CornerRadius = UDim.new(0, 6)

local hMinusBtn = mkBtn(miscContainer, 191, 0.46, 2, 0.27, -3, "-H", Color3.fromRGB(40, 45, 58))
local hPlusBtn = mkBtn(miscContainer, 191, 0.73, 2, 0.27, -4, "+H", Color3.fromRGB(40, 45, 58))

local resetSizeBtn = mkBtn(miscContainer, 219, 0, 2, 1, -4, "Reset Menu Size", Color3.fromRGB(45, 52, 68))

-- Clipboard helper
local function copyToClipboard(text)
	local candidates = {
		setclipboard,
		toclipboard,
		toClipboard,
		syn and syn.write_clipboard,
		syn and syn.setclipboard,
		Clipboard and Clipboard.set
	}
	for _, fn in ipairs(candidates) do
		if type(fn) == "function" then
			local ok = pcall(fn, text)
			if ok then
				return true
			end
		end
	end
	return false
end

bindTap(ownerBtn, function()
	copyToClipboard(OWNER_HANDLE)
	copyResetToken += 1
	local currentToken = copyResetToken
	ownerBtn.Text = "Username copied"
	ownerBtn.TextColor3 = Color3.fromRGB(140, 220, 160)
	task.delay(1.5, function()
		if copyResetToken == currentToken and ownerBtn and ownerBtn.Parent then
			ownerBtn.Text = "Owner: " .. OWNER_HANDLE
			ownerBtn.TextColor3 = Color3.fromRGB(165, 175, 195)
		end
	end)
end)

local function applyMenuSize()
	f.Size = UDim2.new(0, menuWidth, 0, menuHeight)
end

local function applyMoveSpeed()
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speedEnabled and moveSpeed or 16
	end
end

local function refresh()
	tabMainBtn.BackgroundColor3 = (currentTab == "Main") and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(40, 45, 58)
	tabFarmBtn.BackgroundColor3 = (currentTab == "Farm") and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(40, 45, 58)
	tabMiscBtn.BackgroundColor3 = (currentTab == "Misc") and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(40, 45, 58)

	mainContainer.Visible = (currentTab == "Main")
	farmContainer.Visible = (currentTab == "Farm")
	miscContainer.Visible = (currentTab == "Misc")

	-- Main
	b1.Text = autoReconnect and "Auto-Reconnect: ON" or "Auto-Reconnect: OFF"
	b1.BackgroundColor3 = autoReconnect and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(140, 55, 65)
	b2.Text = sameServer and "Server: Same" or "Server: Random"
	tVal.Text = timerHours .. "h"

	if timerEnabled then
		tToggle.Text = "Timer: ON"
		tToggle.BackgroundColor3 = Color3.fromRGB(52, 115, 195)
		local left = math.max(0, timerHours * 3600 - elapsedSeconds)
		tInfo.Text = string.format("Next rejoin in: %02d:%02d:%02d", math.floor(left / 3600), math.floor((left % 3600) / 60), left % 60)
	else
		tToggle.Text = "Timer: OFF"
		tToggle.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
		tInfo.Text = "Timer: OFF (" .. timerHours .. "h)"
	end

	-- Farm
	autoDigBtn.Text = autoDigEnabled and "Auto-Dig: ON" or "Auto-Dig: OFF"
	autoDigBtn.BackgroundColor3 = autoDigEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)

	autoTokensBtn.Text = autoTokensEnabled and "Auto-Collect Tokens: ON" or "Auto-Collect Tokens: OFF"
	autoTokensBtn.BackgroundColor3 = autoTokensEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)

	glitterToggleBtn.Text = autoGlitterEnabled and "Auto-Glitter: ON" or "Auto-Glitter: OFF"
	glitterToggleBtn.BackgroundColor3 = autoGlitterEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)
	glitterValBtn.Text = glitterMinutes .. "m"

	if autoGlitterEnabled then
		local gLeft = math.max(0, glitterMinutes * 60 - glitterElapsedSeconds)
		glitterInfo.Text = string.format("Next glitter in: %02d:%02d", math.floor(gLeft / 60), gLeft % 60)
	else
		glitterInfo.Text = "Auto-Glitter: OFF (" .. glitterMinutes .. "m)"
	end

	-- Misc
	speedToggleBtn.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
	speedToggleBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)
	speedValBtn.Text = tostring(moveSpeed)

	flyToggleBtn.Text = flyEnabled and "Fly: ON" or "Fly: OFF"
	flyToggleBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)

	noclipToggleBtn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
	noclipToggleBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)

	flyValBtn.Text = tostring(flySpeed)

	mobToggleBtn.Text = mobileBtnVisible and "Show mobile button: ON" or "Show mobile button: OFF"
	mobToggleBtn.BackgroundColor3 = mobileBtnVisible and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(55, 60, 75)
	mobileBtn.Visible = mobileBtnVisible

	wLabel.Text = "W: " .. menuWidth
	hLabel.Text = "H: " .. menuHeight
end

refresh()

local function rejoin(force)
	if (not force and not autoReconnect) or isRejoining then
		return
	end
	isRejoining = true
	st.Text = "Status: Rejoining..."
	st.TextColor3 = Color3.fromRGB(255, 205, 90)
	while task.wait(2) do
		pcall(function()
			if sameServer and #Players:GetPlayers() > 1 then
				TeleportService:TeleportToPlaceInstance(PLACE_ID, game.JobId, lp)
			else
				TeleportService:Teleport(PLACE_ID, lp)
			end
		end)
	end
end

-- Tab events
bindTap(tabMainBtn, function()
	currentTab = "Main"
	refresh()
end)

bindTap(tabFarmBtn, function()
	currentTab = "Farm"
	refresh()
end)

bindTap(tabMiscBtn, function()
	currentTab = "Misc"
	refresh()
end)

-- Main events
bindTap(b1, function()
	autoReconnect = not autoReconnect
	refresh()
end)

bindTap(b2, function()
	sameServer = not sameServer
	refresh()
end)

bindTap(b3, function()
	st.Text = "Test: Error 277!"
	st.TextColor3 = Color3.fromRGB(255, 185, 85)
	task.wait(0.7)
	rejoin(true)
end)

bindTap(tToggle, function()
	timerEnabled = not timerEnabled
	elapsedSeconds = 0
	refresh()
end)

bindTap(tMinus, function()
	if timerHours > 1 then
		timerHours -= 1
		elapsedSeconds = 0
		refresh()
	end
end)

bindTap(tPlus, function()
	if timerHours < 24 then
		timerHours += 1
		elapsedSeconds = 0
		refresh()
	end
end)

-- Farm events
bindTap(autoDigBtn, function()
	autoDigEnabled = not autoDigEnabled
	refresh()
end)

bindTap(autoTokensBtn, function()
	autoTokensEnabled = not autoTokensEnabled
	refresh()
end)

bindTap(glitterToggleBtn, function()
	autoGlitterEnabled = not autoGlitterEnabled
	glitterElapsedSeconds = 0
	if autoGlitterEnabled then
		useGlitterItem()
	end
	refresh()
end)

bindTap(glitterMinusBtn, function()
	glitterMinutes = math.clamp(glitterMinutes - 5, 15, 60)
	glitterElapsedSeconds = 0
	refresh()
end)

bindTap(glitterPlusBtn, function()
	glitterMinutes = math.clamp(glitterMinutes + 5, 15, 60)
	glitterElapsedSeconds = 0
	refresh()
end)

local glitterPresets = { 15, 20, 30, 45, 60 }
local glitterIdx = 1
bindTap(glitterValBtn, function()
	glitterIdx = (glitterIdx % #glitterPresets) + 1
	glitterMinutes = glitterPresets[glitterIdx]
	glitterElapsedSeconds = 0
	refresh()
end)

bindTap(useGlitterNowBtn, function()
	useGlitterItem()
	glitterElapsedSeconds = 0
	glitterInfo.Text = "Glitter used!"
	refresh()
end)

-- Misc events: WalkSpeed
bindTap(speedToggleBtn, function()
	speedEnabled = not speedEnabled
	applyMoveSpeed()
	refresh()
end)

bindTap(speedMinusBtn, function()
	moveSpeed = math.clamp(moveSpeed - 5, 1, 100)
	if speedEnabled then
		applyMoveSpeed()
	end
	refresh()
end)

bindTap(speedPlusBtn, function()
	moveSpeed = math.clamp(moveSpeed + 5, 1, 100)
	if speedEnabled then
		applyMoveSpeed()
	end
	refresh()
end)

local walkPresets = { 16, 35, 50, 75, 100 }
local walkIdx = 2
bindTap(speedValBtn, function()
	walkIdx = (walkIdx % #walkPresets) + 1
	moveSpeed = walkPresets[walkIdx]
	if speedEnabled then
		applyMoveSpeed()
	end
	refresh()
end)

-- Misc events: Fly & Noclip
bindTap(flyToggleBtn, function()
	flyEnabled = not flyEnabled
	if flyEnabled then
		startFly()
	else
		stopFly()
	end
	refresh()
end)

bindTap(noclipToggleBtn, function()
	noclipEnabled = not noclipEnabled
	if not noclipEnabled then
		setCharacterCollision(true)
	end
	refresh()
end)

bindTap(flyMinusBtn, function()
	flySpeed = math.clamp(flySpeed - 5, 1, 150)
	refresh()
end)

bindTap(flyPlusBtn, function()
	flySpeed = math.clamp(flySpeed + 5, 1, 150)
	refresh()
end)

local flyPresets = { 25, 50, 80, 110, 150 }
local flyIdx = 2
bindTap(flyValBtn, function()
	flyIdx = (flyIdx % #flyPresets) + 1
	flySpeed = flyPresets[flyIdx]
	refresh()
end)

-- Misc events: Mobile button
bindTap(mobToggleBtn, function()
	mobileBtnVisible = not mobileBtnVisible
	if not mobileBtnVisible then
		f.Visible = true
	end
	refresh()
end)

-- Misc events: Menu Size
bindTap(wMinusBtn, function()
	menuWidth = math.clamp(menuWidth - 16, 250, 440)
	applyMenuSize()
	refresh()
end)

bindTap(wPlusBtn, function()
	menuWidth = math.clamp(menuWidth + 16, 250, 440)
	applyMenuSize()
	refresh()
end)

bindTap(hMinusBtn, function()
	menuHeight = math.clamp(menuHeight - 16, 290, 460)
	applyMenuSize()
	refresh()
end)

bindTap(hPlusBtn, function()
	menuHeight = math.clamp(menuHeight + 16, 290, 460)
	applyMenuSize()
	refresh()
end)

bindTap(resetSizeBtn, function()
	menuWidth = DEFAULT_W
	menuHeight = DEFAULT_H
	applyMenuSize()
	refresh()
end)

-- Draggable helper
local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

makeDraggable(top, f)
makeDraggable(verLabel, f)
makeDraggable(mobileBtn, mobileBtn)

-- Stepped loop for Noclip
RunService.Stepped:Connect(function()
	if noclipEnabled then
		setCharacterCollision(false)
	end
end)

-- RenderStepped loop for Fly
RunService.RenderStepped:Connect(function()
	if not flyEnabled then
		return
	end
	local char = lp.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local cam = workspace.CurrentCamera
	if not root or not hum or not cam then
		return
	end

	if not flyBV or not flyBV.Parent or not flyBG or not flyBG.Parent then
		startFly()
		return
	end

	hum.PlatformStand = true
	flyBG.CFrame = cam.CFrame

	local moveDir = hum.MoveDirection
	local velocity = Vector3.zero

	if moveDir.Magnitude > 0 then
		local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
		local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
		if flatLook.Magnitude > 0.001 then
			flatLook = flatLook.Unit
		end
		if flatRight.Magnitude > 0.001 then
			flatRight = flatRight.Unit
		end

		local forwardAmount = moveDir:Dot(flatLook)
		local rightAmount = moveDir:Dot(flatRight)
		local flyVec = (cam.CFrame.LookVector * forwardAmount) + (cam.CFrame.RightVector * rightAmount)
		if flyVec.Magnitude > 0.001 then
			velocity = flyVec.Unit * flySpeed
		end
	end

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		velocity += Vector3.new(0, flySpeed, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		velocity -= Vector3.new(0, flySpeed, 0)
	end

	flyBV.Velocity = velocity
end)

-- Respawn handler
lp.CharacterAdded:Connect(function()
	task.wait(0.5)
	if speedEnabled then
		applyMoveSpeed()
	end
	if flyEnabled then
		startFly()
	end
end)

-- Farm loop (Auto-Dig & Auto-Collect Tokens)
task.spawn(function()
	while task.wait(0.25) do
		local char = lp.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if autoDigEnabled and char then
			pcall(function()
				local tool = char:FindFirstChildOfClass("Tool")
				if not tool then
					local bp = lp:FindFirstChildOfClass("Backpack")
					local firstTool = bp and bp:FindFirstChildOfClass("Tool")
					if firstTool and hum then
						hum:EquipTool(firstTool)
						tool = firstTool
					end
				end
				if tool then
					tool:Activate()
				end
			end)
		end

		if autoTokensEnabled and root and hum then
			pcall(function()
				local collectibles = workspace:FindFirstChild("Collectibles")
				if collectibles then
					local nearest, bestDist = nil, 48
					for _, item in ipairs(collectibles:GetChildren()) do
						if item:IsA("BasePart") and item.Transparency < 0.8 then
							local dist = (item.Position - root.Position).Magnitude
							if dist < bestDist then
								bestDist = dist
								nearest = item
							end
						end
					end
					if nearest then
						hum:MoveTo(nearest.Position)
					end
				end
			end)
		end
	end
end)

-- Main background loop
task.spawn(function()
	while task.wait(1) do
		if speedEnabled then
			pcall(function()
				local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.WalkSpeed ~= moveSpeed then
					hum.WalkSpeed = moveSpeed
				end
			end)
		end

		if autoReconnect and not isRejoining then
			pcall(function()
				local o = CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
				if o and o:FindFirstChild("ErrorPrompt") then
					rejoin(false)
				end
			end)
		end

		if timerEnabled and not isRejoining then
			elapsedSeconds += 1
			if elapsedSeconds >= timerHours * 3600 then
				elapsedSeconds = 0
				refresh()
				rejoin(true)
			else
				refresh()
			end
		end

		if autoGlitterEnabled then
			glitterElapsedSeconds += 1
			if glitterElapsedSeconds >= glitterMinutes * 60 then
				glitterElapsedSeconds = 0
				useGlitterItem()
			end
			refresh()
		end
	end
end)
