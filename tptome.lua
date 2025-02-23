local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local teleporting = false
local frozenPlayers = {}

local function teleportPlayersToMe()
    local character = player.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        teleporting = true
        local humanoidRootPart = character.HumanoidRootPart
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local otherHumanoidRootPart = otherPlayer.Character.HumanoidRootPart
                
                -- Move player in front and freeze them
                local myPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
                otherHumanoidRootPart.CFrame = CFrame.new(myPosition)
                
                -- Anchor them so they can't move
                otherHumanoidRootPart.Anchored = true
                frozenPlayers[otherPlayer] = true
            end
        end
    end
end

local function stopTeleporting()
    teleporting = false
    for otherPlayer, _ in pairs(frozenPlayers) do
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            otherPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
    frozenPlayers = {}
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
    Text = "Teleport Loaded! // Hold X to teleport players in front of you and freeze them", 
    Duration = 2
})
