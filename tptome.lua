local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- RemoteEvent für serverseitige Teleportation
local teleportEvent = ReplicatedStorage:FindFirstChild("TeleportPlayersEvent")
if not teleportEvent then
    teleportEvent = Instance.new("RemoteEvent", ReplicatedStorage)
    teleportEvent.Name = "TeleportPlayersEvent"
end

local function isOnSameTeam(otherPlayer)
    if player.Team and otherPlayer.Team then
        return player.Team == otherPlayer.Team
    end
    return false
end

local function teleportPlayersToMe()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        teleportEvent:FireServer()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        teleportPlayersToMe()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Teleport Loaded! // Press X to teleport all players to you", 
    Duration = 2
})
