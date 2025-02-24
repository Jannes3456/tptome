local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local teleporting = false
local statusGui, statusLabel
local headSize = 25
local HitboxDisabled = true
local teleportConnection

-- UI Label for Status Display in Bottom Left
local function createStatusUI()
    statusGui = Instance.new("ScreenGui")
    statusGui.ResetOnSpawn = false
    statusGui.Parent = game:GetService("CoreGui")

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 250, 0, 120)
    statusLabel.Position = UDim2.new(0.01, 0, 0.75, 0) -- Adjusted position
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
                           "Hitbox Enlarged: " .. (not HitboxDisabled and "ON" or "OFF") .. "\n" ..
                           healthText
    end
end

local function showNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
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

local function toggleHitbox()
    HitboxDisabled = not HitboxDisabled
    updateStatus()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.C then
        toggleHitbox()
    end
end)

RunService.RenderStepped:Connect(function()
    if not HitboxDisabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    pcall(function()
                        rootPart.Size = Vector3.new(headSize, headSize, headSize)
                        rootPart.Transparency = 1
                        rootPart.BrickColor = BrickColor.new("Really black")
                        rootPart.Material = Enum.Material.Neon
                        rootPart.CanCollide = false
                        rootPart.Shape = Enum.PartType.Ball
                    end)
                end
            end
        end
    end
end)

local function teleportClosestHitboxToMe()
    teleporting = not teleporting
    showNotification("Flame", "Hitbox Teleport " .. (teleporting and "Enabled" or "Disabled"))
    
    if teleporting then
        if teleportConnection then teleportConnection:Disconnect() end
        teleportConnection = RunService.RenderStepped:Connect(function()
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPosition = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 3
                closestPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPosition)
            end
        end)
    else
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
    end
    updateStatus()
end

createStatusUI()
updateStatus()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportClosestHitboxToMe()
    end
end)

showNotification("Flame", "Teleport & Hitbox Enlargement Loaded!\nPress X: Teleport enemy hitbox\nPress C: Toggle enlarged hitbox")
