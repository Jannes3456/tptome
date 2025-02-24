local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- Für kontinuierliche Updates

local player = Players.LocalPlayer
local isFloating = false

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

local function floatAboveEnemyFor3Seconds()
    if isFloating then return end -- Falls du schon schwebst, nicht erneut starten
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local enemyHRP = closestPlayer.Character.HumanoidRootPart
        local enemyHead = closestPlayer.Character:FindFirstChild("Head") -- Kopf des Gegners
        local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart and enemyHead then
            local originalPosition = humanoidRootPart.Position -- Speichere die alte Position
            isFloating = true -- Markiere, dass der Spieler schwebt

            -- Verbindung zur Render-Schleife, um Position permanent anzupassen
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not isFloating or not closestPlayer or not closestPlayer.Character then
                    connection:Disconnect()
                    return
                end
                -- Ständig über dem Kopf des Gegners bleiben
                humanoidRootPart.CFrame = CFrame.new(enemyHead.Position + Vector3.new(0, 3, 0)) -- 3 Studs über dem Kopf
            end)

            -- Warte 3 Sekunden, dann beende das Schweben
            task.wait(3)
            isFloating = false
            connection:Disconnect()
            humanoidRootPart.CFrame = CFrame.new(originalPosition) -- Zurück zur alten Position
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        floatAboveEnemyFor3Seconds()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Drücke X, um 3 Sekunden über dem Kopf eines Gegners zu schweben!", 
    Duration = 2
})
