local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local isControllingClone = false
local scriptActive = true -- Kontrolliert, ob das Skript aktiv ist
local originalCFrame = nil
local clonedCharacter = nil
local clonedBackpack = {} -- Speichert geklonte Tools

-- Funktion: Klont ein Tool in das Klon-Character-Modell
local function cloneTool(tool, targetParent)
    local clonedTool = tool:Clone()
    clonedTool.Parent = targetParent
    return clonedTool
end

-- Funktion: Gibt dem Klon alle Waffen & Tools
local function transferWeaponsToClone()
    if not clonedCharacter then return end
    local clonedHumanoid = clonedCharacter:FindFirstChildOfClass("Humanoid")
    
    -- Waffen aus dem Charakter kopieren
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local clonedTool = cloneTool(tool, clonedCharacter)
            table.insert(clonedBackpack, clonedTool)
        end
    end

    -- Waffen aus dem Backpack kopieren
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local clonedTool = cloneTool(tool, clonedCharacter)
            table.insert(clonedBackpack, clonedTool)
        end
    end

    -- Erste Waffe automatisch ausrüsten
    if #clonedBackpack > 0 then
        clonedHumanoid:EquipTool(clonedBackpack[1])
    end
end

-- Funktion: Erstellt einen steuerbaren Klon
local function createClone()
    if not scriptActive or isControllingClone then return end
    isControllingClone = true
    originalCFrame = humanoidRootPart.CFrame -- Speichere Startposition

    -- Klone den Charakter
    clonedCharacter = character:Clone()
    clonedCharacter.Parent = workspace
    clonedCharacter.Name = "Clone_" .. player.Name

    -- Entferne alte Skripte aus dem Klon
    for _, obj in pairs(clonedCharacter:GetChildren()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()
        end
    end

    -- Übertrage Waffen & Tools auf den Klon
    transferWeaponsToClone()

    -- Setze die Kamera & Steuerung auf den Klon
    player.Character = clonedCharacter
    workspace.CurrentCamera.CameraSubject = clonedCharacter:FindFirstChildOfClass("Humanoid")

    -- Echten Charakter unsichtbar machen
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end

    StarterGui:SetCore("SendNotification", {
        Title = "Flame",
        Text = "Klon AKTIVIERT! // Drücke X zum Zurückwechseln",
        Duration = 2
    })
end

-- Funktion: Wechsel zurück zum echten Körper
local function returnToRealCharacter()
    if not isControllingClone then return end
    isControllingClone = false

    -- Setze Kamera & Steuerung zurück auf das Original
    player.Character = character
    workspace.CurrentCamera.CameraSubject = character:FindFirstChildOfClass("Humanoid")

    -- Mache den echten Charakter wieder sichtbar
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end

    -- Waffen aus dem Klon entfernen & zurückgeben
    for _, tool in pairs(clonedBackpack) do
        if tool and tool.Parent then
            tool:Destroy()
        end
    end
    clonedBackpack = {}

    -- Zerstöre den Klon
    if clonedCharacter then
        clonedCharacter:Destroy()
        clonedCharacter = nil
    end

    -- Setze den echten Charakter an die ursprüngliche Position zurück
    character:SetPrimaryPartCFrame(originalCFrame)

    StarterGui:SetCore("SendNotification", {
        Title = "Flame",
        Text = "Klon DEAKTIVIERT! // Du bist wieder im echten Körper",
        Duration = 2
    })
end

-- Funktion: Beende das gesamte Skript mit `Z`
local function disableScript()
    if not scriptActive then return end
    scriptActive = false

    -- Falls gerade ein Klon aktiv ist, zurückwechseln
    if isControllingClone then
        returnToRealCharacter()
    end

    -- Entferne alle Verbindungen & blockiere `X`
    UserInputService.InputBegan:Disconnect()
    StarterGui:SetCore("SendNotification", {
        Title = "Flame",
        Text = "Skript deaktiviert! Neustart nötig zum Reaktivieren.",
        Duration = 3
    })
end

-- `X` drücken → Klon aktivieren oder deaktivieren (nur wenn Skript aktiv)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not scriptActive then return end
    if input.KeyCode == Enum.KeyCode.X then
        if isControllingClone then
            returnToRealCharacter()
        else
            createClone()
        end
    elseif input.KeyCode == Enum.KeyCode.Z then
        disableScript() -- Beendet das Skript mit `Z`
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Flame", 
    Text = "Drücke X, um in einen Klon zu wechseln! Drücke Z zum Deaktivieren!", 
    Duration = 2
})
