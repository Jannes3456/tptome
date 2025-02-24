local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local teleporting = false

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
                closestPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myPosition) * CFrame.Angles(0, math.rad(180), 0) -- Gegner schaut zu mir
                
                -- Hitbox des Gegners vor dem Spieler setzen
                if closestPlayer.Character:FindFirstChild("Humanoid") then
                    closestPlayer.Character.HumanoidRootPart.Size = Vector3.new(10, 10, 10) -- Größere Hitbox
                    closestPlayer.Character.HumanoidRootPart.CanCollide = false -- Verhindert Kollision
                end
            end
            RunService.RenderStepped:Wait()
        end
    end
end

-- Kugeln durch alles außer den Gegner gehen lassen
local function onBulletFired(bullet)
    bullet.Touched:Connect(function(hit)
        if hit:IsDescendantOf(player.Character) then return end -- Verhindert Kollision mit sich selbst
        
        local closestPlayer = getClosestPlayer()
        if closestPlayer and hit:IsDescendantOf(closestPlayer.Character) then
            -- Kugel trifft den Gegner
            print("Bullet hit the closest enemy!")
        else
            -- Verhindert Kollision mit Wänden oder anderen Objekten
            bullet.CanCollide = false
            bullet.CollisionGroup = "NoCollide"
        end
    end)
end

-- Setzt eine Kollisionsebene, um Kugeln durch Objekte zu lassen
local function setupCollisionGroup()
    local PhysicsService = game:GetService("PhysicsService")
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
    end
end)

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "Bullet" then
        onBulletFired(child)
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Permanent Reverse Teleport Loaded! // Press X to toggle", 
    Duration = 2
})
