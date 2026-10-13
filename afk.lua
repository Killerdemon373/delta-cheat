-- Anti AFK - uses shared Speed_Library
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/afk.lua"))()

print("=== Anti AFK Loading ===")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local enabled = true

Player.Idled:Connect(function()
    if not enabled then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("[AntiAFK] prevented idle kick")
end)

task.spawn(function()
    while true do
        task.wait(30)
        if not enabled then continue end
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

local Speed_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Library.lua"))()
local Window = Speed_Library:CreateWindow({
    Title = "Anti AFK",
    Description = "Stay Online",
    SizeUi = UDim2.fromOffset(320, 160)
})

Window:AddToggle("Anti AFK", true, function(v) enabled = v end)
Window:AddLabel("Prevents idle disconnect")

print("=== Anti AFK Loaded (Speed_Library UI) ===")
