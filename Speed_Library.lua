-- Speed_Library (shared UI)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Library.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Custom = {}
Custom.ColorRGB = Color3.fromRGB(250, 7, 7)

function Custom:Create(Name, Properties, Parent)
    local inst = Instance.new(Name)
    for i, v in pairs(Properties) do inst[i] = v end
    if Parent then inst.Parent = Parent end
    return inst
end

function Custom:EnabledAFK()
    Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end
Custom:EnabledAFK()

local function MakeDraggable(top, obj)
    local dragging, dragStart, startPos = false, nil, nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local Speed_Library = {}
Speed_Library.Unloaded = false

function Speed_Library:CreateWindow(Config)
    local Title = Config.Title or Config[1] or "Menu"
    local Description = Config.Description or Config[2] or ""
    local SizeUi = Config.SizeUi or Config[4] or UDim2.fromOffset(480, 340)

    local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
    local SpeedHubXGui = Custom:Create("ScreenGui", {ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent)

    local DropShadowHolder = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        Size = SizeUi,
        Position = UDim2.new(0.5, -SizeUi.X.Offset/2, 0.5, -SizeUi.Y.Offset/2),
        Name = "DropShadowHolder"
    }, SpeedHubXGui)

    local Main = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = SizeUi,
        Name = "Main"
    }, DropShadowHolder)

    Custom:Create("UICorner", {}, Main)
    Custom:Create("UIStroke", {Color = Color3.fromRGB(50, 50, 50), Thickness = 1.5}, Main)

    local Top = Custom:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Name = "Top"
    }, Main)

    local TextLabel = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 14, 0, 0)
    }, Top)

    local TextLabel1 = Custom:Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = Description,
        TextColor3 = Custom.ColorRGB,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, TextLabel.TextBounds.X + 20, 0, 0)
    }, Top)

    local Close = Custom:Create("TextButton", {
        Font = Enum.Font.SourceSans,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0.5, -12),
        Size = UDim2.new(0, 25, 0, 25),
        Name = "Close"
    }, Top)

    local Min = Custom:Create("TextButton", {
        Font = Enum.Font.SourceSans,
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -58, 0.5, -12),
        Size = UDim2.new(0, 25, 0, 25),
        Name = "Min"
    }, Top)

    local Content = Custom:Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 48),
        Size = UDim2.new(1, -24, 1, -58),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        Name = "Content"
    }, Main)

    local list = Custom:Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Content)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    MakeDraggable(Top, DropShadowHolder)

    -- floating open button when minimized
    local OpenBtn = Custom:Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Text = Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Size = UDim2.new(0, 120, 0, 32),
        Position = UDim2.new(0, 20, 0, 20),
        Visible = false,
        Name = "OpenBtn"
    }, SpeedHubXGui)
    Custom:Create("UICorner", {CornerRadius = UDim.new(0, 8)}, OpenBtn)

    Min.Activated:Connect(function()
        DropShadowHolder.Visible = false
        OpenBtn.Visible = true
    end)
    OpenBtn.Activated:Connect(function()
        DropShadowHolder.Visible = true
        OpenBtn.Visible = false
    end)
    Close.Activated:Connect(function()
        SpeedHubXGui:Destroy()
        Speed_Library.Unloaded = true
    end)

    local Window = {}

    function Window:AddToggle(name, default, callback)
        local frame = Custom:Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(28, 28, 28),
            Size = UDim2.new(1, 0, 0, 36),
            Name = name
        }, Content)
        Custom:Create("UICorner", {CornerRadius = UDim.new(0, 6)}, frame)

        Custom:Create("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            TextSize = 13,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -70, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        }, frame)

        local btn = Custom:Create("TextButton", {
            Text = default and "ON" or "OFF",
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = default and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Position = UDim2.new(1, -58, 0.5, -12),
            Size = UDim2.new(0, 48, 0, 24)
        }, frame)
        Custom:Create("UICorner", {CornerRadius = UDim.new(0, 4)}, btn)

        local state = default
        btn.Activated:Connect(function()
            state = not state
            btn.Text = state and "ON" or "OFF"
            btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
            if callback then callback(state) end
        end)
        return {Set = function(_, v)
            state = v
            btn.Text = state and "ON" or "OFF"
            btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
            if callback then callback(state) end
        end}
    end

    function Window:AddButton(name, callback)
        local btn = Custom:Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(28, 28, 28),
            Size = UDim2.new(1, 0, 0, 36),
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(230, 230, 230)
        }, Content)
        Custom:Create("UICorner", {CornerRadius = UDim.new(0, 6)}, btn)
        btn.Activated:Connect(function()
            if callback then callback() end
        end)
    end

    function Window:AddLabel(text)
        Custom:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(160, 160, 160),
            TextXAlignment = Enum.TextXAlignment.Left
        }, Content)
    end

    return Window
end

return Speed_Library
