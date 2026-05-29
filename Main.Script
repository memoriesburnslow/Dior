getgenv().Config = {
    ['Settings'] = {
        ['Knock Check'] = true,
        ['Visible Check'] = true
    },
    ['Keybinds'] = {
        ['CamLock'] = {
            ['Key'] = 'Q',
            ['Mode'] = 'Toggle'
        },
        ['ESP'] = {
            ['Key'] = 'P',
            ['Mode'] = 'Toggle'
        }
    },
    ['ESP'] = {
        ['Enabled'] = false, 
        ['Text Size'] = 16,
        ['Color'] = Color3.fromRGB(255, 255, 255)
    },
    ['Silent Aim'] = {
        ['Enabled'] = true, 
        ['Hit Part'] = 'Closest Part',
        ['Prediction'] = {
            ['Enabled'] = true, 
            ['X'] = 0.135,
            ['Y'] = 0.135,
            ['Z'] = 0.135
        },
        ['Anti Curve'] = {
            ['Enabled'] = true,
            ['Strength'] = 1.0,
            ['LinearMode'] = true
        },
        ['FOV'] = { 
            ['X'] = 150, 
            ['Y'] = 150, 
            ['Z'] = 500, 
            ['Visible'] = true 
        }
    },
    ['Camera Lock'] = {
        ['Enabled'] = false, 
        ['Hit Part'] = 'Closest Part',
        ['Smoothness'] = 0.09, 
        ['Prediction'] = {
            ['Enabled'] = true,
            ['X'] = 0.135,
            ['Y'] = 0.135,
            ['Z'] = 0.135
        },
        ['FOV'] = { 
            ['X'] = 120, 
            ['Y'] = 120, 
            ['Z'] = 400, 
            ['Visible'] = true 
        }
    },
    ['Speed Walk'] = {
        ['Enabled'] = true,
        ['Key'] = 'V',
        ['Mode'] = 'Toggle',
        ['Speed'] = 180
    },
    ['Panic Key'] = {
        ['Enabled'] = true,
        ['Key'] = 'X'
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CamLockTarget = nil
local IsCamLocking = false
local IsESPOpen = false
local IsSpeedWalking = false
local IsPanicActive = false
local ESP_Drawings = {}

if Config['Camera Lock'].Enabled and Config.Keybinds.CamLock.Mode == 'Always' then
    IsCamLocking = true
end
if Config.ESP.Enabled and Config.Keybinds.ESP.Mode == 'Always' then
    IsESPOpen = true
end

local function IsKnocked(player)
    if not Config.Settings['Knock Check'] then return false end
    if player.Character and player.Character:FindFirstChild("BodyEffects") then
        local KO = player.Character.BodyEffects:FindFirstChild("K.O")
        local Knocked = player.Character.BodyEffects:FindFirstChild("Knocked")
        if (KO and KO.Value == true) or (Knocked and Knocked.Value == true) then
            return true
        end
    end
    return false
end

local function IsVisible(part, position)
    if not Config.Settings['Visible Check'] then return true end
    if not part then return false end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local targetPos = position or part.Position
    local direction = (targetPos - origin).Unit * (targetPos - origin).Magnitude
    local result = Workspace:Raycast(origin, direction, params)
    
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestPixelPosition(character)
    local closestPosition = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    local partsToCheck = {
        "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso",
        "Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand",
        "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }
    
    for _, partName in pairs(partsToCheck) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local size = part.Size
            local offsets = {
                Vector3.new(0, 0, 0),
                Vector3.new(0, -size.Y/2, 0), 
                Vector3.new(0, size.Y/2, 0),
                Vector3.new(-size.X/2, 0, 0),
                Vector3.new(size.X/2, 0, 0),
                Vector3.new(0, 0, -size.Z/2),
                Vector3.new(0, 0, size.Z/2),
                Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
                Vector3.new(size.X/2, -size.Y/2, size.Z/2)
            }
            
            for _, offset in pairs(offsets) do
                local pixelWorldPos = (part.CFrame * CFrame.new(offset)).Position
                local pos, onScreen = Camera:WorldToViewportPoint(pixelWorldPos)
                
                if onScreen then
                    local dist = (mousePos - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < shortestDist then
                        if IsVisible(part, pixelWorldPos) then
                            shortestDist = dist
                            closestPosition = pixelWorldPos
                        end
                    end
                end
            end
        end
    end
    
    if not closestPosition and character:FindFirstChild("HumanoidRootPart") then
        closestPosition = character.HumanoidRootPart.Position
    end
    
    return closestPosition
end

local function GetClosestPlayer(mode)
    local closestPlayer = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 and not IsKnocked(player) then
                local rootPart = player.Character.HumanoidRootPart
                local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local fovConfig = Config[mode].FOV
                    
                    local diffX = (rootPos.X - mousePos.X) / fovConfig.X
                    local diffY = (rootPos.Y - mousePos.Y) / fovConfig.Y
                    local inEllipse = (diffX * diffX) + (diffY * diffY) <= 1
                    
                    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist3D = localRoot and (localRoot.Position - rootPart.Position).Magnitude or 0
                    local withinZ = dist3D <= fovConfig.Z
                    
                    if inEllipse and withinZ then
                        local dist2D = (mousePos - Vector2.new(rootPos.X, rootPos.Y)).Magnitude
                        if dist2D < shortestDist then
                            shortestDist = dist2D
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function ApplyAntiCurve(targetPos, currentPos, configMode)
    local antiCurve = Config[configMode]['Anti Curve']
    if antiCurve and antiCurve.Enabled then
        local dir = (targetPos - currentPos)
        if antiCurve.LinearMode then
            return currentPos + dir.Unit * (dir.Magnitude * antiCurve.Strength)
        end
    end
    return targetPos
end

local function PredictPosition(targetPos, velocity, isSilentAim)
    local vel = velocity or Vector3.new(0,0,0)
    
    if isSilentAim and Config['Silent Aim'].Prediction.Enabled then
        local pX = Config['Silent Aim'].Prediction.X
        local pY = Config['Silent Aim'].Prediction.Y
        local pZ = Config['Silent Aim'].Prediction.Z
        local predicted = targetPos + Vector3.new(vel.X * pX, vel.Y * pY, vel.Z * pZ)
        return ApplyAntiCurve(predicted, Camera.CFrame.Position, 'Silent Aim')
    elseif not isSilentAim and Config['Camera Lock'].Prediction.Enabled then
        local pX = Config['Camera Lock'].Prediction.X
        local pY = Config['Camera Lock'].Prediction.Y
        local pZ = Config['Camera Lock'].Prediction.Z
        return targetPos + Vector3.new(vel.X * pX, vel.Y * pY, vel.Z * pZ)
    end
    
    return targetPos
end

local Watermark = Drawing.new("Text")
Watermark.Visible = false
Watermark.Center = false
Watermark.Outline = true
Watermark.Font = 2
Watermark.Size = 18
Watermark.Color = Color3.fromRGB(255, 85, 85) 
Watermark.Position = Vector2.new(15, 15)
Watermark.Text = "script made by @memories"

local SilentAimCircle = Drawing.new("Circle")
SilentAimCircle.Visible = false
SilentAimCircle.Color = Color3.fromRGB(255, 255, 255)
SilentAimCircle.Thickness = 1
SilentAimCircle.NumSides = 64
SilentAimCircle.Filled = false

local CamLockCircle = Drawing.new("Circle")
CamLockCircle.Visible = false
CamLockCircle.Color = Color3.fromRGB(85, 170, 255)
CamLockCircle.Thickness = 1
CamLockCircle.NumSides = 64
CamLockCircle.Filled = false

local function CreateESP(player)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = Config.ESP['Text Size']
    text.Color = Config.ESP.Color
    ESP_Drawings[player] = text
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end

Players.PlayerAdded:Connect(function(player) CreateESP(player) end)
Players.PlayerRemoving:Connect(function(player)
    if ESP_Drawings[player] then
        ESP_Drawings[player]:Remove()
        ESP_Drawings[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if IsPanicActive then
        Watermark.Visible = false
        SilentAimCircle.Visible = false
        CamLockCircle.Visible = false
        for _, text in pairs(ESP_Drawings) do
            text.Visible = false
        end
        return
    end

    local espActive = Config.ESP.Enabled and IsESPOpen
    Watermark.Visible = espActive 
    local mouseLocation = UserInputService:GetMouseLocation()
    
    if Config['Silent Aim'].Enabled and Config['Silent Aim'].FOV.Visible then
        SilentAimCircle.Visible = true
        SilentAimCircle.Position = mouseLocation
        SilentAimCircle.Radius = Config['Silent Aim'].FOV.X
    else
        SilentAimCircle.Visible = false
    end
    
    if Config['Camera Lock'].Enabled and Config['Camera Lock'].FOV.Visible then
        CamLockCircle.Visible = true
        CamLockCircle.Position = mouseLocation
        CamLockCircle.Radius = Config['Camera Lock'].FOV.X
    else
        CamLockCircle.Visible = false
    end
    
    for player, text in pairs(ESP_Drawings) do
        if espActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character.HumanoidRootPart
            local bottomPos, onScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
            
            if onScreen then
                text.Position = Vector2.new(bottomPos.X, bottomPos.Y)
                text.Text = player.DisplayName
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode[Config['Panic Key'].Key] and Config['Panic Key'].Enabled then
        IsPanicActive = not IsPanicActive
        if IsPanicActive then
            CamLockTarget = nil
        end
        return
    end

    if IsPanicActive then return end

    if input.KeyCode == Enum.KeyCode[Config.Keybinds.CamLock.Key] and Config['Camera Lock'].Enabled then
        if Config.Keybinds.CamLock.Mode == 'Toggle' then
            IsCamLocking = not IsCamLocking
            if IsCamLocking then 
                local targetPlr = GetClosestPlayer('Camera Lock')
                CamLockTarget = targetPlr and targetPlr.Character or nil
            else 
                CamLockTarget = nil 
            end
        elseif Config.Keybinds.CamLock.Mode == 'Hold' then
            IsCamLocking = true
            local targetPlr = GetClosestPlayer('Camera Lock')
            CamLockTarget = targetPlr and targetPlr.Character or nil
        end
    end
    
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.ESP.Key] and Config.ESP.Enabled then
        if Config.Keybinds.ESP.Mode == 'Toggle' then
            IsESPOpen = not IsESPOpen
        elseif Config.Keybinds.ESP.Mode == 'Hold' then
            IsESPOpen = true
        end
    end

    if input.KeyCode == Enum.KeyCode[Config['Speed Walk'].Key] and Config['Speed Walk'].Enabled then
        if Config['Speed Walk'].Mode == 'Toggle' then
            IsSpeedWalking = not IsSpeedWalking
        elseif Config['Speed Walk'].Mode == 'Hold' then
            IsSpeedWalking = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed or IsPanicActive then return end
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.CamLock.Key] and Config['Camera Lock'].Enabled and Config.Keybinds.CamLock.Mode == 'Hold' then
        IsCamLocking = false
        CamLockTarget = nil
    end
    if input.KeyCode == Enum.KeyCode[Config.Keybinds.ESP.Key] and Config.ESP.Enabled and Config.Keybinds.ESP.Mode == 'Hold' then
        IsESPOpen = false
    end
    if input.KeyCode == Enum.KeyCode[Config['Speed Walk'].Key] and Config['Speed Walk'].Enabled and Config['Speed Walk'].Mode == 'Hold' then
        IsSpeedWalking = false
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if IsPanicActive then 
        CamLockTarget = nil
        return 
    end

    if Config['Camera Lock'].Enabled and IsCamLocking then
        if Config.Keybinds.CamLock.Mode == 'Always' or not CamLockTarget then
            local targetPlr = GetClosestPlayer('Camera Lock')
            CamLockTarget = targetPlr and targetPlr.Character or nil
        end
        
        if CamLockTarget and CamLockTarget:FindFirstChild("Humanoid") and CamLockTarget.Humanoid.Health > 0 then
            local targetPlayerInstance = Players:GetPlayerFromCharacter(CamLockTarget)
            if targetPlayerInstance and IsKnocked(targetPlayerInstance) then
                CamLockTarget = nil
                return
            end
            
            local hitPartSetting = Config['Camera Lock']['Hit Part']
            local targetPixelPos = nil
            
            if hitPartSetting == 'Closest Part' then
                targetPixelPos = GetClosestPixelPosition(CamLockTarget)
            else
                local part = CamLockTarget:FindFirstChild(hitPartSetting)
                if part and IsVisible(part, part.Position) then
                    targetPixelPos = part.Position
                end
            end
            
            if targetPixelPos then
                local rootPart = CamLockTarget:FindFirstChild("HumanoidRootPart")
                local velocity = rootPart and rootPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                
                local predPos = PredictPosition(targetPixelPos, velocity, false)
                local smooth = Config['Camera Lock'].Smoothness
                local lerpFactor = math.clamp(smooth * (dt * 60), 0, 1)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predPos), lerpFactor)
            end
        else
            CamLockTarget = nil
        end
    end

    if Config['Speed Walk'].Enabled and IsSpeedWalking then
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (Config['Speed Walk'].Speed / 10) * dt)
        end
    end
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self:IsA("Mouse") and Config['Silent Aim'].Enabled and not IsPanicActive then
        if key == "Hit" or key == "Target" then
            local targetPlr = GetClosestPlayer('Silent Aim')
            if targetPlr and targetPlr.Character then
                local hitPartSetting = Config['Silent Aim']['Hit Part']
                local targetPixelPos = nil
                local chosenPart = targetPlr.Character:FindFirstChild("HumanoidRootPart")
                
                if hitPartSetting == 'Closest Part' then
                    targetPixelPos = GetClosestPixelPosition(targetPlr.Character)
                else
                    local part = targetPlr.Character:FindFirstChild(hitPartSetting)
                    if part and IsVisible(part, part.Position) then
                        targetPixelPos = part.Position
                        chosenPart = part
                    end
                end
                
                if targetPixelPos then
                    if key == "Hit" then
                        local velocity = targetPlr.Character.HumanoidRootPart and targetPlr.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0,0,0)
                        local predPos = PredictPosition(targetPixelPos, velocity, true)
                        return CFrame.new(predPos)
                    elseif key == "Target" then
                        return chosenPart
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end)
