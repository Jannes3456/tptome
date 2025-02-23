local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function teleportPlayersToMe()
    local character = player.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        local myPosition = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.LookVector * 5
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = otherPlayer.Character.HumanoidRootPart
                
                -- Store original position server-side but change only locally
                humanoidRootPart:SetAttribute("OriginalPosition", humanoidRootPart.Position)
                
                -- Move them in front of the player on client only
                humanoidRootPart.CFrame = CFrame.new(myPosition)
            end
        end
        
        task.delay(3, function()
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = otherPlayer.Character.HumanoidRootPart
                    local originalPosition = humanoidRootPart:GetAttribute("OriginalPosition")
                    
                    if originalPosition then
                        humanoidRootPart.CFrame = CFrame.new(originalPosition)
                    end
                end
            end
        end)
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
    Text = "Teleport Loaded! // X to teleport all in front of you", 
    Duration = 2
})
