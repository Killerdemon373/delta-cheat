-- [Code: Badges] Trade Strength Auto Farm + Auto Math (Chat)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/trade_strength.lua"))()

print("=== Trade Strength Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TextChat = game:GetService("TextChatService")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

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
Frame.Size = UDim2.new(0, 240, 0, 340)
Frame.Position = UDim2.new(0, 20, 0.25, 0)
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
makeToggle("Auto Math", 170, true, function(v) Settings.AutoMath = v end)
makeToggle("Speed", 210, false, function(v) Settings.Speed = v end)
makeToggle("Infinite Jump", 250, true, function(v) Settings.InfiniteJump = v end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 1, -30)
Status.BackgroundTransparency = 1
Status.Text = "Anti AFK: Active | Code: Badges"
Status.TextColor3 = Color3.fromRGB(150, 150, 150)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.Parent = Frame

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
                            if st and st:IsA("RemoteEvent") then
                                st:FireServer()
                            end
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

-- Math solver
local function solveMath(expr)
    if not expr then return nil end
    expr = tostring(expr):gsub("%s+", "")
    expr = expr:gsub("×", "*"):gsub("x", "*"):gsub("X", "*")
    local a, op, b = expr:match("^(-?%d+%.?%d*)([%+%-%*/])(-?%d+%.?%d*)$")
    if not a then return nil end
    local n1, n2 = tonumber(a), tonumber(b)
    if not n1 or not n2 then return nil end
    if op == "+" then return n1 + n2
    elseif op == "-" then return n1 - n2
    elseif op == "*" then return n1 * n2
    elseif op == "/" then if n2 == 0 then return nil end return n1 / n2
    end
    return nil
end

local function sendChat(msg)
    pcall(function()
        -- TextChatService (new chat)
        local channels = TextChat:FindFirstChild("TextChannels")
        if channels then
            local general = channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("General")
            if general then
                general:SendAsync(tostring(msg))
                return
            end
        end
    end)
    pcall(function()
        -- legacy chat
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local say = chatEvents:FindFirstChild("SayMessageRequest")
            if say then
                say:FireServer(tostring(msg), "All")
            end
        end
    end)
    pcall(function()
        -- fallback
        game:GetService("Players"):Chat(tostring(msg))
    end)
end

-- Auto Math: watch chat messages for "What is X ?"
pcall(function()
    local function onMessage(msg)
        if not Settings.AutoMath then return end
        local text = tostring(msg)
        if answered[text] then return end

        -- match: What is 19 - 72 ?   or   What is 1 * 9 ?
        local expr = text:match("[Ww]hat%s+is%s+([%d%.%s%+%-%*/xX×]+)[%s%?]+")
        if not expr then
            expr = text:match("([%d%.]+%s*[%+%-%*/xX×]%s*[%d%.]+)")
        end

        if expr then
            local result = solveMath(expr)
            if result then
                answered[text] = true
                -- slight delay so it looks normal
                task.wait(0.4 + math.random() * 0.6)
                local answer = tostring(math.floor(result + 0.5))
                sendChat(answer)
                print("[AutoMath] answered:", expr, "=", answer)
            end
        end
    end

    -- TextChatService
    pcall(function()
        TextChat.MessageReceived:Connect(function(message)
            onMessage(message.Text)
        end)
    end)

    -- also scan PlayerGui chat labels every second as backup
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
print("Auto Math answers in CHAT now")
print("Auto Strength ON")
