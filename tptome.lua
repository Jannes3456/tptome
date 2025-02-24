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

-- UI Label for Status Display in Bottom Left
local statusGui = Instance.new("ScreenGui")
statusGui.ResetOnSpawn = false
statusGui.Parent = game:GetService("CoreGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 80)
statusLabel.Position = UDim2.new(0.01, 0, 0.85, 0) -- Bottom left
statusLabel.BackgroundTransparency = 0.5
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.BorderSizePixel = 2
statusLabel.Parent = statusGui

local function updateStatus()
    statusLabel.Text = "[Flame Status]\n" ..
                       "Teleport: " .. (teleporting and "ON" or "OFF") .. "\n" ..
                       "Magic Bullets: " .. (magicBulletsEnabled and "ON" or "OFF") .. "\n" ..
                       "ESP: " .. (ESP and "ON" or "OFF") .. "\n" ..
                       "Walls: " .. (wallsInvisible and "INVISIBLE" or "VISIBLE")
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
end

local function toggleMagicBullets()
    magicBulletsEnabled = not magicBulletsEnabled
    showNotification("Flame", "Magic Bullets " .. (magicBulletsEnabled and "Enabled" or "Disabled"))
end

local function toggleESP()
    ESP = not ESP
    showNotification("Flame", "ESP " .. (ESP and "Enabled" or "Disabled"))
end

local function toggleWalls()
    wallsInvisible = not wallsInvisible
    showNotification("Flame", "Walls " .. (wallsInvisible and "Invisible" or "Visible"))
end

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

showNotification("Flame", "Magic Bullets, ESP, Teleport & Wall Toggle Loaded!\nPress X: Teleport hitbox\nPress C: Toggle Magic Bullets\nPress E: Toggle ESP\nPress V: Toggle walls")
