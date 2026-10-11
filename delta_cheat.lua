-- Delta Cheat v2 | Silent Aim + Aimbot + ESP + Speed + Infinite Jump + Simple UI
print("=== LOADING CHEAT v2 ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Settings = {
    SilentAim = true,
    Aimbot = true,
    ESP = true,
    TeamCheck = true,
    FOV = 150,
    Smoothness = 0.15,
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = true,
    ShowFOV = true
}

local CurrentTarget = nil
local FOVCircle = nil
local ESPObjects = {}

-- ===================== DRAWING =====================
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(0, 255, 140)
    FOVCircle.Visible = true
    FOVCircle.Transparency = 0.4
end)

local function getClosest()
    local closest, shortest = nil, Settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                if not (Settings.TeamCheck and plr.Team and Player.Team and plr.Team == Player.Team) then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = head
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ===================== SILENT AIM (stronger) =====================
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if Settings.SilentAim and CurrentTarget and not checkcaller() then
            if typeof(self) == "Instance" and self:IsA("Mouse") then
                if key == "Hit" or key == "hit" then
                    return CurrentTarget.CFrame
                elseif key == "Target" or key == "target" then
                    return CurrentTarget
                end
            end
        end
        return oldIndex(self, key)
    end))
end)

-- also try namecall for some games
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Settings.SilentAim and CurrentTarget and not checkcaller() then
            if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
                -- some games use these, leave for now
            end
        end
        return oldNamecall(self, ...)
    end))
end)

print("silent aim ready")

-- ===================== MAIN LOOP =====================
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV
    end

    CurrentTarget = getClosest()

    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and CurrentTarget then
        local screen = Camera:WorldToViewportPoint(CurrentTarget.Position)
        local move = (Vector2.new(screen.X, screen.Y) - Vector2.new(Mouse.X, Mouse.Y)) * Settings.Smoothness
        pcall(function() mousemoverel(move.X, move.Y) end)
    end
end)

-- ===================== ESP =====================
local function createESP(plr)
    if ESPObjects[plr] then return end
    local ok, box = pcall(Drawing.new, "Square")
    if not ok then return end
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 50, 50)
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false

    ESPObjects[plr] = {box = box, name = name}
end

local function removeESP(plr)
    if ESPObjects[plr] then
        pcall(function() ESPObjects[plr].box:Remove() end)
        pcall(function() ESPObjects[plr].name:Remove() end)
        ESPObjects[plr] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for plr, drawings in pairs(ESPObjects) do
        local char = plr.Character
        if Settings.ESP and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
            if Settings.TeamCheck and plr.Team and Player.Team and plr.Team == Player.Team then
                drawings.box.Visible = false
                drawings.name.Visible = false
            else
                local hrp = char.HumanoidRootPart
                local top, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                if onScreen then
                    local height = math.abs(top.Y - bottom.Y)
                    local width = height * 0.55
                    drawings.box.Size = Vector2.new(width, height)
                    drawings.box.Position = Vector2.new(top.X - width/2, top.Y)
                    drawings.box.Visible = true
                    drawings.name.Text = plr.Name
                    drawings.name.Position = Vector2.new(top.X, top.Y - 15)
                    drawings.name.Visible = true
                else
                    drawings.box.Visible = false
                    drawings.name.Visible = false
                end
            end
        else
            drawings.box.Visible = false
            drawings.name.Visible = false
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then
        createESP(p)
        p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end)
    end
end
Players.PlayerAdded:Connect(function(p)
    createESP(p)
    p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end)
end)
Players.PlayerRemoving:Connect(removeESP)

-- ===================== MOVEMENT =====================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.V then
        Settings.Speed = not Settings.Speed
        print("Speed:", Settings.Speed and "ON" or "OFF")
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Speed and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.SpeedValue end
    end
end)

-- ===================== SIMPLE UI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCheatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 280)
Frame.Position = UDim2.new(0, 20, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "Delta Cheat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local function makeToggle(name, y, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
        callback(state)
    end)
end

makeToggle("Silent Aim", 45, true, function(v) Settings.SilentAim = v end)
makeToggle("Aimbot (RMB)", 82, true, function(v) Settings.Aimbot = v end)
makeToggle("ESP", 119, true, function(v) Settings.ESP = v end)
makeToggle("Team Check", 156, true, function(v) Settings.TeamCheck = v end)
makeToggle("Show FOV", 193, true, function(v) Settings.ShowFOV = v end)
makeToggle("Speed (V)", 230, false, function(v) Settings.Speed = v end)

print("=== CHEAT LOADED v2 ===")
print("UI should be visible on left side")
print("Silent Aim + Aimbot + ESP ON")
