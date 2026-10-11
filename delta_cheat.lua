-- Delta Cheat | Silent Aim + Aimbot + ESP + Speed + Infinite Jump
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/delta_cheat.lua"))()

print("=== LOADING CHEAT ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Settings = {
    SilentAim = true,
    Aimbot = true,
    ESP = true,
    TeamCheck = true,
    FOV = 120,
    Smoothness = 0.18,
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = true,
    ShowFOV = true
}

local CurrentTarget = nil
local FOVCircle = nil
local ESPObjects = {}

-- Drawing
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(0, 255, 140)
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Transparency = 0.5
end)
print("drawing ready")

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

-- Silent Aim
pcall(function()
    local old
    old = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if Settings.SilentAim and CurrentTarget and not checkcaller() then
            if typeof(self) == "Instance" and self:IsA("Mouse") then
                if key == "Hit" then return CurrentTarget.CFrame
                elseif key == "Target" then return CurrentTarget end
            end
        end
        return old(self, key)
    end))
end)
print("silent aim hooked")

-- Main loop
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV and (Settings.Aimbot or Settings.SilentAim)
    end
    CurrentTarget = getClosest()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and CurrentTarget then
        local screen = Camera:WorldToViewportPoint(CurrentTarget.Position)
        local move = (Vector2.new(screen.X, screen.Y) - Vector2.new(Mouse.X, Mouse.Y)) * Settings.Smoothness
        pcall(function() mousemoverel(move.X, move.Y) end)
    end
end)

-- ESP
local function createESP(plr)
    if ESPObjects[plr] then return end
    local box = Drawing.new("Square")
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Speed toggle (V key)
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

print("=== CHEAT LOADED ===")
print("Silent Aim + Aimbot + ESP ON")
print("Hold Right Click = Aimbot")
print("V = Toggle Speed")
print("Infinite Jump always on")
