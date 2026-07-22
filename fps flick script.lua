print("=== START ===")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

print("1. Services OK")

-- ESP
local function addESP(char)
    if not char then return end
    if char:FindFirstChild("E") then return end
    local h = Instance.new("Highlight")
    h.Name = "E"
    h.FillColor = Color3.new(1, 0, 0)
    h.FillTransparency = 0.5
    h.OutlineColor = Color3.new(1, 1, 1)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= player and p.Character then
        addESP(p.Character)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        addESP(char)
    end)
end)

print("2. ESP OK")

-- FOV
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "F"
fovGui.Parent = game:GetService("CoreGui")
fovGui.ResetOnSpawn = false

local circle = Instance.new("Frame")
circle.Size = UDim2.new(0, 400, 0, 400)
circle.BackgroundTransparency = 1
circle.Parent = fovGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(0, 1, 0)
stroke.Thickness = 2
stroke.Transparency = 0.4
stroke.Parent = circle

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle

RunService.RenderStepped:Connect(function()
    local c = camera.ViewportSize / 2.4
    circle.Position = UDim2.new(0, c.X - 200, 0, c.Y - 200)
end)

print("3. FOV OK")

-- Aimbot
local aimbot = true
local fovRadius = 90
local smooth = 0.3

RunService.Heartbeat:Connect(function()
    local closest = nil
    local minDist = fovRadius
    local center = camera.ViewportSize / 2
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if r and hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToScreenPoint(r.Position)
                if onScreen and pos.Z > 0 then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = r
                    end
                end
            end
        end
    end
    
    if closest and aimbot then
        camera.CFrame = camera.CFrame:Lerp(
            CFrame.new(camera.CFrame.Position, closest.Position),
            smooth
        )
    end
end)

print("4. Aimbot OK")

-- Hotkeys
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        aimbot = not aimbot
        print("Aimbot:", aimbot)
    end
end)

print("5. Hotkeys OK")
print("=== LOADED | F1 = toggle aimbot ===")
