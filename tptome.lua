local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer
local teleporting = false
local bulletsIgnoreWalls = false
local boxVisible = false
local enemyBoxVisible = false
local boxPart = nil
local enemyBoxPart = nil

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

local function toggleBox()
    boxVisible = not boxVisible
    if boxVisible then
        if not boxPart then
            boxPart = Instance.new("Part")
            boxPart.Size = Vector3.new(5, 7, 5)
            boxPart.Transparency = 0.5
            boxPart.Anchored = true
            boxPart.CanCollide = false
            boxPart.Color = Color3.new(1, 0, 0)
            boxPart.Parent = Workspace
        end
        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                boxPart.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        end)
    else
        if boxPart then
            boxPart:Destroy()
            boxPart = nil
        end
    end
end

local function toggleEnemyBox()
    enemyBoxVisible = not enemyBoxVisible
    local closestPlayer = getClosestPlayer()
    if enemyBoxVisible and closestPlayer and closestPlayer.Character then
        if not enemyBoxPart then
            enemyBoxPart = Instance.new("Part")
            enemyBoxPart.Size = Vector3.new(5, 7, 5)
            enemyBoxPart.Transparency = 0.5
            enemyBoxPart.Anchored = true
            enemyBoxPart.CanCollide = false
            enemyBoxPart.Color = Color3.new(0, 1, 0)
            enemyBoxPart.Parent = Workspace
        end
        RunService.RenderStepped:Connect(function()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                enemyBoxPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame
            end
        end)
    else
        if enemyBoxPart then
            enemyBoxPart:Destroy()
            enemyBoxPart = nil
        end
    end
end

local function onBulletFired(bullet)
    bullet.Position = Vector3.new(0, -1000, 0)
    bullet.Touched:Connect(function(hit)
        local closestPlayer = getClosestPlayer()
        if closestPlayer and hit:IsDescendantOf(closestPlayer.Character) then
            print("Bullet hit the closest enemy!")
        end
    end)
end

local function disableWallCollision()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("MeshPart") then
            part.CollisionGroup = "NoCollide"
        end
    end
end

disableWallCollision()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportClosestHitboxToMe()
    elseif input.KeyCode == Enum.KeyCode.C then
        bulletsIgnoreWalls = not bulletsIgnoreWalls
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Flame", 
            Text = "Bullet Wall Collision: " .. (bulletsIgnoreWalls and "OFF" or "ON"), 
            Duration = 2
        })
    elseif input.KeyCode == Enum.KeyCode.E then
        toggleEnemyBox()
    end
end)

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "Bullet" then
        onBulletFired(child)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Permanent Reverse Teleport Loaded! // Press X to toggle hitbox, C to toggle bullet collision, E to toggle enemy box", 
    Duration = 2
})
