local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local teleporting = false
local objectsRemoved = false
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
                           "Objects: " .. (objectsRemoved and "REMOVED" or "VISIBLE") .. "\n" ..
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

local function removeMapObjects()
    if not objectsRemoved then
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") then
                if not part.Name:lower():find("ground") and not part:IsDescendantOf(game:GetService("StarterPack")) and not part:IsDescendantOf(game:GetService("Lighting")) then
                    part:Destroy()
                end
            end
        end
        objectsRemoved = true
        showNotification("Flame", "All Map Objects Removed, Weapons & Essentials Kept!")
    end
end

local function healPlayer()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = math.min(humanoid.Health + 10, humanoid.MaxHealth)
        showNotification("Flame", "+10 Health Added!")
    end
end

-- Make bullets ignore everything except players
local function onBulletFired(bullet)
    bullet.CanCollide = false
    bullet.Touched:Connect(function(hit)
        local character = hit.Parent
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:TakeDamage(25) -- Adjust damage as needed
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
    elseif input.KeyCode == Enum.KeyCode.V then
        removeMapObjects()
    elseif input.KeyCode == Enum.KeyCode.Z then
        healPlayer()
    end
end)

showNotification("Flame", "Teleport, Health Boost & Map Cleanup Loaded!\nPress X: Teleport hitbox\nPress V: Remove Map Objects (Weapons & Essentials Kept)\nPress Z: Gain 10 Health")
