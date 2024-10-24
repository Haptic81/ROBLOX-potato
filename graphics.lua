local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- List of part names or parent names to exclude from optimization
local excludedParts = {
    "SpawnLocation",   -- For spawn points that should retain their appearance
    "Checkpoint",      -- Any checkpoints or critical objects
    "UI",              -- If there are UI elements that should stay
    "Water",           -- If you want to keep water with its usual properties
}

-- Function to check if a part belongs to a player (to avoid modifying it)
local function isPartOfPlayer(obj)
    for _, player in pairs(Players:GetPlayers()) do
        if obj:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

-- Function to check if a part or its parent should be excluded from optimization
local function shouldExcludePart(part)
    -- Check if the part itself is in the exclusion list
    for _, excludedName in pairs(excludedParts) do
        if part.Name:find(excludedName) or (part.Parent and part.Parent.Name:find(excludedName)) then
            return true
        end
    end
    return false
end

-- Function to hide player usernames (removes BillboardGui elements that display names)
local function hideUsernames()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            -- Find the BillboardGui responsible for displaying the username
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj:IsA("BillboardGui") and obj.Name == "NameTag" then
                    obj:Destroy()  -- Remove the name tag
                end
            end
        end
    end

    -- Continuously monitor new players and hide their usernames when they spawn
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            for _, obj in pairs(character:GetDescendants()) do
                if obj:IsA("BillboardGui") and obj.Name == "NameTag" then
                    obj:Destroy()  -- Remove the name tag for new players
                end
            end
        end)
    end)
end

-- Function to remove or reduce particles in the game
local function optimizeParticles()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            -- Remove or significantly reduce particles for performance
            obj.Rate = 0  -- Disables particle emission to save performance
            obj.Enabled = false  -- Turn off the effect
        end
    end
    
    -- Continuously monitor new particle effects and optimize them
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Rate = 0  -- Disable new particles
            obj.Enabled = false  -- Turn off the effect
        end
    end)
end

-- Function to apply smooth visuals and FPS boost settings without changing colors
local function optimizePerformance()
    -- Loop through all the game objects in the workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Check if the object is a part and not a player character, and if it's not excluded
        if obj:IsA("BasePart") and not isPartOfPlayer(obj) and not shouldExcludePart(obj) then
            -- Simplify appearance by setting everything to smooth plastic while keeping its original color
            obj.Material = Enum.Material.SmoothPlastic
            -- Retain the original color of the object
            obj.CastShadow = false  -- Disables shadows for better FPS
            -- Remove textures or decals to improve FPS
            for _, decal in pairs(obj:GetDescendants()) do
                if decal:IsA("Texture") or decal:IsA("Decal") then
                    decal:Destroy()  -- Remove them to reduce visual clutter
                end
            end
        end
    end
    
    -- Make sure the game runs at a smoother rate by reducing quality for certain effects
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 -- Set to lowest quality level

    -- Attempt to reduce network latency to simulate smoother ping
    game:GetService("NetworkSettings").IncomingReplicationLag = 0
    
    -- Adjusting camera settings to give a smoother feel
    local camera = workspace.CurrentCamera
    camera.FieldOfView = 90  -- Widening the FOV a bit for smoother gameplay

    -- Optional: Enable high refresh rate feeling
    local function simulateHighRefreshRate()
        local refreshRate = 240  -- Simulate 240Hz monitor smoothness
        RunService.RenderStepped:Connect(function(deltaTime)
            local fps = 1 / deltaTime
            if fps < refreshRate then
                RunService.Heartbeat:Wait()  -- Simulate a smoother frame pacing
            end
        end)
    end
    simulateHighRefreshRate()
end

-- Function to reapply the performance boost after respawn or every few seconds
local function maintainPotatoGraphics()
    -- Ensure the optimization stays active all the time
    optimizePerformance()
    optimizeParticles()  -- Optimize particles for better FPS
    
    -- Apply optimizations every 5 seconds to enforce them even if the game resets parts or graphics
    while true do
        optimizePerformance()
        optimizeParticles()
        wait(5)  -- Reapply optimizations every 5 seconds
    end
end

-- Function to reapply the performance boost after respawn
local function onCharacterAdded(character)
    -- Ensure the optimization runs again after respawn
    optimizePerformance()
    optimizeParticles()
    
    -- Keep listening for new parts being added to the workspace and optimize them
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and not isPartOfPlayer(obj) and not shouldExcludePart(obj) then
            -- Simplify newly added parts in real time but keep original color
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            for _, decal in pairs(obj:GetDescendants()) do
                if decal:IsA("Texture") or decal:IsA("Decal") then
                    decal:Destroy()  -- Remove decals to boost FPS
                end
            end
        end
    end)
end

-- Apply the performance boost and hide usernames when the script first runs
optimizePerformance()
optimizeParticles()  -- Optimize particles at the start
hideUsernames()

-- Ensure the optimization remains active after death/respawn
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Keep listening for new characters (respawns) and apply optimizations
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- Start the loop to reapply potato graphics every few seconds
spawn(maintainPotatoGraphics)

-- Notify the user that the script is active and will stay on
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "FPS Booster",
    Text = "Potato graphics and particle optimizations enabled!",
    Duration = 5
})
