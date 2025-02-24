local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

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

local function teleportAboveEnemyFor3Seconds()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local enemyPosition = closestPlayer.Character.HumanoidRootPart.Position
        local newPosition = enemyPosition + Vector3.new(0, 5, 0) -- 5 Studs über dem Gegner

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local originalPosition = humanoidRootPart.Position -- Speichere die alte Position
            
            -- Teleportiere den Spieler nur lokal
            humanoidRootPart.CFrame = CFrame.new(newPosition)

            -- Nach 3 Sekunden zurück teleportieren
            task.wait(3)
            humanoidRootPart.CFrame = CFrame.new(originalPosition)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportAboveEnemyFor3Seconds()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Drücke X, um für 3 Sekunden über einem Gegner zu schweben!", 
    Duration = 2
})
