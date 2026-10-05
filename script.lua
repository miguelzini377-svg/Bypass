
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local activated = false
local keybind = Enum.KeyCode.V
local waitingForKey = false
local power = 23500
local lagAmount = 0.12
local lagConn = nil

local function applyPower(val)
	power = math.clamp(val, 10000, 500000)
	local t = (power - 10000) / 490000
	lagAmount = t * 0.2
end

applyPower(power)

local enableBtn

local function startLag()
	if lagConn then lagConn:Disconnect() end

	lagConn = RunService.RenderStepped:Connect(function()
		if not activated then return end
		if lagAmount > 0 then
			local t = tick()
			while tick() - t < lagAmount do end
		end
	end)
end

local function stopLag()
	activated = false
	if lagConn then lagConn:Disconnect(); lagConn = nil end
end
local autoCarryEnabled = false
local autoCarryConn = nil
local _lastCarryState = false

local function isCarryName(name)
	local n = tostring(name or ""):lower()
	return n:find("brainrot") or n:find("animal") or n:find("carry")
		or n:find("grab") or n:find("steal") or n:find("hold")
end
local function isIgnoredCarryTool(name)
	local n = tostring(name or ""):lower()
	return n:find("bat") or n:find("slap") or n:find("medusa")
		or n:find("head") or n:find("stone")
end

local function isCarryingBrainrot(char)
	if not char then return false end

	for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do
		local v = char:FindFirstChild(name, true)
		if v then
			if v:IsA("BoolValue") and v.Value then return true end
			if v:IsA("ObjectValue") and v.Value then return true end
			if v:IsA("StringValue") and v.Value ~= "" then return true end
		end
	end

	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
			if child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
				return true
			end
			if isCarryName(child.Name) then return true end
		elseif child:IsA("Tool") and not isIgnoredCarryTool(child.Name) then
			return true
		end
	end
	return false
end

local function bypassOn()
	if not activated then
		activated = true
		enableBtn.Text = "Disable"
		enableBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
		startLag()
	end
end


local function bypassOff()
	if activated then
		stopLag()
		enableBtn.Text = "Enable"
		enableBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	end
end

local function startAutoCarry()
	if autoCarryConn then autoCarryConn:Disconnect(); autoCarryConn = nil end
	autoCarryEnabled = true
	_lastCarryState = false
	autoCarryConn = RunService.RenderStepped:Connect(function()
		if not autoCarryEnabled then return end
		local char = lp.Character
		if not char then
			_lastCarryState = false
			return
		end
		local carrying = isCarryingBrainrot(char)
		if carrying and not _lastCarryState then
			-- Just picked up a brainrot -> turn bypass ON
			bypassOn()
		elseif not carrying and _lastCarryState then
			-- Dropped the brainrot -> turn bypass OFF
			bypassOff()
		end
		_lastCarryState = carrying
	end)
	print("[Nxtzy] Auto Bypass on Carry STARTED")
end

local function stopAutoCarry()
	autoCarryEnabled = false
	if autoCarryConn then autoCarryConn:Disconnect(); autoCarryConn = nil end
	_lastCarryState = false
	print("[Nxtzy] Auto Bypass on Carry STOPPED")
end

if CoreGui:FindFirstChild("NxtzySpeedBypass") then
	CoreGui.NxtzySpeedBypass:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "NxtzySpeedBypass"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 180, 0, 250)
main.Position = UDim2.new(0.5, -90, 0.5, -125)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Nxtzy Speed Bypass"
title.TextColor3 = Color3.fromRGB(200, 200, 205)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = main

enableBtn = Instance.new("TextButton")
enableBtn.Size = UDim2.new(0.9, 0, 0, 34)
enableBtn.Position = UDim2.new(0.05, 0, 0, 42)
enableBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
enableBtn.Text = "Enable"
enableBtn.TextColor3 = Color3.new(1, 1, 1)
enableBtn.Font = Enum.Font.GothamBold
enableBtn.TextSize = 12
enableBtn.BorderSizePixel = 0
enableBtn.AutoButtonColor = false
enableBtn.Parent = main

Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 8)

local function createRow(yPos, labelText)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(0.9, 0, 0, 30)
	row.Position = UDim2.new(0.05, 0, 0, yPos)
	row.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	row.BorderSizePixel = 0
	row.Parent = main
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.Parent = label

	return row, label
end

local versionRow, versionLabel = createRow(81, "Version")
local versionBtn = Instance.new("TextButton")
versionBtn.Size = UDim2.new(0.4, 0, 0.7, 0)
versionBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
versionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
versionBtn.Text = "V1"
versionBtn.TextColor3 = Color3.new(1, 1, 1)
versionBtn.Font = Enum.Font.GothamBold
versionBtn.TextSize = 11
versionBtn.BorderSizePixel = 0
versionBtn.AutoButtonColor = false
versionBtn.Parent = versionRow
Instance.new("UICorner", versionBtn).CornerRadius = UDim.new(0, 6)

local powerRow, powerLabel = createRow(115, "Power")
local powerBox = Instance.new("TextBox")
powerBox.Size = UDim2.new(0.4, 0, 0.7, 0)
powerBox.Position = UDim2.new(0.55, 0, 0.15, 0)
powerBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
powerBox.Text = tostring(power)
powerBox.TextColor3 = Color3.new(1, 1, 1)
powerBox.Font = Enum.Font.GothamBold
powerBox.TextSize = 12
powerBox.BorderSizePixel = 0
powerBox.ClearTextOnFocus = false
powerBox.Parent = powerRow
Instance.new("UICorner", powerBox).CornerRadius = UDim.new(0, 6)

powerBox.FocusLost:Connect(function()
	local val = tonumber(powerBox.Text)
	if val then
		applyPower(val)
		powerBox.Text = tostring(power)
	else
		powerBox.Text = tostring(power)
	end
end)


local kbRow, kbLabel = createRow(149, "Keybind")
local kbBtn = Instance.new("TextButton")
kbBtn.Size = UDim2.new(0.4, 0, 0.7, 0)
kbBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
kbBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
kbBtn.Text = keybind.Name
kbBtn.TextColor3 = Color3.new(1, 1, 1)
kbBtn.Font = Enum.Font.GothamBold
kbBtn.TextSize = 12
kbBtn.BorderSizePixel = 0
kbBtn.AutoButtonColor = false
kbBtn.Parent = kbRow
Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 6)

kbBtn.MouseButton1Click:Connect(function()
	waitingForKey = true
	kbBtn.Text = "..."
	kbBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
end)

local function toggle()
	if not activated then
		activated = true
		enableBtn.Text = "Disable"
		enableBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
		startLag()
	else
		stopLag()
		enableBtn.Text = "Enable"
		enableBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	end
end

enableBtn.MouseButton1Click:Connect(toggle)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if waitingForKey then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keybind = input.KeyCode
			kbBtn.Text = keybind.Name
			kbBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			waitingForKey = false
		end
		return
	end
	if input.KeyCode == keybind then
		toggle()
	end
end)

local acHeader = Instance.new("TextLabel")
acHeader.Size = UDim2.new(0.9, 0, 0, 18)
acHeader.Position = UDim2.new(0.05, 0, 0, 183)
acHeader.BackgroundTransparency = 1
acHeader.Text = "Auto Bypass on Carry"
acHeader.TextColor3 = Color3.fromRGB(200, 200, 205)
acHeader.Font = Enum.Font.GothamBold
acHeader.TextSize = 11
acHeader.TextXAlignment = Enum.TextXAlignment.Left
acHeader.Parent = main

local acHint = Instance.new("TextLabel")
acHint.Size = UDim2.new(0.9, 0, 0, 14)
acHint.Position = UDim2.new(0.05, 0, 0, 200)
acHint.BackgroundTransparency = 1
acHint.Text = "Bypass turns ON while carrying a brainrot"
acHint.TextColor3 = Color3.fromRGB(140, 140, 150)
acHint.Font = Enum.Font.Gotham
acHint.TextSize = 9
acHint.TextXAlignment = Enum.TextXAlignment.Left
acHint.Parent = main

local acRow, acLabel = createRow(218, "Auto Bypass")
local acBtn = Instance.new("TextButton")
acBtn.Size = UDim2.new(0.4, 0, 0.7, 0)
acBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
acBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
acBtn.Text = "OFF"
acBtn.TextColor3 = Color3.new(1, 1, 1)
acBtn.Font = Enum.Font.GothamBold
acBtn.TextSize = 11
acBtn.BorderSizePixel = 0
acBtn.AutoButtonColor = false
acBtn.Parent = acRow
Instance.new("UICorner", acBtn).CornerRadius = UDim.new(0, 6)

acBtn.MouseButton1Click:Connect(function()
	if autoCarryEnabled then
		stopAutoCarry()
		acBtn.Text = "OFF"
		acBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	else
		startAutoCarry()
		acBtn.Text = "ON"
		acBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	end
end)

lp.CharacterAdded:Connect(function()
	task.wait(1)
	if activated then
		stopLag()
		activated = true
		startLag()
	end

	_lastCarryState = false
end)
