local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local function teleportAllToMe()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPosition = player.Character.HumanoidRootPart.Position
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = otherPlayer.Character.HumanoidRootPart
            
            task.spawn(function()
                for i = 1, 50 do
                    local targetPosition = myPosition + player.Character.HumanoidRootPart.CFrame.LookVector * 5
                    humanoidRootPart.CFrame = CFrame.new(targetPosition)
                    
                    if otherPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        otherPlayer.Character.HumanoidRootPart.Size = Vector3.new(5, 5, 5)
                    end
                    
                    task.wait(0.1)
                end
                
                if otherPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    otherPlayer.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                end
            end)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.H then
        teleportAllToMe()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Flame", 
    Text = \"Teleport Loaded! // H to bring players in front of you 50 times in 5s\", 
    Duration = 2
})
