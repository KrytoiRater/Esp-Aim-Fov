-- ============================================
-- VehigHost - FPS Flick Aimbot (HumanoidRootPart)
-- Сделано - Vehighost
-- ============================================

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ====== ЗАГРУЗКА RAYFIELD ======
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ====== ПЕРЕМЕННЫЕ ======
local aimbotEnabled = false
local espEnabled = false
local fovEnabled = false
local fovCircle = nil
local smoothness = 0.3
local fovRadius = 200

-- ====== ФУНКЦИЯ СОЗДАНИЯ FOV ======
local function createFOV()
    if fovCircle then
        fovCircle:Destroy()
        fovCircle = nil
    end
    
    if not fovEnabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVGui"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    circle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    circle.BackgroundTransparency = 1
    circle.ZIndex = 999
    circle.Parent = screenGui
    
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    border.ZIndex = 999
    border.Parent = circle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 0)
    stroke.Thickness = 2
    stroke.Transparency = 0.4
    stroke.Parent = border
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = border
    
    fovCircle = screenGui
end

-- ====== ФУНКЦИЯ ПОЛУЧЕНИЯ БЛИЖАЙШЕГО ИГРОКА (HumanoidRootPart) ======
local function getClosestPlayer()
    local closest = nil
    local closestDist = fovRadius
    local center = camera.ViewportSize / 2
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Целимся в HumanoidRootPart
                local pos, onScreen = camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

-- ====== ESP ======
local function updateESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("ESP_Highlight")
            if espEnabled then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "ESP_Highlight"
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = p.Character
                end
            else
                if h then h:Destroy() end
            end
        end
    end
end

game.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateESP()
    end)
end)

-- ====== ОСНОВНОЙ ЦИКЛ (AIMBOT НА HUMANOIDROOTPART) ======
game:GetService("RunService").Heartbeat:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local root = target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Цель - HumanoidRootPart (тело, не голова)
                local targetPos = root.Position
                local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)
                camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothness)
            end
        end
    end
end)

-- ============================================
-- ====== СОЗДАНИЕ ОКНА ======
-- ============================================

local Window = Rayfield:CreateWindow({
    Name = "VehigHost",
    LoadingTitle = "VehigHost",
    LoadingSubtitle = "by Vehighost",
    Theme = "Dark",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "VehigHost"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("🎯 Aimbot", nil)

-- ====== ТОГГЛЫ ======
MainTab:CreateToggle({
    Name = "🎯 Aimbot (HumanoidRootPart)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(state)
        aimbotEnabled = state
    end
})

MainTab:CreateToggle({
    Name = "🎯 FOV Круг",
    CurrentValue = false,
    Flag = "FOVToggle",
    Callback = function(state)
        fovEnabled = state
        if state then
            createFOV()
        else
            if fovCircle then
                fovCircle:Destroy()
                fovCircle = nil
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "👁️ ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(state)
        espEnabled = state
        updateESP()
    end
})

-- ====== СЛАЙДЕРЫ ======
MainTab:CreateSlider({
    Name = "🎚️ Радиус FOV",
    Range = {50, 400},
    Increment = 5,
    CurrentValue = 200,
    Flag = "FOVSlider",
    Callback = function(value)
        fovRadius = value
        if fovEnabled then
            createFOV()
        end
    end
})

MainTab:CreateSlider({
    Name = "🎚️ Плавность наведения",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = 0.3,
    Flag = "SmoothnessSlider",
    Callback = function(value)
        smoothness = value
    end
