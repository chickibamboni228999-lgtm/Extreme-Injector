local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

shared.toggles = shared.toggles or {}
shared.extremeMenu = {}
shared.connections = shared.connections or {}
shared.walkSpeed = shared.walkSpeed or 16
shared.jumpPower = shared.jumpPower or 50

----------------------------------------------------------------
-- Notifications
----------------------------------------------------------------
local function notify(msg)
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 40)
    frame.Position = UDim2.new(1, -320, 1, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = msg
    label.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, -320, 1, -110)}):Play()
    task.delay(2, function()
        gui:Destroy()
    end)
end

local function toggle(name, state, callback)
    shared.toggles[name] = state
    if callback then
        callback(state)
    end
    notify(name .. " " .. (state and "ON" or "OFF"))
end

----------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------
do
    -- Fly
    local flyConn, bv, bg
    local function fly(state)
        if state then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            bg = Instance.new("BodyGyro", hrp)
            bv = Instance.new("BodyVelocity", hrp)
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            flyConn = RS.RenderStepped:Connect(function()
                local dir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                bv.Velocity = dir * 60
                bg.CFrame = workspace.CurrentCamera.CFrame
            end)
        else
            if flyConn then flyConn:Disconnect() end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
    shared.extremeMenu.fly = function()
        toggle("Fly", not shared.toggles.Fly, fly)
    end

    -- Noclip
    local noclipConn
    local function noclip(state)
        if state then
            noclipConn = RS.Stepped:Connect(function()
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
    shared.extremeMenu.noclip = function()
        toggle("Noclip", not shared.toggles.Noclip, noclip)
    end

    -- Infinite Jump
    local jumpConn
    local function infJump(state)
        if state then
            jumpConn = UIS.JumpRequest:Connect(function()
                player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        else
            if jumpConn then jumpConn:Disconnect() end
        end
    end
    shared.extremeMenu.infJump = function()
        toggle("Infinite Jump", not shared.toggles.InfJump, infJump)
    end

    -- WalkSpeed
    shared.extremeMenu.setSpeed = function(value)
        shared.walkSpeed = value
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = value end
        notify("WalkSpeed = " .. value)
    end

    -- JumpPower
    shared.extremeMenu.setJump = function(value)
        shared.jumpPower = value
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = value end
        notify("JumpPower = " .. value)
    end
end

----------------------------------------------------------------
-- MM2 Functions
----------------------------------------------------------------
local function getMurderer()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            if plr.Backpack:FindFirstChild("Knife") or (plr.Character and plr.Character:FindFirstChild("Knife")) then
                return plr
            end
        end
    end
end
local function getSheriff()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            if plr.Backpack:FindFirstChild("Gun") or (plr.Character and plr.Character:FindFirstChild("Gun")) then
                return plr
            end
        end
    end
end
local function getGunDrop()
    for _,v in pairs(workspace:GetChildren()) do
        if v.Name == "GunDrop" then
            return v
        end
    end
end

-- Auto Grab Gun
do
    local conn
    local function autoGrab(state)
        if state then
            conn = RS.Stepped:Connect(function()
                local g = getGunDrop()
                if g and player.Character then
                    player.Character:MoveTo(g.Position)
                end
            end)
        else
            if conn then conn:Disconnect() end
        end
    end
    shared.extremeMenu.autoGrab = function()
        toggle("Auto Grab Gun", not shared.toggles.AutoGrab, autoGrab)
    end
end

-- Auto Shoot Murderer
do
    local conn
    local function autoShoot(state)
        if state then
            conn = RS.Heartbeat:Connect(function()
                local s = player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun"))
                local m = getMurderer()
                if s and m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
                    local tool = player.Character and player.Character:FindFirstChild("Gun")
                    if tool and tool:FindFirstChild("Shoot") then
                        tool.Shoot:FireServer(m.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            if conn then conn:Disconnect() end
        end
    end
    shared.extremeMenu.autoShoot = function()
        toggle("Auto Shoot Murderer", not shared.toggles.AutoShoot, autoShoot)
    end
end

-- Kill All (if murderer)
shared.extremeMenu.killAll = function()
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
        notify("Kill All Executed")
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                player.Character:MoveTo(plr.Character.HumanoidRootPart.Position)
                task.wait(0.2)
            end
        end
    else
        notify("You are not Murderer!")
    end
end

-- Knife Reach
shared.extremeMenu.knifeReach = function()
    local knife = player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife"))
    if knife and knife:IsA("Tool") then
        local handle = knife:FindFirstChild("Handle")
        if handle then
            handle.Size = Vector3.new(50,50,50)
            handle.Massless = true
            notify("Knife Reach Activated")
        end
    end
end

----------------------------------------------------------------
-- ESP Functions
----------------------------------------------------------------
local espFolder = Instance.new("Folder", player.PlayerGui)
espFolder.Name = "ExtremeESP"

local function clearESP()
    espFolder:ClearAllChildren()
end

local function createESP(plr, color)
    if plr == player then return end
    if not plr.Character then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local billboard = Instance.new("BillboardGui", espFolder)
    billboard.Name = plr.Name
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = color
end

local function espUpdate()
    clearESP()
    for _,plr in pairs(Players:GetPlayers()) do
        local color = Color3.fromRGB(200,200,200)
        if plr ~= player then
            if plr.Backpack:FindFirstChild("Knife") or (plr.Character and plr.Character:FindFirstChild("Knife")) then
                color = Color3.fromRGB(255,0,0)
            elseif plr.Backpack:FindFirstChild("Gun") or (plr.Character and plr.Character:FindFirstChild("Gun")) then
                color = Color3.fromRGB(0,0,255)
            else
                local g = getGunDrop()
                if g then color = Color3.fromRGB(0,255,0) end
            end
            createESP(plr, color)
        end
    end
end

do
    local conn
    local function esp(state)
        if state then
            conn = RS.Heartbeat:Connect(espUpdate)
        else
            if conn then conn:Disconnect() end
            clearESP()
        end
    end
    shared.extremeMenu.esp = function()
        toggle("ESP", not shared.toggles.ESP, esp)
    end
end

----------------------------------------------------------------
-- TP
----------------------------------------------------------------
shared.extremeMenu.tpLobby = function()
    local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("Spawn")
    if lobby and player.Character then
        player.Character:MoveTo(lobby.Position)
        notify("TP to Lobby")
    end
end
shared.extremeMenu.tpMurderer = function()
    local m = getMurderer()
    if m and m.Character then
        player.Character:MoveTo(m.Character.HumanoidRootPart.Position + Vector3.new(0,3,0))
        notify("TP to Murderer")
    end
end
shared.extremeMenu.tpSheriff = function()
    local s = getSheriff()
    if s and s.Character then
        player.Character:MoveTo(s.Character.HumanoidRootPart.Position + Vector3.new(0,3,0))
        notify("TP to Sheriff")
    end
end
shared.extremeMenu.tpGun = function()
    local g = getGunDrop()
    if g then
        player.Character:MoveTo(g.Position + Vector3.new(0,3,0))
        notify("TP to Gun")
    end
end

----------------------------------------------------------------
-- Fling
----------------------------------------------------------------
shared.extremeMenu.flingNearest = function()
    local nearest, dist = nil, math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                nearest = plr
            end
        end
    end
    if nearest then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            notify("Flinging " .. nearest.Name)
            for i=1,40 do
                hrp.AssemblyLinearVelocity = (nearest.Character.HumanoidRootPart.Position - hrp.Position).Unit * 200
                task.wait(0.05)
            end
        end
    end
end

----------------------------------------------------------------
-- Auto-Reenable after respawn
----------------------------------------------------------------
player.CharacterAdded:Connect(function()
    task.wait(2)
    for name, state in pairs(shared.toggles) do
        if state and shared.extremeMenu[name:lower()] then
            shared.extremeMenu[name:lower()]()
        end
    end
end)

----------------------------------------------------------------
return shared.extremeMenu
