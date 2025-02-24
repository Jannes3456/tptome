local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer
local teleporting = false
local magicBulletsEnabled = false
local ESP = false
local wallsInvisible = false
local boxVisible = false
local enemyBoxVisible = false
local boxPart = nil
local enemyBoxPart = nil

-- UI Label for Status Display
local statusGui = Instance.new("ScreenGui")
statusGui.Parent = player:FindFirstChildOfClass("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 300, 0, 100)
statusLabel.Position = UDim2.new(0.02, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.Parent = statusGui

local function updateStatus()
    statusLabel.Text = "Teleport: " .. (teleporting and "ON" or "OFF") ..
                       "\nMagic Bullets: " .. (magicBulletsEnabled and "ON" or "OFF") ..
                       "\nESP: " .. (ESP and "ON" or "OFF") ..
                       "\nWalls: " .. (wallsInvisible and "INVISIBLE" or "VISIBLE")
end

local function showNotification(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end)
    updateStatus()
end

local function isOnSameTeam(otherPlayer)
    if player.Team and otherPlayer.Team then
        return player.Team == otherPlayer.Team
    end
    return false
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not isOnSameTeam(otherPlayer) then
                local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end
    return closestPlayer
end

local function teleportClosestHitboxToMe()
    teleporting = not teleporting
    showNotification("Flame", "Hitbox Teleport " .. (teleporting and "Enabled" or "Disabled"))
    if teleporting then
        while teleporting do
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPosition = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 3
                closestPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPosition) * CFrame.Angles(0, math.rad(180), 0)
            end
            RunService.RenderStepped:Wait()
        end
    end
end

local function toggleMagicBullets()
    magicBulletsEnabled = not magicBulletsEnabled
    showNotification("Flame", "Magic Bullets " .. (magicBulletsEnabled and "Enabled" or "Disabled"))
end

local function toggleESP()
    ESP = not ESP
    showNotification("Flame", "ESP " .. (ESP and "Enabled" or "Disabled"))
    for _, player in pairs(Players:GetPlayers()) do
        EspActivate(player)
    end
end

local function toggleWalls()
    wallsInvisible = not wallsInvisible
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("MeshPart") then
            if part.Name:lower():find("wall") or part.Size.Y > 10 then
                part.Transparency = wallsInvisible and 1 or 0
                part.CanCollide = not wallsInvisible
                part.CollisionGroup = wallsInvisible and "NoCollide" or "Default"
            end
        end
    end
    showNotification("Flame", "Walls " .. (wallsInvisible and "Invisible" or "Visible"))
end

local function setupCollisionGroup()
    pcall(function()
        PhysicsService:CreateCollisionGroup("NoCollide")
        PhysicsService:CollisionGroupSetCollidable("NoCollide", "Default", false)
        PhysicsService:CollisionGroupSetCollidable("NoCollide", "NoCollide", false)
    end)
end

setupCollisionGroup()

for _, player in pairs(Players:GetPlayers()) do
    EspActivate(player)
    player.CharacterAdded:Connect(function() EspActivate(player) end)
    player:GetPropertyChangedSignal("Team"):Connect(function() EspActivate(player) end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() EspActivate(player) end)
    player:GetPropertyChangedSignal("Team"):Connect(function() EspActivate(player) end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportClosestHitboxToMe()
    elseif input.KeyCode == Enum.KeyCode.C then
        toggleMagicBullets()
    elseif input.KeyCode == Enum.KeyCode.E then
        toggleESP()
    elseif input.KeyCode == Enum.KeyCode.V then
        toggleWalls()
    end
end)

showNotification("Flame", "Magic Bullets, ESP, Teleport & Wall Toggle Loaded! \nPress X: Teleport hitbox \nPress C: Toggle Magic Bullets \nPress E: Toggle ESP \nPress V: Toggle walls")
