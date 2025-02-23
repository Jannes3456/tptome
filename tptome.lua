local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local teleporting = false
local connections = {}

local function teleportPlayersToMe()
    local character = player.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        teleporting = true
        local humanoidRootPart = character.HumanoidRootPart
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local otherHumanoidRootPart = otherPlayer.Character.HumanoidRootPart
                
                -- Ensure collision and hit detection work correctly
                otherHumanoidRootPart.Anchored = false
                otherHumanoidRootPart.CanCollide = true
                
                local function updatePosition()
                    if teleporting then
                        local myPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
                        otherHumanoidRootPart.CFrame = CFrame.new(myPosition)
                    end
                end
                
                connections[otherPlayer] = RunService.RenderStepped:Connect(updatePosition)
            end
        end
    end
end

local function stopTeleporting()
    teleporting = false
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
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
    Text = "Teleport Loaded! // Hold X to keep all in front of you and allow damage", 
    Duration = 2
})
