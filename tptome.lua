local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer
local teleporting = false
local bulletsIgnoreWalls = false

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

local function teleportClosestPlayerToMe()
    teleporting = not teleporting
    if teleporting then
        while teleporting do
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPosition = player.Character.HumanoidRootPart.Position + player.Character.HumanoidRootPart.CFrame.LookVector * 3
                closestPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPosition) * CFrame.Angles(0, math.rad(180), 0)
                
                if closestPlayer.Character:FindFirstChild("Humanoid") then
                    closestPlayer.Character.HumanoidRootPart.Size = Vector3.new(10, 10, 10)
                    closestPlayer.Character.HumanoidRootPart.CanCollide = false
                end
            end
            RunService.RenderStepped:Wait()
        end
    end
end

local function onBulletFired(bullet)
    bullet.Touched:Connect(function(hit)
        if hit:IsDescendantOf(player.Character) then return end 
        
        local closestPlayer = getClosestPlayer()
        if closestPlayer and hit:IsDescendantOf(closestPlayer.Character) then
            print("Bullet hit the closest enemy!")
        else
            if bulletsIgnoreWalls then
                bullet.CanCollide = false
                bullet.CollisionGroup = "NoCollide"
                bullet.Touched:Connect(function() bullet.Position = bullet.Position + bullet.CFrame.LookVector * 2 end)
            end
        end
    end)
end

local function setupCollisionGroup()
    pcall(function()
        PhysicsService:CreateCollisionGroup("NoCollide")
        PhysicsService:CollisionGroupSetCollidable("NoCollide", "Default", false)
        PhysicsService:CollisionGroupSetCollidable("NoCollide", "NoCollide", false)
    end)
end

setupCollisionGroup()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportClosestPlayerToMe()
    elseif input.KeyCode == Enum.KeyCode.C then
        bulletsIgnoreWalls = not bulletsIgnoreWalls
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Flame", 
            Text = "Bullet Wall Collision: " .. (bulletsIgnoreWalls and "OFF" or "ON"), 
            Duration = 2
        })
    end
end)

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "Bullet" then
        onBulletFired(child)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Permanent Reverse Teleport Loaded! // Press X to toggle, C to toggle bullet collision", 
    Duration = 2
})
