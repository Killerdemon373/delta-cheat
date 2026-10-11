-- Muscle Legends Auto Farm (Delta) v2
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/muscle_legends.lua"))()

print("=== Muscle Legends Farm Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- Anti AFK built-in
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

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MuscleFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 290)
Frame.Position = UDim2.new(0, 20, 0.35, 0)
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
Title.Text = "Muscle Legends"
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

makeToggle("Auto Punch", 50, true, function(v) Settings.AutoPunch = v end)
makeToggle("Auto Weight", 90, true, function(v) Settings.AutoWeight = v end)
makeToggle("Auto Rebirth", 130, false, function(v) Settings.AutoRebirth = v end)
makeToggle("Speed", 170, false, function(v) Settings.Speed = v end)
makeToggle("Infinite Jump", 210, true, function(v) Settings.InfiniteJump = v end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 1, -30)
Status.BackgroundTransparency = 1
Status.Text = "Anti AFK: Active"
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Frame

-- Tools
local function getTool(name)
    local char = Player.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find(name:lower()) then return t end
        end
    end
    local bp = Player:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find(name:lower()) then return t end
        end
    end
    return nil
end

local function equip(tool)
    if tool and tool.Parent ~= Player.Character then
        tool.Parent = Player.Character
    end
end

task.spawn(function()
    while true do
        task.wait(0.12)
        if not Player.Character then continue end

        if Settings.AutoPunch then
            local punch = getTool("Punch") or getTool("Fist") or getTool("Hand")
            if punch then
                equip(punch)
                pcall(function() punch:Activate() end)
            end
        end

        if Settings.AutoWeight then
            local weight = getTool("Weight") or getTool("Dumbbell") or getTool("Barbell")
            if weight then
                equip(weight)
                pcall(function() weight:Activate() end)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Settings.Speed and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Settings.SpeedValue end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
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
