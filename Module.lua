local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player.PlayerGui:FindFirstChild("ExtremeMenu") then
	player.PlayerGui.ExtremeMenu:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExtremeMenu"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 500)
frame.Position = UDim2.new(0.5, -300, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🌌 Extreme Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 6
contentFrame.CanvasSize = UDim2.new(0,0,5,0)
contentFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = contentFrame
layout.Padding = UDim.new(0,6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top

local function notify(txt)
	local n = Instance.new("TextLabel")
	n.Size = UDim2.new(0, 250, 0, 40)
	n.Position = UDim2.new(1,-260,1,-50)
	n.BackgroundColor3 = Color3.fromRGB(50,50,50)
	n.Text = txt
	n.TextColor3 = Color3.new(1,1,1)
	n.Font = Enum.Font.GothamBold
	n.TextSize = 16
	n.Parent = screenGui
	game:GetService("TweenService"):Create(n, TweenInfo.new(0.4), {BackgroundTransparency = 0.1, TextTransparency = 0}):Play()
	task.delay(2,function()
		game:GetService("TweenService"):Create(n, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		task.wait(0.5)
		n:Destroy()
	end)
end

local function createButton(text,callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 540, 0, 35)
	b.BackgroundColor3 = Color3.fromRGB(60,60,60)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.Text = text.." [OFF]"
	b.BorderSizePixel = 0
	b.Parent = contentFrame
	local state = false
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text.." ["..(state and "ON" or "OFF").."]"
		callback(state)
	end)
	return b
end

local function createSlider(text,min,max,default,callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,540,0,50)
	frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
	frame.Parent = contentFrame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,0,20)
	label.BackgroundTransparency = 1
	label.Text = text..": "..default
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = frame
	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(1,0,0,20)
	slider.Position = UDim2.new(0,0,0,25)
	slider.BackgroundColor3 = Color3.fromRGB(80,80,80)
	slider.Text = ""
	slider.Parent = frame
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0,10,1,0)
	knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
	knob.Parent = slider
	local value = default
	local dragging = false
	slider.MouseButton1Down:Connect(function() dragging = true end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
	game:GetService("RunService").RenderStepped:Connect(function()
		if dragging then
			local pos = math.clamp((UIS:GetMouseLocation().X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
			value = math.floor(min + (max-min)*pos)
			knob.Position = UDim2.new(pos, -5,0,0)
			label.Text = text..": "..value
			callback(value)
		end
	end)
	knob.Position = UDim2.new((default-min)/(max-min),-5,0,0)
end

createButton("✈️ Fly", function(state) notify("Fly "..(state and "ON" or "OFF")) end)
createButton("👻 Noclip", function(state) notify("Noclip "..(state and "ON" or "OFF")) end)
createButton("🌀 Infinite Jump", function(state) notify("Infinite Jump "..(state and "ON" or "OFF")) end)
createButton("🔫 Auto Grab Gun", function(state) notify("Auto Grab Gun "..(state and "ON" or "OFF")) end)
createButton("⚔️ Kill Aura", function(state) notify("Kill Aura "..(state and "ON" or "OFF")) end)
createButton("👹 ESP Murderer", function(state) notify("ESP Murderer "..(state and "ON" or "OFF")) end)
createButton("👮 ESP Sheriff", function(state) notify("ESP Sheriff "..(state and "ON" or "OFF")) end)
createButton("🔫 ESP Gun", function(state) notify("ESP Gun "..(state and "ON" or "OFF")) end)
createButton("🚪 TP to Lobby", function(state) notify("Teleport Lobby") end)
createButton("🗺️ TP to Map", function(state) notify("Teleport Map") end)
createButton("💥 Fling Nearest", function(state) notify("Fling Nearest "..(state and "ON" or "OFF")) end)
createButton("❌ Destroy Menu", function() screenGui:Destroy() end)

createSlider("WalkSpeed",16,200,16,function(v) notify("WalkSpeed: "..v) end)
createSlider("JumpPower",50,200,50,function(v) notify("JumpPower: "..v) end)

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(0,300,0,30)
hint.Position = UDim2.new(1,-310,1,-40)
hint.BackgroundTransparency = 1
hint.Text = "Press B to open Extreme Menu"
hint.TextColor3 = Color3.fromRGB(255,255,255)
hint.Font = Enum.Font.GothamBold
hint.TextSize = 16
hint.Parent = player.PlayerGui

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.B then
		screenGui.Enabled = not screenGui.Enabled
		hint.Visible = not screenGui.Enabled
	end
end)

print("✅ Extreme Menu Loaded")
