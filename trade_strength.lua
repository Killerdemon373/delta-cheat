-- [Code: Badges] Trade Strength Auto Farm
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/trade_strength.lua"))()

print("=== Trade Strength Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local Settings = {
    AutoStrength = true,
    AutoSacrifice = false,
    AutoRoll = false,
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = true
}

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TradeStrengthUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 300)
Frame.Position = UDim2.new(0, 20, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(50, 50, 50)
stroke.Thickness = 1.5
stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Trade Strength"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 10)
tCorner.Parent = Title

local function makeToggle(text, y, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 34)
    btn.Position = UDim2.new(0, 12, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = default and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 130) or Color3.fromRGB(255, 80, 80)
        cb(state)
    end)
end

makeToggle("Auto Strength", 50, true, function(v) Settings.AutoStrength = v end)
makeToggle("Auto Sacrifice", 90, false, function(v) Settings.AutoSacrifice = v end)
makeToggle("Auto Roll", 130, false, function(v) Settings.AutoRoll = v end)
makeToggle("Speed", 170, false, function(v) Settings.Speed = v end)
makeToggle("Infinite Jump", 210, true, function(v) Settings.InfiniteJump = v end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 1, -30)
Status.BackgroundTransparency = 1
Status.Text = "Anti AFK: Active | Code: Badges"
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.Parent = Frame

-- Auto Strength (common remote path from existing scripts)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Settings.AutoStrength then
            pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("Remote")
                if remote then
                    local fromLocal = remote:FindFirstChild("FromLocalForServer")
                    if fromLocal then
                        local get = fromLocal:FindFirstChild("Get")
                        if get then
                            local st = get:FindFirstChild("st")
                            if st and st:IsA("RemoteEvent") then
                                st:FireServer()
                            end
                        end
                    end
                end
            end)
            -- fallback: search any strength-related remote
            pcall(function()
                for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                    if r:IsA("RemoteEvent") and (r.Name:lower() == "st" or r.Name:lower():find("strength") or r.Name:lower():find("train")) then
                        r:FireServer()
                    end
                end
            end)
        end
    end
end)

-- Auto Sacrifice
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoSacrifice then
            pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("Remote")
                if remote then
                    local fromLocal = remote:FindFirstChild("FromLocalForServer")
                    if fromLocal then
                        local get = fromLocal:FindFirstChild("Get")
                        if get then
                            local sac = get:FindFirstChild("sac1") or get:FindFirstChild("sac")
                            if sac and sac:IsA("RemoteEvent") then
                                sac:FireServer()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if Settings.Speed and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.SpeedValue end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

print("=== Trade Strength Loaded ===")
print("UI on left | Auto Strength ON")
print("Use code Badges in shop for starter boost")
