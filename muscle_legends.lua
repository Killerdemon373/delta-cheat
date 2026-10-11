-- Muscle Legends Auto Farm (Delta)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/muscle_legends.lua"))()

print("=== Muscle Legends Farm Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local Settings = {
    AutoPunch = true,
    AutoWeight = true,
    AutoRebirth = false,
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = true
}

-- Simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MuscleFarmUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 260)
Frame.Position = UDim2.new(0, 20, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Title.Text = "Muscle Legends Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Frame

local tCorner = Instance.new("UICorner")
tCorner.CornerRadius = UDim.new(0, 8)
tCorner.Parent = Title

local function makeToggle(text, y, default, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 90, 90)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 90, 90)
        cb(state)
    end)
end

makeToggle("Auto Punch", 45, true, function(v) Settings.AutoPunch = v end)
makeToggle("Auto Weight", 82, true, function(v) Settings.AutoWeight = v end)
makeToggle("Auto Rebirth", 119, false, function(v) Settings.AutoRebirth = v end)
makeToggle("Speed", 156, false, function(v) Settings.Speed = v end)
makeToggle("Infinite Jump", 193, true, function(v) Settings.InfiniteJump = v end)

-- Tool helpers
local function getTool(name)
    local char = Player.Character
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find(name:lower()) then
            return t
        end
    end
    local backpack = Player:FindFirstChild("Backpack")
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find(name:lower()) then
                return t
            end
        end
    end
    return nil
end

local function equipTool(tool)
    if tool and tool.Parent ~= Player.Character then
        tool.Parent = Player.Character
    end
end

-- Auto Punch / Weight loop
task.spawn(function()
    while true do
        task.wait(0.15)
        if not Player.Character then continue end

        if Settings.AutoPunch then
            local punch = getTool("Punch") or getTool("Fist") or getTool("Hand")
            if punch then
                equipTool(punch)
                pcall(function() punch:Activate() end)
            end
        end

        if Settings.AutoWeight then
            local weight = getTool("Weight") or getTool("Dumbbell") or getTool("Barbell")
            if weight then
                equipTool(weight)
                pcall(function() weight:Activate() end)
            end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if Settings.Speed and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Settings.SpeedValue
        end
    end
end)

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Settings.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Try common remotes for rebirth / farm (safe pcall)
task.spawn(function()
    while true do
        task.wait(2)
        if Settings.AutoRebirth then
            pcall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("RemoteEvents")
                if remotes then
                    for _, r in ipairs(remotes:GetDescendants()) do
                        if r:IsA("RemoteEvent") and (r.Name:lower():find("rebirth") or r.Name:lower():find("reborn")) then
                            r:FireServer()
                        end
                    end
                end
            end)
        end
    end
end)

print("=== Muscle Legends Farm Loaded ===")
print("UI on left side")
print("Auto Punch + Auto Weight ON")
