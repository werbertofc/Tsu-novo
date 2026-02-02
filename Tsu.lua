local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÕES =================
local WAVE_NAME = "Tsunamis" -- O nome exato da onda
local SAFE_DISTANCE = 60 -- Distância para ativar o escudo (aumente se a onda for muito grande)

-- Salva a posição inicial
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script: MODO CAÇA + PROTEÇÃO ANTI-ONDA ---")

-- ================= CRIANDO O BOTÃO =================
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner") 
local UIStroke = Instance.new("UIStroke")

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

ScreenGui.Name = "LuckyBlock_WaveProtect"
ScreenGui.ResetOnSpawn = false 

Button.Name = "ToggleMode"
Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(1, 0, 0) -- COMEÇA VERMELHO
Button.Position = UDim2.new(0.5, -20, 0.85, 0) 
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Text = "HUNT\n(WAVE)"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.GothamBlack
Button.TextSize = 10
Button.Active = true
Button.Draggable = true 

UICorner.Parent = Button
UICorner.CornerRadius = UDim.new(0, 10)
UIStroke.Parent = Button
UIStroke.Thickness = 3
UIStroke.Color = Color3.new(1, 1, 1)

local isFleeing = false 

Button.MouseButton1Click:Connect(function()
    isFleeing = not isFleeing
    if isFleeing then
        Button.BackgroundColor3 = Color3.new(0, 1, 0)
        Button.Text = "SAFE\n(RUN)"
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    else
        Button.BackgroundColor3 = Color3.new(1, 0, 0)
        Button.Text = "HUNT\n(WAVE)"
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

-- =================================================================
-- PARTE 1: APAGAR VIP DOORS
-- =================================================================
local newMap = Workspace:FindFirstChild("NewMapFully")
if newMap then
    local vipDoors = newMap:FindFirstChild("VIPDoors")
    if vipDoors then
        vipDoors:Destroy()
        print("✅ VIPDoors apagadas.")
    end
end

-- =================================================================
-- PARTE 2: AUTO COLLECT
-- =================================================================
task.spawn(function()
    local collectRemote = ReplicatedStorage:WaitForChild("SharedModules")
        :WaitForChild("Network")
        :WaitForChild("Remotes")
        :WaitForChild("Collect Earnings")

    while true do
        for i = 1, 90 do
            collectRemote:FireServer(tostring(i))
        end
        task.wait(1.5)
    end
end)

-- =================================================================
-- PARTE 3: LÓGICA PRINCIPAL (CAÇA + ONDA)
-- =================================================================
task.spawn(function()
    print("🌊 Proteção Anti-Onda Ativada!")
    
    while true do
        RunService.RenderStepped:Wait()
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            if hum.Health <= 0 then 
                hrp.Anchored = false 
                continue 
            end

            -- 1. DETECÇÃO DA ONDA (PRIORIDADE MÁXIMA)
            local liveFolder = Workspace:FindFirstChild("Live")
            local tsunamiObject = liveFolder and liveFolder:FindFirstChild(WAVE_NAME)
            local isWaveDangerous = false

            if tsunamiObject then
                -- Pega a posição da onda
                local wavePos
                if tsunamiObject:IsA("BasePart") then
                    wavePos = tsunamiObject.Position
                else
                    wavePos = tsunamiObject:GetPivot().Position
                end

                -- Calcula distância
                local distWave = (hrp.Position - wavePos).Magnitude

                -- SE A ONDA ESTIVER PERTO: ATIVA MODO ESCUDO
                if distWave < SAFE_DISTANCE then
                    isWaveDangerous = true
                    hrp.Anchored = true -- TRAVA O PERSONAGEM
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    -- Se quiser ver quando ativa, descomente a linha abaixo:
                    -- print("🛡️ ONDA CHEGANDO! ESCUDO ATIVADO!") 
                end
            end

            -- SE A ONDA ESTIVER PERTO, PULA O RESTO DO SCRIPT (NÃO TELEPORTA)
            if isWaveDangerous then
                continue -- Volta pro início do loop e mantém travado
            end

            -- 2. LÓGICA NORMAL DE CAÇA (Só roda se a onda estiver longe)
            -- Garante que está solto se a onda já passou
            hrp.Anchored = false 

            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                
                while luckyBlock.Parent do
                    if hum.Health <= 0 then break end

                    -- Verifica a onda DE NOVO dentro do loop para reação rápida
                    local waveCheck = liveFolder:FindFirstChild(WAVE_NAME)
                    if waveCheck then
                        local wPos = waveCheck:IsA("BasePart") and waveCheck.Position or waveCheck:GetPivot().Position
                        if (hrp.Position - wPos).Magnitude < SAFE_DISTANCE then
                            hrp.Anchored = true -- Trava imediata dentro do loop
                            hrp.Velocity = Vector3.new(0,0,0)
                            RunService.RenderStepped:Wait()
                            continue -- Pula o teleporte
                        end
                    end
                    
                    -- Se a onda não tá perigosa, destrava e segue a vida
                    hrp.Anchored = false

                    local targetPosition = Vector3.new(0,0,0)

                    if isFleeing then
                        targetPosition = startPos.Position
                    else
                        if luckyBlock:FindFirstChild("Handle") then
                            targetPosition = luckyBlock.Handle.Position
                        else
                            targetPosition = luckyBlock:GetPivot().Position
                        end
                        targetPosition = targetPosition + Vector3.new(0, 4, 0) -- Altura
                    end

                    local distance = (hrp.Position - targetPosition).Magnitude

                    if distance > 4 then
                        -- Longe: Teleporta
                        hrp.CFrame = CFrame.new(targetPosition) * hrp.CFrame.Rotation
                        hrp.Velocity = Vector3.new(0,0,0)
                    else
                        -- Perto: Para de teleportar (Zero Tremor)
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.RotVelocity = Vector3.new(0,0,0)
                    end
                    
                    RunService.RenderStepped:Wait()
                end
            end
        end
    end
end)
