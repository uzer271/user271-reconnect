local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local PLACE_ID = 1537690962
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

local function hasFS()
	return type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"
end

local function loadConfig()
	if not hasFS() then
		return
	end

	local existsOk, exists = pcall(function()
		return isfile(CFG_FILE)
	end)
	if not existsOk or not exists then
		return
	end

	local readOk, raw = pcall(function()
		return readfile(CFG_FILE)
	end)
	if not readOk or type(raw) ~= "string" or raw == "" then
		return
	end

	local decodeOk, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not decodeOk or type(data) ~= "table" then
		return
	end

	if type(data.AutoReconnect) == "boolean" then
		Config.AutoReconnect = data.AutoReconnect
	end
	if type(data.SameServer) == "boolean" then
		Config.SameServer = data.SameServer
	end
	if type(data.TimerEnabled) == "boolean" then
		Config.TimerEnabled = data.TimerEnabled
	end
	if type(data.TimerHours) == "number" then
		Config.TimerHours = math.clamp(math.floor(data.TimerHours), 1, 24)
	end
	if type(data.PosXScale) == "number" then
		Config.PosXScale = data.PosXScale
	end
	if type(data.PosXOffset) == "number" then
		Config.PosXOffset = data.PosXOffset
	end
	if type(data.PosYScale) == "number" then
		Config.PosYScale = data.PosYScale
	end
	if type(data.PosYOffset) == "number" then
		Config.PosYOffset = data.PosYOffset
	end
end

local function saveConfig()
	if not hasFS() then
		return
	end
	pcall(function()
		writefile(CFG_FILE, HttpService:JSONEncode(Config))
	end)
end

loadConfig()

local isRejoining = false
local elapsedSeconds = 0

local function getLocalPlayer()
	local ok, lp = pcall(function()
		return Players.LocalPlayer
	end)
	if ok and lp then
		return lp
	end
	return nil
end

local function resolveGuiParent()
	local huiOk, hui = pcall(function()
		if type(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if huiOk and typeof(hui) == "Instance" then
		return hui
	end

	local cgOk, cg = pcall(function()
		return CoreGui
	end)
	if cgOk and typeof(cg) == "Instance" then
		local testOk = pcall(function()
			local probe = Instance.new("Folder")
			probe.Name = "Uze9rProbe"
			probe.Parent = cg
			probe:Destroy()
		end)
		if testOk then
			return cg
		end
	end

	local lp = getLocalPlayer()
	if lp then
		local pgOk, pg = pcall(function()
			return lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
		end)
		if pgOk and typeof(pg) == "Instance" then
			return pg
		end
	end

	return nil
end

local parentGui = resolveGuiParent()
if not parentGui then
	warn("[@uze9r reconnect] Failed to find a valid GUI parent")
	return
end

pcall(function()
	local old = parentGui:FindFirstChild("Uze9rReconnectGui")
	if old then
		old:Destroy()
	end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Uze9rReconnectGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	screenGui.DisplayOrder = 999999
end)
screenGui.Parent = parentGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 232, 0, 224)
mainFrame.Position = UDim2.new(Config.PosXScale, Config.PosXOffset, Config.PosYScale, Config.PosYOffset)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 33)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(115, 120, 132)
mainStroke.Thickness = 1.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -30, 0, 28)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "@uze9r reconnect"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Active = true
titleLabel.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.new(0, 8, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Active"
statusLabel.TextColor3 = Color3.fromRGB(140, 220, 160)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainFrame

local function makeBtn(name, yPos, xPos, width, height, text, bgColor)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, width, 0, height)
	btn.Position = UDim2.new(0, xPos, 0, yPos)
	btn.BackgroundColor3 = bgColor
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 11
	btn.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	return btn
end

local autoBtn = makeBtn("AutoBtn", 49, 8, 216, 26, "", Color3.fromRGB(45, 140, 80))
local serverBtn = makeBtn("ServerBtn", 79, 8, 216, 26, "", Color3.fromRGB(40, 45, 58))
local testErrBtn = makeBtn("TestErrBtn", 109, 8, 216, 26, "Test Error", Color3.fromRGB(175, 105, 35))

local timerToggleBtn = makeBtn("TimerToggleBtn", 139, 8, 118, 26, "", Color3.fromRGB(55, 60, 75))
local timerMinusBtn = makeBtn("TimerMinusBtn", 139, 130, 26, 26, "-", Color3.fromRGB(40, 45, 58))

local timerHoursLabel = Instance.new("TextLabel")
timerHoursLabel.Name = "TimerHours"
timerHoursLabel.Size = UDim2.new(0, 40, 0, 26)
timerHoursLabel.Position = UDim2.new(0, 160, 0, 139)
timerHoursLabel.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
timerHoursLabel.BorderSizePixel = 0
timerHoursLabel.Text = tostring(Config.TimerHours) .. "h"
timerHoursLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerHoursLabel.Font = Enum.Font.GothamBold
timerHoursLabel.TextSize = 11
timerHoursLabel.Parent = mainFrame

local hoursCorner = Instance.new("UICorner")
hoursCorner.CornerRadius = UDim.new(0, 6)
hoursCorner.Parent = timerHoursLabel

local timerPlusBtn = makeBtn("TimerPlusBtn", 139, 204, 26, 26, "+", Color3.fromRGB(40, 45, 58))

local timerInfoLabel = Instance.new("TextLabel")
timerInfoLabel.Name = "TimerInfo"
timerInfoLabel.Size = UDim2.new(1, -16, 0, 16)
timerInfoLabel.Position = UDim2.new(0, 8, 0, 169)
timerInfoLabel.BackgroundTransparency = 1
timerInfoLabel.Text = ""
timerInfoLabel.TextColor3 = Color3.fromRGB(175, 182, 198)
timerInfoLabel.Font = Enum.Font.Gotham
timerInfoLabel.TextSize = 10
timerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
timerInfoLabel.Parent = mainFrame

local function formatHMS(totalSec)
	local sec = math.max(0, math.floor(totalSec))
	local h = math.floor(sec / 3600)
	local m = math.floor((sec % 3600) / 60)
	local s = sec % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function updateTimerUI()
	timerHoursLabel.Text = tostring(Config.TimerHours) .. "h"
	if Config.TimerEnabled then
		timerToggleBtn.Text = "Timer: ON"
		timerToggleBtn.BackgroundColor3 = Color3.fromRGB(52, 115, 195)
		local remaining = math.max(0, Config.TimerHours * 3600 - elapsedSeconds)
		timerInfoLabel.Text = "Next rejoin in: " .. formatHMS(remaining)
	else
		timerToggleBtn.Text = "Timer: OFF"
		timerToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
		timerInfoLabel.Text = "Timer: OFF (" .. tostring(Config.TimerHours) .. "h)"
	end
end

local function updateMainUI()
	autoBtn.Text = Config.AutoReconnect and "Auto-Reconnect: ON" or "Auto-Reconnect: OFF"
	autoBtn.BackgroundColor3 = Config.AutoReconnect and Color3.fromRGB(45, 140, 80) or Color3.fromRGB(140, 55, 65)
	serverBtn.Text = Config.SameServer and "Server: Same" or "Server: Random"

	if not isRejoining then
		if Config.AutoReconnect then
			statusLabel.Text = "Status: Active"
			statusLabel.TextColor3 = Color3.fromRGB(140, 220, 160)
		else
			statusLabel.Text = "Status: Disabled"
			statusLabel.TextColor3 = Color3.fromRGB(235, 130, 135)
		end
	end

	updateTimerUI()
end

updateMainUI()

local function queueScriptOnTeleport()
	local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
	if type(qot) == "function" then
		pcall(function()
			qot('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
		end)
	end
end

local function startRejoin(force)
	if (not force and not Config.AutoReconnect) or isRejoining then
		return
	end
	isRejoining = true
	saveConfig()
	queueScriptOnTeleport()

	statusLabel.Text = "Status: Rejoining..."
	statusLabel.TextColor3 = Color3.fromRGB(255, 205, 90)

	task.spawn(function()
		while task.wait(2) do
			pcall(function()
				local lp = getLocalPlayer()
				if not lp then
					return
				end
				local jobId = game.JobId
				local playerCount = #Players:GetPlayers()
				if Config.SameServer and type(jobId) == "string" and jobId ~= "" and playerCount > 1 then
					TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, lp)
				else
					TeleportService:Teleport(PLACE_ID, lp)
				end
			end)
		end
	end)
end

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

autoBtn.MouseButton1Click:Connect(function()
	Config.AutoReconnect = not Config.AutoReconnect
	saveConfig()
	updateMainUI()
end)

serverBtn.MouseButton1Click:Connect(function()
	Config.SameServer = not Config.SameServer
	saveConfig()
	updateMainUI()
end)

testErrBtn.MouseButton1Click:Connect(function()
	statusLabel.Text = "ВАС ОБНУЛИЛИ ЗА НАТРО АТЛАС"
	statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	pcall(function()
		local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
		local overlay = promptGui and promptGui:FindFirstChild("promptOverlay")
		if overlay then
			local oldTest = overlay:FindFirstChild("Uze9rTestError")
			if oldTest then
				oldTest:Destroy()
			end

			local msg = Instance.new("TextLabel")
			msg.Name = "Uze9rTestError"
			msg.Size = UDim2.new(0, 340, 0, 90)
			msg.Position = UDim2.new(0.5, -170, 0.5, -45)
			msg.BackgroundColor3 = Color3.fromRGB(45, 48, 56)
			msg.BorderSizePixel = 0
			msg.Text = "ВАС ОБНУЛИЛИ ЗА НАТРО АТЛАС"
			msg.TextColor3 = Color3.fromRGB(255, 255, 255)
			msg.Font = Enum.Font.GothamBold
			msg.TextSize = 15
			msg.TextWrapped = true
			msg.Parent = overlay

			local msgCorner = Instance.new("UICorner")
			msgCorner.CornerRadius = UDim.new(0, 8)
			msgCorner.Parent = msg
		end
	end)
	task.wait(0.9)
	startRejoin(true)
end)

timerToggleBtn.MouseButton1Click:Connect(function()
	Config.TimerEnabled = not Config.TimerEnabled
	elapsedSeconds = 0
	saveConfig()
	updateTimerUI()
end)

timerMinusBtn.MouseButton1Click:Connect(function()
	if Config.TimerHours > 1 then
		Config.TimerHours -= 1
		elapsedSeconds = 0
		saveConfig()
		updateTimerUI()
	end
end)

timerPlusBtn.MouseButton1Click:Connect(function()
	if Config.TimerHours < 24 then
		Config.TimerHours += 1
		elapsedSeconds = 0
		saveConfig()
		updateTimerUI()
	end
end)

local isDragging = false
local dragStartPos = Vector3.zero
local frameStartPos = mainFrame.Position

titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStartPos = input.Position
		frameStartPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not isDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStartPos
		mainFrame.Position = UDim2.new(
			frameStartPos.X.Scale,
			frameStartPos.X.Offset + delta.X,
			frameStartPos.Y.Scale,
			frameStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not isDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
		Config.PosXScale = mainFrame.Position.X.Scale
		Config.PosXOffset = mainFrame.Position.X.Offset
		Config.PosYScale = mainFrame.Position.Y.Scale
		Config.PosYOffset = mainFrame.Position.Y.Offset
		saveConfig()
	end
end)

task.spawn(function()
	while task.wait(1) do
		if Config.AutoReconnect and not isRejoining then
			pcall(function()
				local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
				local overlay = promptGui and promptGui:FindFirstChild("promptOverlay")
				if overlay and overlay:FindFirstChild("ErrorPrompt") then
					startRejoin(false)
				end
			end)
		end

		if Config.TimerEnabled and not isRejoining then
			elapsedSeconds += 1
			local limitSeconds = Config.TimerHours * 3600
			if elapsedSeconds >= limitSeconds then
				elapsedSeconds = 0
				updateTimerUI()
				startRejoin(true)
			else
				updateTimerUI()
			end
		end
	end
end)
