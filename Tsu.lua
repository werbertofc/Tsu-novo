local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script Modo IMÃ: Só para quando o item sumir ---")

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
-- PARTE 2: AUTO COLLECT (Loop de 3 segundos)
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
        task.wait(3)
    end
end)

-- =================================================================
-- PARTE 3: LUCKY BLOCK (Lógica de Imã com pausa no 3º TP)
-- =================================================================
task.spawn(function()
    print("🍀 Magnet Lucky Block Iniciado!")
    
    while true do
        task.wait() -- Loop super rápido
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            if hum.Health <= 0 then 
                task.wait(1) 
                continue 
            end

            -- Busca o objeto
            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                print("🚀 Objeto detectado! Grudando nele...")
                
                local teleportCount = 0

                -- === LOOP: SÓ SAI DAQUI QUANDO O OBJETO SUMIR ===
                while luckyBlock.Parent do
                    -- Verifica vida
                    if hum.Health <= 0 then break end

                    -- 1. Teleporta para o objeto
                    if luckyBlock:FindFirstChild("Handle") then
                        hrp.CFrame = luckyBlock.Handle.CFrame
                    else
                        hrp.CFrame = luckyBlock:GetPivot()
                    end
                    
                    teleportCount = teleportCount + 1
                    
                    -- 2. Regra do 3º Teleporte: Esperar 6 segundos
                    if teleportCount == 3 then
                        print("⏳ 3º Teleporte: Aguardando 6s (ou até sumir)...")
                        -- Loop de espera inteligente
                        for k = 1, 60 do -- 60 * 0.1 = 6 segundos
                            if not luckyBlock.Parent then break end -- Se sumiu, para de esperar
                            if hum.Health <= 0 then break end
                            task.wait(0.1)
                        end
                    end

                    -- Delay rápido entre teleportes (para manter grudado)
                    task.wait(0.05) 
                end
                
                -- === OBJETO SUMIU (PEGAMOS!) -> VOLTAR PARA O INÍCIO ===
                print("✅ Objeto coletado/sumiu! Voltando para a base...")
                
                -- Teleporta rápido para o início várias vezes para não bugar
                for j = 1, 15 do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                         LocalPlayer.Character.HumanoidRootPart.CFrame = startPos
                    end
                    task.wait(0.05) -- Muito rápido
                end
                
                print("🏠 Seguro na base. Aguardando próximo...")
            end
        end
    end
end)
