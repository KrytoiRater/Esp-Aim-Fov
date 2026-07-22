-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- НАСТРОЙКИ ЧИТА (Управляются через Rayfield)
local AIMBOT_ENABLED = true    -- Авто-лок включен по умолчанию
local ESP_ENABLED = true        -- ВХ включен по умолчанию
local FOV_RADIUS = 150         -- Радиус круга
local SMOOTHNESS = 0.2         -- Плавность наводки
local TEAM_CHECK = true        -- Проверка на команду

-- СОЗДАНИЕ ОКНА RAYFIELD UI
local Window = Rayfield:CreateWindow({
    Name = "Universal Cheat Hub",
    LoadingTitle = "Loading Studio Suite...",
    LoadingSubtitle = "by AI Assistant",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Создание вкладки управления
local MainTab = Window:CreateTab("Главная", 4483362458)

-- КНОПКИ И ТУМБЛЕРЫ В МЕНЮ
MainTab:CreateToggle({
    Name = "Включить Аимбот (Авто-лок)",
    CurrentValue = true,
    Flag = "AimbotToggle",
    Callback = function(Value)
        AIMBOT_ENABLED = Value
    end,
})

MainTab:CreateToggle({
    Name = "Включить ВХ (ESP)",
    CurrentValue = true,
    Flag = "ESPToggle",
    Callback = function(Value)
        ESP_ENABLED = Value
    end,
})

MainTab:CreateToggle({
    Name = "Проверка Команды (Team Check)",
    CurrentValue = true,
    Flag = "TeamToggle",
    Callback = function(Value)
        TEAM_CHECK = Value
    end,
})

MainTab:CreateSlider({
    Name = "Радиус FOV",
    Range = {50, 400},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "FOVSlider",
    Callback = function(Value)
        FOV_RADIUS = Value
    end,
})

MainTab:CreateSlider({
    Name = "Плавность Аима (Меньше = Быстрее)",
    Range = {5, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 20,
    Flag = "SmoothSlider",
    Callback = function(Value)
        SMOOTHNESS = Value / 100
    end,
})

-- ИСПРАВЛЕННЫЙ ВХ (ESP)
local function addESP(char, p)
    if not char then return end
    
    -- Если ВХ выключен или это союзник при TeamCheck — удаляем старую подсветку
    if not ESP_ENABLED or (TEAM_CHECK and p.Team == player.Team) then 
        if char:FindFirstChild("E") then char.E:Destroy() end
        return 
    end
    
    -- Создаем подсветку Highlight
    if not char:FindFirstChild("E") then
        local h = Instance.new("Highlight")
        h.Name = "E"
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.FillTransparency = 0.6
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.OutlineTransparency = 0.1
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
    end
end

-- Постоянный цикл обновления ВХ
task.spawn(function()
    while task.wait(0.5) do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                addESP(p.Character, p)
            end
        end
    end
end)

-- СОЗДАНИЕ КРУГА FOV НА ЭКРАНЕ
local fovGui = game:GetService("CoreGui"):FindFirstChild("F") or Instance.new("ScreenGui")
fovGui.Name = "F"
fovGui.Parent = game:GetService("CoreGui")
fovGui.ResetOnSpawn = false

local circle = fovGui:FindFirstChild("CircleFrame") or Instance.new("Frame")
circle.Name = "CircleFrame"
circle.BackgroundTransparency = 1
circle.Parent = fovGui

local stroke = circle:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 0)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = circle

local corner = circle:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = circle

-- ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕЙ ЦЕЛИ К ЦЕНТРУ
local function GetClosestTarget()
    local maxDist = FOV_RADIUS
    local center = camera.ViewportSize / 2
    local targetPart = nil
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if not TEAM_CHECK or p.Team ~= player.Team then
                local char = p.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    if head and hum and hum.Health > 0 then
                        local pos, onScreen = camera:WorldToScreenPoint(head.Position)
                        if onScreen and pos.Z > 0 then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < maxDist then
                                maxDist = dist
                                targetPart = head
                            end
                        end
                    end
                end
            end
        end
    end
    return targetPart
end

-- ЦИКЛ НАВЕДЕНИЯ И ОТРИСОВКИ (КАЖДЫЙ КАДР)
RunService.RenderStepped:Connect(function()
    local center = camera.ViewportSize / 2
    
    -- Синхронизация круга FOV с настройками интерфейса
    if AIMBOT_ENABLED then
        circle.Visible = true
        circle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
        circle.Position = UDim2.new(0, center.X - FOV_RADIUS, 0, center.Y - FOV_RADIUS)
    else
        circle.Visible = false
    end
    
    -- Автоматический жесткий лок без кнопок мыши
    if AIMBOT_ENABLED then
        local target = GetClosestTarget()
        if target then
            local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, SMOOTHNESS)
        end
    end
end)

-- Уведомление об успешном запуске
Rayfield:Notify({
    Title = "Чит Запущен!",
    Content = "Все функции активны. Настройки доступны в меню.",
    Duration = 5,
    Image = 4483362458,
})
-- by @laf4zi
