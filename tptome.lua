local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- Für kontinuierliche Updates

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local isFloating = false
local originalCFrame = nil
local connection = nil

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
                local distance = (humanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end
    return closestPlayer
end

local function startFloating()
    if isFloating then return end -- Falls du schon schwebst, nicht erneut starten
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local enemyHead = closestPlayer.Character.Head
        originalCFrame = humanoidRootPart.CFrame -- Speichert die originale Position
        isFloating = true -- Markiere, dass der Spieler schwebt

        -- Verbindung zur Render-Schleife, um Position permanent anzupassen
        connection = RunService.RenderStepped:Connect(function()
            if not isFloating or not closestPlayer or not closestPlayer.Character then
                connection:Disconnect()
                return
            end
            -- Nur das Charakter-Modell bewegen (nicht die Hitbox)
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part ~= humanoidRootPart then
                    part.CFrame = CFrame.new(enemyHead.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
    end
end

local function stopFloating()
    if not isFloating then return end -- Falls du nicht schwebst, nichts tun
    isFloating = false
    if connection then connection:Disconnect() end

    -- Charakter-Modell zurück zur Original-Position setzen
    if originalCFrame then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part ~= humanoidRootPart then
                part.CFrame = originalCFrame
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        startFloating()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.X then
        stopFloating()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Halte X gedrückt, um über dem Kopf eines Gegners zu schweben!", 
    Duration = 2
})
