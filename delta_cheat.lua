-- Delta Cheat (Universal Aimbot/ESP) - uses shared Speed_Library
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/delta_cheat.lua"))()

print("=== Delta Cheat Loading ===")

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

local Speed_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Library.lua"))()
local Window = Speed_Library:CreateWindow({
    Title = "Delta Cheat",
    Description = "Aimbot + ESP",
    SizeUi = UDim2.fromOffset(420, 360)
})

Window:AddToggle("Silent Aim", true, function(v) Settings.SilentAim = v end)
Window:AddToggle("Aimbot (RMB)", true, function(v) Settings.Aimbot = v end)
Window:AddToggle("ESP", true, function(v) Settings.ESP = v end)
Window:AddToggle("Team Check", true, function(v) Settings.TeamCheck = v end)
Window:AddToggle("Show FOV", true, function(v) Settings.ShowFOV = v end)
Window:AddToggle("Speed", false, function(v) Settings.Speed = v end)
Window:AddToggle("Infinite Jump", true, function(v) Settings.InfiniteJump = v end)
Window:AddLabel("Hold RMB for Aimbot | V = Speed")

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
                        if dist < shortest then shortest = dist closest = head end
                    end
                end
            end
        end
    end
    return closest
end

pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if Settings.SilentAim and CurrentTarget and not checkcaller() then
            if typeof(self) == "Instance" and self:IsA("Mouse") then
                if key == "Hit" or key == "hit" then return CurrentTarget.CFrame
                elseif key == "Target" or key == "target" then return CurrentTarget end
            end
        end
        return oldIndex(self, key)
    end))
end)

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

local function createESP(plr)
    if ESPObjects[plr] then return end
    local ok, box = pcall(Drawing.new, "Square")
    if not ok then return end
    box.Thickness = 1 box.Filled = false box.Color = Color3.fromRGB(255, 50, 50) box.Visible = false
    local name = Drawing.new("Text")
    name.Size = 13 name.Center = true name.Outline = true name.Color = Color3.fromRGB(255, 255, 255) name.Visible = false
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
                drawings.box.Visible = false drawings.name.Visible = false
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
                    drawings.box.Visible = false drawings.name.Visible = false
                end
            end
        else
            drawings.box.Visible = false drawings.name.Visible = false
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= Player then createESP(p) p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end) end
end
Players.PlayerAdded:Connect(function(p) createESP(p) p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end) end)
Players.PlayerRemoving:Connect(removeESP)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.V then Settings.Speed = not Settings.Speed end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Speed and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.SpeedValue end
    end
end)

print("=== Delta Cheat Loaded (Speed_Library UI) ===")
