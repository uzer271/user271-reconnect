local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

local speedEnabled = false
local moveSpeed = 35
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50
local mobileBtnVisible = false

local DEFAULT_W = 286
local DEFAULT_H = 310
local menuWidth = DEFAULT_W
local menuHeight = DEFAULT_H

local currentTab = "Main"
local copyResetToken = 0

local flyBV = nil
local flyBG = nil

local sg = Instance.new("ScreenGui")
sg.Name = "Uze9rReconnectGui"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999999
sg.Parent = pg

local f = Instance.new("Frame")
f.Name = "MainFrame"
f.Size = UDim2.new(0, menuWidth, 0, menuHeight)
f.Position = UDim2.new(0.5, -math.floor(menuWidth / 2), 0.2, 0)
f.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
f.BorderSizePixel = 0
f.Active = true
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
verLabel.Parent = f

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 20, 0, 20)
x.Position = UDim2.new(1, -24, 0, 4)
x.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
x.BorderSizePixel = 0
x.Text = "×"
x.TextColor3 = Color3.new(1, 1, 1)
x.Font = Enum.Font.GothamBold
x.TextSize = 14
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
mobileBtn.Active = true
mobileBtn.Parent = sg
Instance.new("UICorner", mobileBtn).CornerRadius = UDim.new(0, 8)

local mobileStroke = Instance.new("UIStroke")
mobileStroke.Color = Color3.fromRGB(255, 255, 255)
mobileStroke.Thickness = 2.2
mobileStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mobileStroke.Parent = mobileBtn

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

x.MouseButton1Click:Connect(function()
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

mobileBtn.MouseButton1Click:Connect(function()
	f.Visible = not f.Visible
end)

-- Left Sidebar for Tabs
local SIDEBAR_W = 62
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -56)
sidebar.Position = UDim2.new(0, 6, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(19, 21, 27)
sidebar.BorderSizePixel = 0
sidebar.Parent = f
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 6)

local function mkSideTab(yPos, txt)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 26)
	b.Position = UDim2.new(0, 4, 0, yPos)
	b.BackgroundColor3 = Color3.fromRGB(40, 45, 58)
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = sidebar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end

local tabMainBtn = mkSideTab(6, "Main")
local tabFarmBtn = mkSideTab(36, "Farm")
local tabMiscBtn = mkSideTab(66, "Misc")

-- Content Area (right of sidebar, responsive to menuWidth & menuHeight)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -(SIDEBAR_W + 14), 1, -56)
contentArea.Position = UDim2.new(0, SIDEBAR_W + 10, 0, 30)
contentArea.BackgroundTransparency = 1
contentArea.Parent = f

local function mkContainer()
	local c = Instance.new("ScrollingFrame")
	c.Size = UDim2.new(1, 0, 1, 0)
	c.BackgroundTransparency = 1
	c.BorderSizePixel = 0
	c.ScrollBarThickness = 3
	c.ScrollBarImageColor3 = Color3.fromRGB(110, 120, 140)
	c.CanvasSize = UDim2.new(0, 0, 0, 0)
	c.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
ownerBtn.Position = UDim2.new(0, 8, 1, -22)
ownerBtn.BackgroundTransparency = 1
ownerBtn.BorderSizePixel = 0
ownerBtn.Text = "Owner: " .. OWNER_HANDLE
ownerBtn.TextColor3 = Color3.fromRGB(165, 175, 195)
ownerBtn.Font = Enum.Font.GothamSemibold
ownerBtn.TextSize = 11
ownerBtn.TextXAlignment = Enum.TextXAlignment.Left
ownerBtn.Parent = f

local function mkBtn(parent, y, xScale, xOff, wScale, wOff, txt, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, wOff, 0, 25)
	b.Position = UDim2.new(xScale, xOff, 0, y)
	b.BackgroundColor3 = col
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 10
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
st.Parent = mainContainer

local b1 = mkBtn(mainContainer, 24, 0, 2, 1, -6, "Auto-Reconnect: ON", Color3.fromRGB(45, 140, 80))
local b2 = mkBtn(mainContainer, 53, 0, 2, 1, -6, "Server: Same", Color3.fromRGB(40, 45, 58))
local b3 = mkBtn(mainContainer, 82, 0, 2, 1, -6, "Test Error", Color3.fromRGB(175, 105, 35))

local tToggle = mkBtn(mainContainer, 111, 0, 2, 0.52, -4, "Timer: OFF", Color3.fromRGB(55, 60, 75))
local tMinus = mkBtn(mainContainer, 111, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))

local tVal = Instance.new("TextLabel")
tVal.Size = UDim2.new(0.20, -2, 0, 25)
tVal.Position = UDim2.new(0.66, 2, 0, 111)
tVal.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
tVal.BorderSizePixel = 0
tVal.Text = "3h"
tVal.TextColor3 = Color3.new(1, 1, 1)
tVal.Font = Enum.Font.GothamBold
tVal.TextSize = 11
tVal.Parent = mainContainer
Instance.new("UICorner", tVal).CornerRadius = UDim.new(0, 6)

local tPlus = mkBtn(mainContainer, 111, 0.86, 2, 0.14, -6, "+", Color3.fromRGB(40, 45, 58))

local tInfo = Instance.new("TextLabel")
tInfo.Size = UDim2.new(1, -6, 0, 16)
tInfo.Position = UDim2.new(0, 2, 0, 140)
tInfo.BackgroundTransparency = 1
tInfo.Text = "Timer: OFF (3h)"
tInfo.TextColor3 = Color3.fromRGB(175, 182, 198)
tInfo.Font = Enum.Font.Gotham
tInfo.TextSize = 10
tInfo.TextXAlignment = Enum.TextXAlignment.Left
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
farmTitle.Parent = farmContainer

local autoDigBtn = mkBtn(farmContainer, 24, 0, 2, 1, -6, "Auto-Dig: OFF", Color3.fromRGB(55, 60, 75))
local autoTokensBtn = mkBtn(farmContainer, 53, 0, 2, 1, -6, "Auto-Collect Tokens: OFF", Color3.fromRGB(55, 60, 75))

local farmHint = Instance.new("TextLabel")
farmHint.Size = UDim2.new(1, -6, 0, 44)
farmHint.Position = UDim2.new(0, 2, 0, 84)
farmHint.BackgroundTransparency = 1
farmHint.Text = "Auto-Dig swings equipped collector. Auto-Collect pulls toward nearby field tokens."
farmHint.TextColor3 = Color3.fromRGB(150, 158, 175)
farmHint.Font = Enum.Font.Gotham
farmHint.TextSize = 10
farmHint.TextWrapped = true
farmHint.TextXAlignment = Enum.TextXAlignment.Left
farmHint.Parent = farmContainer

-- ==================== MISC TAB ====================
local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -6, 0, 16)
speedTitle.Position = UDim2.new(0, 2, 0, 2)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "Player movespeed (1 - 100)"
speedTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
speedTitle.Font = Enum.Font.GothamSemibold
speedTitle.TextSize = 10
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = miscContainer

local speedToggleBtn = mkBtn(miscContainer, 20, 0, 2, 0.52, -4, "Speed: OFF", Color3.fromRGB(55, 60, 75))
local speedMinusBtn = mkBtn(miscContainer, 20, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))
local speedValBtn = mkBtn(miscContainer, 20, 0.66, 2, 0.20, -2, tostring(moveSpeed), Color3.fromRGB(32, 35, 44))
speedValBtn.Font = Enum.Font.GothamBold
local speedPlusBtn = mkBtn(miscContainer, 20, 0.86, 2, 0.14, -6, "+", Color3.fromRGB(40, 45, 58))

-- Fly + Noclip row
local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, -6, 0, 16)
flyTitle.Position = UDim2.new(0, 2, 0, 50)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "Fly, Noclip & Fly speed (1 - 150)"
flyTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
flyTitle.Font = Enum.Font.GothamSemibold
flyTitle.TextSize = 10
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.Parent = miscContainer

local flyToggleBtn = mkBtn(miscContainer, 68, 0, 2, 0.50, -4, "Fly: OFF", Color3.fromRGB(55, 60, 75))
local noclipToggleBtn = mkBtn(miscContainer, 68, 0.50, 2, 0.50, -6, "Noclip: OFF", Color3.fromRGB(55, 60, 75))

local flySpeedLbl = Instance.new("TextLabel")
flySpeedLbl.Size = UDim2.new(0.52, -4, 0, 25)
flySpeedLbl.Position = UDim2.new(0, 2, 0, 97)
flySpeedLbl.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
flySpeedLbl.BorderSizePixel = 0
flySpeedLbl.Text = "Fly speed"
flySpeedLbl.TextColor3 = Color3.fromRGB(200, 206, 220)
flySpeedLbl.Font = Enum.Font.GothamSemibold
flySpeedLbl.TextSize = 10
flySpeedLbl.Parent = miscContainer
Instance.new("UICorner", flySpeedLbl).CornerRadius = UDim.new(0, 6)

local flyMinusBtn = mkBtn(miscContainer, 97, 0.52, 2, 0.14, -2, "-", Color3.fromRGB(40, 45, 58))
local flyValBtn = mkBtn(miscContainer, 97, 0.66, 2, 0.20, -2, tostring(flySpeed), Color3.fromRGB(32, 35, 44))
flyValBtn.Font = Enum.Font.GothamBold
local flyPlusBtn = mkBtn(miscContainer, 97, 0.86, 2, 0.14, -6, "+", Color3.fromRGB(40, 45, 58))

-- Mobile Button toggle
local mobToggleBtn = mkBtn(miscContainer, 128, 0, 2, 1, -6, "Show mobile button: OFF", Color3.fromRGB(55, 60, 75))

-- Menu Size controls (Width & Height)
local sizeTitle = Instance.new("TextLabel")
sizeTitle.Size = UDim2.new(1, -6, 0, 16)
sizeTitle.Position = UDim2.new(0, 2, 0, 158)
sizeTitle.BackgroundTransparency = 1
sizeTitle.Text = "Menu Size (Width / Height)"
sizeTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
sizeTitle.Font = Enum.Font.GothamSemibold
sizeTitle.TextSize = 10
sizeTitle.TextXAlignment = Enum.TextXAlignment.Left
sizeTitle.Parent = miscContainer

local wLabel = Instance.new("TextLabel")
wLabel.Size = UDim2.new(0.46, -4, 0, 24)
wLabel.Position = UDim2.new(0, 2, 0, 176)
wLabel.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
wLabel.BorderSizePixel = 0
wLabel.Text = "W: " .. menuWidth
wLabel.TextColor3 = Color3.new(1, 1, 1)
wLabel.Font = Enum.Font.GothamBold
wLabel.TextSize = 10
wLabel.Parent = miscContainer
Instance.new("UICorner", wLabel).CornerRadius = UDim.new(0, 6)

local wMinusBtn = mkBtn(miscContainer, 176, 0.46, 2, 0.27, -3, "-W", Color3.fromRGB(40, 45, 58))
local wPlusBtn = mkBtn(miscContainer, 176, 0.73, 2, 0.27, -6, "+W", Color3.fromRGB(40, 45, 58))

local hLabel = Instance.new("TextLabel")
hLabel.Size = UDim2.new(0.46, -4, 0, 24)
hLabel.Position = UDim2.new(0, 2, 0, 204)
hLabel.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
hLabel.BorderSizePixel = 0
hLabel.Text = "H: " .. menuHeight
hLabel.TextColor3 = Color3.new(1, 1, 1)
hLabel.Font = Enum.Font.GothamBold
hLabel.TextSize = 10
hLabel.Parent = miscContainer
Instance.new("UICorner", hLabel).CornerRadius = UDim.new(0, 6)

local hMinusBtn = mkBtn(miscContainer, 204, 0.46, 2, 0.27, -3, "-H", Color3.fromRGB(40, 45, 58))
local hPlusBtn = mkBtn(miscContainer, 204, 0.73, 2, 0.27, -6, "+H", Color3.fromRGB(40, 45, 58))

local resetSizeBtn = mkBtn(miscContainer, 232, 0, 2, 1, -6, "Reset Menu Size", Color3.fromRGB(45, 52, 68))

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

ownerBtn.MouseButton1Click:Connect(function()
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
tabMainBtn.MouseButton1Click:Connect(function()
	currentTab = "Main"
	refresh()
end)

tabFarmBtn.MouseButton1Click:Connect(function()
	currentTab = "Farm"
	refresh()
end)

tabMiscBtn.MouseButton1Click:Connect(function()
	currentTab = "Misc"
	refresh()
end)

-- Main events
b1.MouseButton1Click:Connect(function()
	autoReconnect = not autoReconnect
	refresh()
end)

b2.MouseButton1Click:Connect(function()
	sameServer = not sameServer
	refresh()
end)

b3.MouseButton1Click:Connect(function()
	st.Text = "Test: Error 277!"
	st.TextColor3 = Color3.fromRGB(255, 185, 85)
	task.wait(0.7)
	rejoin(true)
end)

tToggle.MouseButton1Click:Connect(function()
	timerEnabled = not timerEnabled
	elapsedSeconds = 0
	refresh()
end)

tMinus.MouseButton1Click:Connect(function()
	if timerHours > 1 then
		timerHours -= 1
		elapsedSeconds = 0
		refresh()
	end
end)

tPlus.MouseButton1Click:Connect(function()
	if timerHours < 24 then
		timerHours += 1
		elapsedSeconds = 0
		refresh()
	end
end)
