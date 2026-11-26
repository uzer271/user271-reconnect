local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local PLACE_ID = 1537690962
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("Uze9rReconnectGui")
if old then old:Destroy() end

local autoReconnect = true
local sameServer = true
local timerEnabled = false
local timerHours = 3
local elapsedSeconds = 0
local isRejoining = false

local sg = Instance.new("ScreenGui")
sg.Name = "Uze9rReconnectGui"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999999
sg.Parent = pg

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 232, 0, 224)
f.Position = UDim2.new(0.5, -116, 0.2, 0)
f.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
f.BorderSizePixel = 0
f.Active = true
f.Parent = sg
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local top = Instance.new("TextLabel")
top.Size = UDim2.new(1, -30, 0, 28)
top.Position = UDim2.new(0, 8, 0, 0)
top.BackgroundTransparency = 1
top.Text = "@uze9r reconnect"
top.TextColor3 = Color3.new(1, 1, 1)
top.Font = Enum.Font.GothamBold
top.TextSize = 12
top.TextXAlignment = Enum.TextXAlignment.Left
top.Active = true
top.Parent = f

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 20, 0, 20)
x.Position = UDim2.new(1, -24, 0, 4)
x.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
x.Text = "×"
x.TextColor3 = Color3.new(1, 1, 1)
x.Font = Enum.Font.GothamBold
x.Parent = f
Instance.new("UICorner", x).CornerRadius = UDim.new(0, 5)
x.MouseButton1Click:Connect(function() sg:Destroy() end)

local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -16, 0, 18)
st.Position = UDim2.new(0, 8, 0, 28)
st.BackgroundTransparency = 1
st.Text = "Status: Active"
st.TextColor3 = Color3.fromRGB(140, 220, 160)
st.Font = Enum.Font.Gotham
st.TextSize = 11
st.TextXAlignment = Enum.TextXAlignment.Left
st.Parent = f

local function mk(y, xPos, w, txt, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, w, 0, 26)
	b.Position = UDim2.new(0, xPos, 0, y)
	b.BackgroundColor3 = col
	b.Text = txt
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 11
	b.Parent = f
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local b1 = mk(49, 8, 216, "Auto-Reconnect: ON", Color3.fromRGB(45, 140, 80))
local b2 = mk(79, 8, 216, "Server: Same", Color3.fromRGB(40, 45, 58))
local b3 = mk(109, 8, 216, "Test Error", Color3.fromRGB(175, 105, 35))
local tToggle = mk(139, 8, 118, "Timer: OFF", Color3.fromRGB(55, 60, 75))
local tMinus = mk(139, 130, 26, "-", Color3.fromRGB(40, 45, 58))

local tVal = Instance.new("TextLabel")
tVal.Size = UDim2.new(0, 40, 0, 26)
tVal.Position = UDim2.new(0, 160, 0, 139)
tVal.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
tVal.Text = "3h"
tVal.TextColor3 = Color3.new(1, 1, 1)
tVal.Font = Enum.Font.GothamBold
tVal.TextSize = 11
tVal.Parent = f
Instance.new("UICorner", tVal).CornerRadius = UDim.new(0, 6)

local tPlus = mk(139, 204, 26, "+", Color3.fromRGB(40, 45, 58))

local tInfo = Instance.new("TextLabel")
tInfo.Size = UDim2.new(1, -16, 0, 16)
tInfo.Position = UDim2.new(0, 8, 0, 169)
tInfo.BackgroundTransparency = 1
tInfo.Text = "Timer: OFF (3h)"
tInfo.TextColor3 = Color3.fromRGB(175, 182, 198)
tInfo.Font = Enum.Font.Gotham
tInfo.TextSize = 10
tInfo.TextXAlignment = Enum.TextXAlignment.Left
tInfo.Parent = f

local function refresh()
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
end

local function rejoin(force)
	if (not force and not autoReconnect) or isRejoining then return end
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

b1.MouseButton1Click:Connect(function() autoReconnect = not autoReconnect refresh() end)
b2.MouseButton1Click:Connect(function() sameServer = not sameServer refresh() end)
b3.MouseButton1Click:Connect(function()
	st.Text = "Test: Error 277!"
	task.wait(0.7)
	rejoin(true)
end)
tToggle.MouseButton1Click:Connect(function() timerEnabled = not timerEnabled elapsedSeconds = 0 refresh() end)
tMinus.MouseButton1Click:Connect(function() if timerHours > 1 then timerHours -= 1 elapsedSeconds = 0 refresh() end end)
tPlus.MouseButton1Click:Connect(function() if timerHours < 24 then timerHours += 1 elapsedSeconds = 0 refresh() end end)

local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = f.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStart
		f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

task.spawn(function()
	while task.wait(1) do
		if autoReconnect and not isRejoining then
			pcall(function()
				local o = CoreGui:FindFirstChild("RobloxPromptGui") and CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
				if o and o:FindFirstChild("ErrorPrompt") then rejoin(false) end
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
