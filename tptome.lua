local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local teleporting = false
local statusGui, statusLabel

-- UI Label for Status Display in Bottom Left
local function createStatusUI()
    statusGui = Instance.new("ScreenGui")
    statusGui.ResetOnSpawn = false
    statusGui.Parent = game:GetService("CoreGui")

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 200, 0, 100)
    statusLabel.Position = UDim2.new(0.01, 0, 0.80, 0) -- Bottom left
    statusLabel.BackgroundTransparency = 0.5
    statusLabel.TextScaled = true
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    statusLabel.BorderSizePixel = 2
    statusLabel.Parent = statusGui
end

local function updateStatus()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    local healthText = humanoid and ("Health: " .. math.floor(humanoid.Health)) or "Health: N/A"
    
    if statusLabel then
        statusLabel.Text = "[Flame Status]\n" ..
                           "Teleport: " .. (teleporting and "ON" or "OFF") .. "\n" ..
                           healthText
    end
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

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = otherPlayer
            end
        end
    end
    return closestPlayer
end

local function enlargeEnemyHitbox()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, part in pairs(closestPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * 200
            end
        end
        showNotification("Flame", "Enemy Hitbox Enlarged!")
    end
end

local function teleportClosestHitboxToMe()
    teleporting = not teleporting
    showNotification("Flame", "Hitbox Teleport " .. (teleporting and "Enabled" or "Disabled"))
    
    if teleporting then
        RunService.RenderStepped:Connect(function()
            if teleporting then
                local closestPlayer = getClosestPlayer()
                if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPosition = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 3
                    closestPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPosition)
                end
            end
        end)
    end
end

local function createTemporaryPlatform()
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 2, 10)
    platform.Position = player.Character.HumanoidRootPart.Position - Vector3.new(0, 5, 0)
    platform.Anchored = true
    platform.Color = Color3.new(1, 1, 0)
    platform.Parent = Workspace
    task.wait(5)
    platform:Destroy()
end

local function healPlayer()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = math.min(humanoid.Health + 10, humanoid.MaxHealth)
        showNotification("Flame", "+10 Health Added!")
    end
end

-- Adjust damage calculation for headshots and body shots
local function onBulletFired(bullet)
    bullet.CanCollide = false
    bullet.Touched:Connect(function(hit)
        local character = hit.Parent
        if character and character:FindFirstChild("Humanoid") then
            local damage = 25 * 0.5 -- Default reduced damage
            if hit.Name:lower():find("head") then
                damage = damage * 6 -- Headshot multiplier (3x total damage)
            end
            character.Humanoid:TakeDamage(damage)
        end
    end)
end

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "Bullet" then
        onBulletFired(child)
    end
end)

createStatusUI()
updateStatus()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportClosestHitboxToMe()
    elseif input.KeyCode == Enum.KeyCode.Z then
        healPlayer()
    elseif input.KeyCode == Enum.KeyCode.C then
        enlargeEnemyHitbox()
    elseif input.UserInputType == Enum.UserInputType.MouseButton4 then
        createTemporaryPlatform()
    end
end)

showNotification("Flame", "Teleport & Health Boost Loaded!\nPress X: Teleport hitbox\nPress Z: Gain 10 Health\nPress C: Enlarge Enemy Hitbox\nPress MB4: Create Temporary Platform")
