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

local autoReconnect = true
local sameServer = true
local timerEnabled = false
local timerHours = 3
local elapsedSeconds = 0
local isRejoining = false

local speedEnabled = false
local moveSpeed = 35
local flyEnabled = false
local flySpeed = 50
local mobileBtnVisible = false
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
f.Size = UDim2.new(0, 232, 0, 334)
f.Position = UDim2.new(0.5, -116, 0.2, 0)
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
		stopFly()
		sg:Destroy()
	end
end)

mobileBtn.MouseButton1Click:Connect(function()
	f.Visible = not f.Visible
end)

-- Tabs bar
local function mkTab(xPos, txt)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 105, 0, 22)
	b.Position = UDim2.new(0, xPos, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(40, 45, 58)
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = f
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end

local tabMainBtn = mkTab(8, "Main")
local tabMiscBtn = mkTab(119, "Misc")

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(1, 0, 1, -80)
mainContainer.Position = UDim2.new(0, 0, 0, 56)
mainContainer.BackgroundTransparency = 1
mainContainer.Parent = f

local miscContainer = Instance.new("Frame")
miscContainer.Size = UDim2.new(1, 0, 1, -80)
miscContainer.Position = UDim2.new(0, 0, 0, 56)
miscContainer.BackgroundTransparency = 1
miscContainer.Visible = false
miscContainer.Parent = f

local ownerBtn = Instance.new("TextButton")
ownerBtn.Name = "OwnerBtn"
ownerBtn.Size = UDim2.new(1, -16, 0, 20)
ownerBtn.Position = UDim2.new(0, 8, 1, -24)
ownerBtn.BackgroundTransparency = 1
ownerBtn.BorderSizePixel = 0
ownerBtn.Text = "Owner: " .. OWNER_HANDLE
ownerBtn.TextColor3 = Color3.fromRGB(165, 175, 195)
ownerBtn.Font = Enum.Font.GothamSemibold
ownerBtn.TextSize = 11
ownerBtn.TextXAlignment = Enum.TextXAlignment.Left
ownerBtn.Parent = f

local function mkBtn(parent, y, xPos, w, txt, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, w, 0, 26)
	b.Position = UDim2.new(0, xPos, 0, y)
	b.BackgroundColor3 = col
	b.BorderSizePixel = 0
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 11
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

-- MAIN TAB ELEMENTS
local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -16, 0, 18)
st.Position = UDim2.new(0, 8, 0, 0)
st.BackgroundTransparency = 1
st.Text = "Status: Active"
st.TextColor3 = Color3.fromRGB(140, 220, 160)
st.Font = Enum.Font.Gotham
st.TextSize = 11
st.TextXAlignment = Enum.TextXAlignment.Left
st.Parent = mainContainer

local b1 = mkBtn(mainContainer, 22, 8, 216, "Auto-Reconnect: ON", Color3.fromRGB(45, 140, 80))
local b2 = mkBtn(mainContainer, 52, 8, 216, "Server: Same", Color3.fromRGB(40, 45, 58))
local b3 = mkBtn(mainContainer, 82, 8, 216, "Test Error", Color3.fromRGB(175, 105, 35))
local tToggle = mkBtn(mainContainer, 112, 8, 118, "Timer: OFF", Color3.fromRGB(55, 60, 75))
local tMinus = mkBtn(mainContainer, 112, 130, 26, "-", Color3.fromRGB(40, 45, 58))

local tVal = Instance.new("TextLabel")
tVal.Size = UDim2.new(0, 40, 0, 26)
tVal.Position = UDim2.new(0, 160, 0, 112)
tVal.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
tVal.BorderSizePixel = 0
tVal.Text = "3h"
tVal.TextColor3 = Color3.new(1, 1, 1)
tVal.Font = Enum.Font.GothamBold
tVal.TextSize = 11
tVal.Parent = mainContainer
Instance.new("UICorner", tVal).CornerRadius = UDim.new(0, 6)

local tPlus = mkBtn(mainContainer, 112, 204, 26, "+", Color3.fromRGB(40, 45, 58))

local tInfo = Instance.new("TextLabel")
tInfo.Size = UDim2.new(1, -16, 0, 16)
tInfo.Position = UDim2.new(0, 8, 0, 142)
tInfo.BackgroundTransparency = 1
tInfo.Text = "Timer: OFF (3h)"
tInfo.TextColor3 = Color3.fromRGB(175, 182, 198)
tInfo.Font = Enum.Font.Gotham
tInfo.TextSize = 10
tInfo.TextXAlignment = Enum.TextXAlignment.Left
tInfo.Parent = mainContainer

-- MISC TAB ELEMENTS
local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -16, 0, 18)
speedTitle.Position = UDim2.new(0, 8, 0, 0)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "Player movespeed (1 - 100)"
speedTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
speedTitle.Font = Enum.Font.GothamSemibold
speedTitle.TextSize = 11
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = miscContainer

local speedToggleBtn = mkBtn(miscContainer, 20, 8, 118, "Movespeed: OFF", Color3.fromRGB(55, 60, 75))
local speedMinusBtn = mkBtn(miscContainer, 20, 130, 26, "-", Color3.fromRGB(40, 45, 58))
local speedValBtn = mkBtn(miscContainer, 20, 160, 40, tostring(moveSpeed), Color3.fromRGB(32, 35, 44))
speedValBtn.Font = Enum.Font.GothamBold
local speedPlusBtn = mkBtn(miscContainer, 20, 204, 26, "+", Color3.fromRGB(40, 45, 58))

local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, -16, 0, 18)
flyTitle.Position = UDim2.new(0, 8, 0, 52)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "Fly & Fly movespeed (1 - 150)"
flyTitle.TextColor3 = Color3.fromRGB(200, 206, 220)
flyTitle.Font = Enum.Font.GothamSemibold
flyTitle.TextSize = 11
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.Parent = miscContainer

local flyToggleBtn = mkBtn(miscContainer, 72, 8, 118, "Fly: OFF", Color3.fromRGB(55, 60, 75))
local flyMinusBtn = mkBtn(miscContainer, 72, 130, 26, "-", Color3.fromRGB(40, 45, 58))
local flyValBtn = mkBtn(miscContainer, 72, 160, 40, tostring(flySpeed), Color3.fromRGB(32, 35, 44))
flyValBtn.Font = Enum.Font.GothamBold
local flyPlusBtn = mkBtn(miscContainer, 72, 204, 26, "+", Color3.fromRGB(40, 45, 58))

local mobToggleBtn = mkBtn(miscContainer, 108, 8, 216, "Show mobile button: OFF", Color3.fromRGB(55, 60, 75))

local miscHint = Instance.new("TextLabel")
miscHint.Size = UDim2.new(1, -16, 0, 32)
miscHint.Position = UDim2.new(0, 8, 0, 140)
miscHint.BackgroundTransparency = 1
miscHint.Text = "Fly uses camera direction + joystick. Tap numbers for quick presets."
miscHint.TextColor3 = Color3.fromRGB(150, 158, 175)
miscHint.Font = Enum.Font.Gotham
miscHint.TextSize = 10
miscHint.TextWrapped = true
miscHint.TextXAlignment = Enum.TextXAlignment.Left
miscHint.Parent = miscContainer

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

local function applyMoveSpeed()
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = speedEnabled and moveSpeed or 16
	end
end

local function refresh()
	tabMainBtn.BackgroundColor3 = (currentTab == "Main") and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(40, 45, 58)
	tabMiscBtn.BackgroundColor3 = (currentTab == "Misc") and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(40, 45, 58)
	mainContainer.Visible = (currentTab == "Main")
	miscContainer.Visible = (currentTab == "Misc")

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

	speedToggleBtn.Text = speedEnabled and "Movespeed: ON" or "Movespeed: OFF"
	speedToggleBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)
	speedValBtn.Text = tostring(moveSpeed)

	flyToggleBtn.Text = flyEnabled and "Fly: ON" or "Fly: OFF"
	flyToggleBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(55, 60, 75)
	flyValBtn.Text = tostring(flySpeed)

	mobToggleBtn.Text = mobileBtnVisible and "Show mobile button: ON" or "Show mobile button: OFF"
	mobToggleBtn.BackgroundColor3 = mobileBtnVisible and Color3.fromRGB(52, 115, 195) or Color3.fromRGB(55, 60, 75)
	mobileBtn.Visible = mobileBtnVisible
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

-- Misc events: WalkSpeed
speedToggleBtn.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	applyMoveSpeed()
	refresh()
end)

speedMinusBtn.MouseButton1Click:Connect(function()
	moveSpeed = math.clamp(moveSpeed - 5, 1, 100)
	if speedEnabled then
		applyMoveSpeed()
	end
	refresh()
end)

speedPlusBtn.MouseButton1Click:Connect(function()
	moveSpeed = math.clamp(moveSpeed + 5, 1, 100)
	if speedEnabled then
		applyMoveSpeed()
	end
	refresh()
end)

local walkPresets = { 16, 35, 50, 75, 100 }
local walkIdx = 2
speedValBtn.MouseButton1Click:Connect(function()
	walkIdx = (walkIdx % #walkPresets) + 1
	moveSpeed = walkPresets[walkIdx]
	if speedEnabled then
		applyMoveSpeed()
	end
	refresh()
end)

-- Misc events: Fly
flyToggleBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled then
		startFly()
	else
		stopFly()
	end
	refresh()
end)

flyMinusBtn.MouseButton1Click:Connect(function()
	flySpeed = math.clamp(flySpeed - 5, 1, 150)
	refresh()
end)

flyPlusBtn.MouseButton1Click:Connect(function()
	flySpeed = math.clamp(flySpeed + 5, 1, 150)
	refresh()
end)

local flyPresets = { 25, 50, 80, 110, 150 }
local flyIdx = 2
flyValBtn.MouseButton1Click:Connect(function()
	flyIdx = (flyIdx % #flyPresets) + 1
	flySpeed = flyPresets[flyIdx]
	refresh()
end)

-- Misc events: Mobile button
mobToggleBtn.MouseButton1Click:Connect(function()
	mobileBtnVisible = not mobileBtnVisible
	if not mobileBtnVisible then
		f.Visible = true
	end
	refresh()
end)

-- Helper for draggable UI objects
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

-- Fly movement loop (supports mobile thumbstick + camera direction)
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
	end
end)
