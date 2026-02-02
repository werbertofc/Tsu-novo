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
print("--- Script: MODO CONGELADO (Zero Tremor) ---")

-- ================= CRIANDO O BOTÃO =================
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner") 
local UIStroke = Instance.new("UIStroke")

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

ScreenGui.Name = "LuckyBlock_Frozen"
ScreenGui.ResetOnSpawn = false 

Button.Name = "ToggleMode"
Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(1, 0, 0) -- COMEÇA VERMELHO
Button.Position = UDim2.new(0.5, -20, 0.85, 0) 
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Text = "HUNT\n(FROZEN)"
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

-- VARIÁVEL DE ESTADO
local isFleeing = false 

Button.MouseButton1Click:Connect(function()
    isFleeing = not isFleeing
    if isFleeing then
        Button.BackgroundColor3 = Color3.new(0, 1, 0)
        Button.Text = "SAFE\n(FROZEN)"
        -- Garante que descongela ao mudar de modo para poder mover
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    else
        Button.BackgroundColor3 = Color3.new(1, 0, 0)
        Button.Text = "HUNT\n(FROZEN)"
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
-- PARTE 3: LUCKY BLOCK (Lógica de Congelamento)
-- =================================================================
task.spawn(function()
    print("❄️ Modo Congelamento Iniciado!")
    
    while true do
        RunService.RenderStepped:Wait()
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            if hum.Health <= 0 then 
                hrp.Anchored = false -- Se morrer, solta o corpo
                continue 
            end

            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            -- Se o Lucky Block existe...
            if luckyBlock then
                
                -- Enquanto ele existir na pasta...
                while luckyBlock.Parent do
                    if hum.Health <= 0 then 
                        hrp.Anchored = false 
                        break 
                    end

                    local targetCFrame = nil

                    if isFleeing then
                        -- >>> MODO SAFE: Base <<<
                        targetCFrame = startPos
                    else
                        -- >>> MODO HUNT: Objeto (COM OFFSET PARA CIMA) <<<
                        local blockPos
                        if luckyBlock:FindFirstChild("Handle") then
                            blockPos = luckyBlock.Handle.Position
                        else
                            blockPos = luckyBlock:GetPivot().Position
                        end
                        -- Fica 3.5 studs ACIMA do bloco para não bugar colisão
                        -- Mantém a rotação da SUA câmera (hrp.Rotation)
                        targetCFrame = CFrame.new(blockPos + Vector3.new(0, 3.5, 0)) * hrp.CFrame.Rotation
                    end

                    -- === LÓGICA DE CONGELAMENTO ===
                    local dist = (hrp.Position - targetCFrame.Position).Magnitude

                    if dist > 4 then
                        -- Se está longe: DESCONGELA e voa até lá
                        hrp.Anchored = false
                        hrp.CFrame = targetCFrame
                    else
                        -- Se está perto: CONGELA (Vira estátua)
                        -- Isso para 100% do tremor e permite coletar
                        hrp.CFrame = targetCFrame
                        hrp.Anchored = true 
                        hrp.Velocity = Vector3.new(0,0,0)
                    end
                    
                    RunService.RenderStepped:Wait()
                end
                
                -- QUANDO SAI DO LOOP (OBJETO SUMIU):
                -- Solta o boneco imediatamente!
                hrp.Anchored = false
                
            else
                -- Se não tem Lucky Block, garante que não está preso
                if hrp.Anchored == true then
                    hrp.Anchored = false
                end
            end
        end
    end
end)
