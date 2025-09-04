-- ModuleScript ExtremeModule
local ExtremeModule = {}
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local screenGui, notifyFrame
local flyEnabled, noclipEnabled, infJumpsEnabled = false, false, false
local flyBV, flyBG, noclipConnection, jumpConnection

-- Уведомления
local function notify(text)
	if not notifyFrame then
		notifyFrame = Instance.new("Frame")
		notifyFrame.Size = UDim2.new(0, 250, 0, 40)
		notifyFrame.Position = UDim2.new(1,-260,1,-50)
		notifyFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
		notifyFrame.Parent = player.PlayerGui
	end
	notifyFrame:ClearAllChildren()
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 16
	lbl.Parent = notifyFrame
	game:GetService("Debris"):AddItem(lbl,2)
end

-- Fly
function ExtremeModule.ToggleFly(state)
	if state then
		flyEnabled = true
		flyBG = Instance.new("BodyGyro")
		flyBG.P = 9e4
		flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
		flyBG.Parent = hrp
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
		flyBV.Parent = hrp
		task.spawn(function()
			while flyEnabled do
				local dir = Vector3.zero
				if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=workspace.CurrentCamera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=workspace.CurrentCamera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=workspace.CurrentCamera.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=workspace.CurrentCamera.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
				if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
				flyBG.CFrame = workspace.CurrentCamera.CFrame
				flyBV.Velocity = dir*60
				task.wait()
			end
		end)
		notify("Fly ON")
	else
		flyEnabled = false
		if flyBG then flyBG:Destroy() end
		if flyBV then flyBV:Destroy() end
		notify("Fly OFF")
	end
end

-- Noclip
function ExtremeModule.ToggleNoclip(state)
	if state then
		noclipEnabled = true
		noclipConnection = RS.Stepped:Connect(function()
			for _,part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end)
		notify("Noclip ON")
	else
		noclipEnabled = false
		if noclipConnection then noclipConnection:Disconnect() end
		notify("Noclip OFF")
	end
end

-- Infinite Jump
function ExtremeModule.ToggleInfiniteJump(state)
	if state then
		infJumpsEnabled = true
		jumpConnection = UIS.JumpRequest:Connect(function()
			if infJumpsEnabled then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
		notify("Infinite Jump ON")
	else
		infJumpsEnabled = false
		if jumpConnection then jumpConnection:Disconnect() end
		notify("Infinite Jump OFF")
	end
end

-- WalkSpeed / JumpPower
function ExtremeModule.SetWalkSpeed(v)
	humanoid.WalkSpeed = v
	notify("WalkSpeed "..v)
end

function ExtremeModule.SetJumpPower(v)
	humanoid.JumpPower = v
	notify("JumpPower "..v)
end

-- Teleports
function ExtremeModule.TeleportLobby()
	if workspace:FindFirstChild("LobbySpawn") then
		hrp.CFrame = workspace.LobbySpawn.CFrame + Vector3.new(0,3,0)
		notify("Teleported to Lobby")
	end
end

function ExtremeModule.TeleportMap()
	if workspace:FindFirstChild("MapSpawn") then
		hrp.CFrame = workspace.MapSpawn.CFrame + Vector3.new(0,3,0)
		notify("Teleported to Map")
	end
end

-- ESP
function ExtremeModule.AttachESP(target, role)
	if not target.Character or not target.Character:FindFirstChild("Head") then return end
	if target == player then return end
	if target.Character:FindFirstChild("ESP") then target.Character.ESP:Destroy() end
	local bill = Instance.new("BillboardGui")
	bill.Name = "ESP"
	bill.Size = UDim2.new(0,100,0,20)
	bill.AlwaysOnTop = true
	bill.Parent = target.Character.Head
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.Text = target.Name.." ("..role..")"
	if role=="Murderer" then txt.TextColor3 = Color3.fromRGB(255,0,0)
	elseif role=="Sheriff" then txt.TextColor3 = Color3.fromRGB(0,0,255)
	elseif role=="Lobby" then txt.TextColor3 = Color3.fromRGB(150,150,150)
	else txt.TextColor3 = Color3.fromRGB(0,255,0) end
	txt.Font = Enum.Font.GothamBold
	txt.TextSize = 14
	txt.Parent = bill
end

-- Fling
function ExtremeModule.FlingNearest()
	local nearest,dist = nil,math.huge
	for _,plr in pairs(Players:GetPlayers()) do
		if plr~=player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local d = (plr.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
			if d<dist then
				dist=d
				nearest=plr
			end
		end
	end
	if nearest then
		for i=1,20 do
			hrp.Velocity = (nearest.Character.HumanoidRootPart.Position-hrp.Position).Unit*200
			task.wait(0.1)
		end
		notify("Flinged "..nearest.Name)
	end
end

return ExtremeModule
