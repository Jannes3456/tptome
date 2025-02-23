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

local function teleportPlayersToMe()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        teleporting = true
        local humanoidRootPart = character.HumanoidRootPart
        
        teleportEvent:FireServer(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector)
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
    Text = "Teleport Loaded! // Hold X to teleport players in front of you on all screens", 
    Duration = 2
})
