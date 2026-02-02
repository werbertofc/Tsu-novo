local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script: MODO COLETA (Sem Cancelar o 'E') ---")

-- ================= CRIANDO O BOTÃO =================
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner") 
local UIStroke = Instance.new("UIStroke")

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

ScreenGui.Name = "LuckyBlock_Fix"
ScreenGui.ResetOnSpawn = false 

Button.Name = "ToggleMode"
Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(1, 0, 0) -- COMEÇA VERMELHO
Button.Position = UDim2.new(0.5, -20, 0.85, 0) 
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Text = "HUNT\n(AUTO)"
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
        -- Garante que o personagem esteja solto
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    else
        Button.BackgroundColor3 = Color3.new(1, 0, 0)
        Button.Text = "HUNT\n(AUTO)"
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
-- PARTE 3: LUCKY BLOCK (Lógica de Coleta Otimizada)
-- =================================================================
task.spawn(function()
    print("🛠️ Modo Coleta Otimizada Ativado!")
    
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

            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                
                while luckyBlock.Parent do
                    if hum.Health <= 0 then break end

                    local targetPosition = Vector3.new(0,0,0)
                    local shouldInteract = false

                    if isFleeing then
                        -- MODO FUGIR: Vai para a base
                        targetPosition = startPos.Position
                    else
                        -- MODO CAÇAR: Vai para o Lucky Block
                        shouldInteract = true
                        if luckyBlock:FindFirstChild("Handle") then
                            targetPosition = luckyBlock.Handle.Position
                        else
                            targetPosition = luckyBlock:GetPivot().Position
                        end
                    end

                    -- Distância até o alvo
                    local distance = (hrp.Position - targetPosition).Magnitude

                    -- === LÓGICA DE MOVIMENTO INTELIGENTE ===
                    if distance > 3 then
                        -- ESTÁ LONGE? Teleporta usando CFrame (Rápido)
                        -- Mantém a rotação da câmera para não girar a tela
                        hrp.CFrame = CFrame.new(targetPosition) * hrp.CFrame.Rotation
                        hrp.Velocity = Vector3.new(0,0,0)
                    else
                        -- ESTÁ PERTO? (Zona de Coleta)
                        -- NÃO ATUALIZA O CFRAME! (Isso permite segurar o botão sem cancelar)
                        -- Apenas zera a velocidade para não ser empurrado pela água
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.RotVelocity = Vector3.new(0,0,0)
                        
                        -- Tenta interagir automaticamente (Auto-E)
                        if shouldInteract then
                            -- Procura por ProximityPrompt dentro do Lucky Block
                            for _, prompt in pairs(luckyBlock:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    -- Tenta disparar o prompt instantaneamente
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                    
                    RunService.RenderStepped:Wait()
                end
            end
        end
    end
end)
