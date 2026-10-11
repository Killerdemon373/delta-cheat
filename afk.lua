-- Anti AFK / Anti DC
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/afk.lua"))()

print("=== Anti AFK Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Main anti-afk
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("[AntiAFK] prevented idle kick")
end)

-- Extra small movements every 30s just in case
task.spawn(function()
    while true do
        task.wait(30)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
            end
        end)
    end
end)

-- Tiny UI so you know it's running
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiAFK"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(0, 160, 0, 28)
Label.Position = UDim2.new(1, -170, 0, 10)
Label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Label.Text = "Anti AFK: ON"
Label.TextColor3 = Color3.fromRGB(0, 255, 120)
Label.Font = Enum.Font.GothamBold
Label.TextSize = 13
Label.Parent = ScreenGui

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 6)
c.Parent = Label

print("=== Anti AFK Loaded ===")
print("You should not get disconnected from being idle anymore")
