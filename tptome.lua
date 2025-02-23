local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local teleporting = false

-- RemoteEvent für serverseitige Positionsänderung
local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportPlayersEvent")
if not teleportEvent then
    teleportEvent = Instance.new("RemoteEvent", ReplicatedStorage)
    teleportEvent.Name = "TeleportPlayersEvent"
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local character = player.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character.HumanoidRootPart
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
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

local function teleportPlayersToMe()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        teleporting = true
        local humanoidRootPart = character.HumanoidRootPart
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                teleportEvent:FireServer(player, otherPlayer)
            end
        end
    end
end

local function stopTeleporting()
    teleporting = false
    teleportEvent:FireServer(nil, nil)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportPlayersToMe()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.X then
        stopTeleporting()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Teleport Loaded! // Hold X to teleport all players to you", 
    Duration = 2
})
