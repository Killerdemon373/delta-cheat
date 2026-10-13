-- [Code: Badges] Trade Strength - uses shared Speed_Library
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/trade_strength.lua"))()

print("=== Trade Strength Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextChat = game:GetService("TextChatService")

local Settings = {
    AutoStrength = true,
    AutoSacrifice = false,
    AutoRoll = false,
    AutoMath = true,
    Speed = false,
    SpeedValue = 50,
    InfiniteJump = true
}

local answered = {}

-- Load shared UI
local Speed_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Library.lua"))()
local Window = Speed_Library:CreateWindow({
    Title = "Trade Strength",
    Description = "Auto Farm",
    SizeUi = UDim2.fromOffset(420, 360)
})

Window:AddToggle("Auto Strength", true, function(v) Settings.AutoStrength = v end)
Window:AddToggle("Auto Sacrifice", false, function(v) Settings.AutoSacrifice = v end)
Window:AddToggle("Auto Roll", false, function(v) Settings.AutoRoll = v end)
Window:AddToggle("Auto Math (Chat)", true, function(v) Settings.AutoMath = v end)
Window:AddToggle("Speed", false, function(v) Settings.Speed = v end)
Window:AddToggle("Infinite Jump", true, function(v) Settings.InfiniteJump = v end)
Window:AddLabel("Code: Badges | Anti AFK Active")

-- Auto Strength
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
                            if st and st:IsA("RemoteEvent") then st:FireServer() end
                        end
                    end
                end
            end)
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
                            if sac and sac:IsA("RemoteEvent") then sac:FireServer() end
                        end
                    end
                end
            end)
        end
    end
end)

-- Math
local function solveMath(expr)
    if not expr then return nil end
    expr = tostring(expr):gsub("%s+", ""):gsub("×", "*"):gsub("x", "*"):gsub("X", "*")
    local a, op, b = expr:match("^(-?%d+%.?%d*)([%+%-%*/])(-?%d+%.?%d*)$")
    if not a then return nil end
    local n1, n2 = tonumber(a), tonumber(b)
    if not n1 or not n2 then return nil end
    if op == "+" then return n1 + n2
    elseif op == "-" then return n1 - n2
    elseif op == "*" then return n1 * n2
    elseif op == "/" then if n2 == 0 then return nil end return n1 / n2 end
    return nil
end

local function sendChat(msg)
    pcall(function()
        local channels = TextChat:FindFirstChild("TextChannels")
        if channels then
            local general = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("General")
            if general then general:SendAsync(tostring(msg)) return end
        end
    end)
    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local say = chatEvents:FindFirstChild("SayMessageRequest")
            if say then say:FireServer(tostring(msg), "All") end
        end
    end)
end

pcall(function()
    local function onMessage(msg)
        if not Settings.AutoMath then return end
        local text = tostring(msg)
        if answered[text] then return end
        local expr = text:match("[Ww]hat%s+is%s+([%d%.%s%+%-%*/xX×]+)[%s%?]+")
        if not expr then expr = text:match("([%d%.]+%s*[%+%-%*/xX×]%s*[%d%.]+)") end
        if expr then
            local result = solveMath(expr)
            if result then
                answered[text] = true
                task.wait(0.4 + math.random() * 0.5)
                local answer = tostring(math.floor(result + 0.5))
                sendChat(answer)
                print("[AutoMath]", expr, "=", answer)
            end
        end
    end

    pcall(function()
        TextChat.MessageReceived:Connect(function(m) onMessage(m.Text) end)
    end)

    task.spawn(function()
        while true do
            task.wait(0.8)
            if not Settings.AutoMath then continue end
            pcall(function()
                local pg = Player:FindFirstChild("PlayerGui")
                if not pg then return end
                for _, gui in ipairs(pg:GetDescendants()) do
                    if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text then
                        local t = gui.Text
                        if t:find("[Ww]hat is") or t:find("%d%s*[%+%-%*/]%s*%d") then
                            onMessage(t)
                        end
                    end
                end
            end)
        end
    end)
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

print("=== Trade Strength Loaded (Speed_Library UI) ===")
