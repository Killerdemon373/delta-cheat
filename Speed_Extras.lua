-- Speed_Extras | Keybind + Config + ColorPicker + Search
-- load after Speed_Library:
-- local Extras = loadstring(game:HttpGet("https://raw.githubusercontent.com/Killerdemon373/delta-cheat/main/Speed_Extras.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Extras = {}

-- ===================== CONFIG SAVE / LOAD =====================
local CONFIG_NAME = "SpeedConfig.json"

function Extras:SaveConfig(data)
    data = data or {}
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not ok then return false, "encode failed" end
    if writefile then
        pcall(writefile, CONFIG_NAME, encoded)
        return true
    end
    return false, "writefile not available"
end

function Extras:LoadConfig()
    if not isfile or not isfile(CONFIG_NAME) then return {} end
    local ok, raw = pcall(readfile, CONFIG_NAME)
    if not ok or not raw then return {} end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok2 and type(data) == "table" then return data end
    return {}
end

function Extras:DeleteConfig()
    if isfile and isfile(CONFIG_NAME) and delfile then
        pcall(delfile, CONFIG_NAME)
    end
end

-- ===================== KEYBIND =====================
-- Usage:
-- Extras:AddKeybind(Enum.KeyCode.V, function() print("pressed") end)
-- Extras:AddKeybind("E", function() end)  -- string also works

local keybinds = {}

function Extras:AddKeybind(key, callback)
    local code = key
    if type(key) == "string" then
        code = Enum.KeyCode[key:upper()] or Enum.KeyCode[key]
    end
    if not code then return end
    keybinds[code] = callback
end

function Extras:RemoveKeybind(key)
    local code = type(key) == "string" and (Enum.KeyCode[key:upper()] or Enum.KeyCode[key]) or key
    keybinds[code] = nil
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local cb = keybinds[input.KeyCode]
    if cb then pcall(cb) end
end)

-- ===================== COLOR PICKER (simple) =====================
-- Creates a small frame with R/G/B inputs + preview
-- callback(color3) when changed

function Extras:CreateColorPicker(parent, defaultColor, callback)
    defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)
    callback = callback or function() end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 40)
    preview.Position = UDim2.new(0, 10, 0.5, -20)
    preview.BackgroundColor3 = defaultColor
    preview.BorderSizePixel = 0
    preview.Parent = frame

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 6)
    pc.Parent = preview

    local function makeBox(x, text, val)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 50, 0, 28)
        box.Position = UDim2.new(0, x, 0.5, -14)
        box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        box.Text = tostring(val)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.PlaceholderText = text
        box.Parent = frame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = box
        return box
    end

    local r = math.floor(defaultColor.R * 255)
    local g = math.floor(defaultColor.G * 255)
    local b = math.floor(defaultColor.B * 255)

    local rBox = makeBox(60, "R", r)
    local gBox = makeBox(120, "G", g)
    local bBox = makeBox(180, "B", b)

    local function update()
        local nr = math.clamp(tonumber(rBox.Text) or 0, 0, 255)
        local ng = math.clamp(tonumber(gBox.Text) or 0, 0, 255)
        local nb = math.clamp(tonumber(bBox.Text) or 0, 0, 255)
        local col = Color3.fromRGB(nr, ng, nb)
        preview.BackgroundColor3 = col
        callback(col)
    end

    rBox.FocusLost:Connect(update)
    gBox.FocusLost:Connect(update)
    bBox.FocusLost:Connect(update)

    return {
        Set = function(_, col)
            rBox.Text = tostring(math.floor(col.R * 255))
            gBox.Text = tostring(math.floor(col.G * 255))
            bBox.Text = tostring(math.floor(col.B * 255))
            preview.BackgroundColor3 = col
            callback(col)
        end,
        Get = function() return preview.BackgroundColor3 end
    }
end

-- ===================== SEARCH BAR =====================
-- Filters children of a ScrollingFrame by name/text containing query

function Extras:CreateSearchBar(parent, targetScroll)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 30)
    box.Position = UDim2.new(0, 10, 0, 5)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.Text = ""
    box.PlaceholderText = "Search..."
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = box

    box:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(box.Text)
        if not targetScroll then return end
        for _, child in ipairs(targetScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                if q == "" then
                    child.Visible = true
                else
                    local name = string.lower(child.Name or "")
                    local text = ""
                    for _, d in ipairs(child:GetDescendants()) do
                        if d:IsA("TextLabel") or d:IsA("TextButton") then
                            text = text .. " " .. string.lower(d.Text or "")
                        end
                    end
                    child.Visible = name:find(q, 1, true) ~= nil or text:find(q, 1, true) ~= nil
                end
            end
        end
    end)

    return box
end

print("[Speed_Extras] loaded - Keybind / Config / ColorPicker / Search")
return Extras
