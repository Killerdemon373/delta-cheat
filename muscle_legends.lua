-- Muscle Legends Auto Farm - uses shared Speed_Library
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/muscle_legends.lua"))()

print("=== Muscle Legends Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Settings = {
    AutoPunch = true,
    AutoWeight = true,
    AutoRebirth = false,
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = true
}

local Speed_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Library.lua"))()
local Window = Speed_Library:CreateWindow({
    Title = "Muscle Legends",
    Description = "Auto Farm",
    SizeUi = UDim2.fromOffset(420, 320)
})

Window:AddToggle("Auto Punch", true, function(v) Settings.AutoPunch = v end)
Window:AddToggle("Auto Weight", true, function(v) Settings.AutoWeight = v end)
Window:AddToggle("Auto Rebirth", false, function(v) Settings.AutoRebirth = v end)
Window:AddToggle("Speed", false, function(v) Settings.Speed = v end)
Window:AddToggle("Infinite Jump", true, function(v) Settings.InfiniteJump = v end)
Window:AddLabel("Anti AFK Active")

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
    if tool and tool.Parent ~= Player.Character then tool.Parent = Player.Character end
end

task.spawn(function()
    while true do
        task.wait(0.12)
        if not Player.Character then continue end
        if Settings.AutoPunch then
            local punch = getTool("Punch") or getTool("Fist") or getTool("Hand")
            if punch then equip(punch) pcall(function() punch:Activate() end) end
        end
        if Settings.AutoWeight then
            local weight = getTool("Weight") or getTool("Dumbbell") or getTool("Barbell")
            if weight then equip(weight) pcall(function() weight:Activate() end) end
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

print("=== Muscle Legends Loaded (Speed_Library UI) ===")
