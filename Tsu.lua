local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
-- Salva a posição assim que o script liga (Base Segura)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script Atualizado: Teleporte 4x Ida e 4x Volta ---")

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
-- PARTE 3: LUCKY BLOCK (4x Ida -> 6s Espera -> 4x Volta)
-- =================================================================
task.spawn(function()
    print("🍀 Monitoramento Iniciado!")
    
    while true do
        task.wait(0.1) -- Checagem rápida
        
        local char = LocalPlayer.Character
        -- Checa se o player está vivo e tem corpo
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            -- Se a vida for 0, espera renascer
            if hum.Health <= 0 then 
                task.wait(1)
                continue 
            end

            -- Busca o objeto
            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                print("🚀 Lucky Block encontrado! Iniciando sequência de IDA...")
                
                local morreuNoProcesso = false

                -- === ETAPA 1: 4 TELEPORTES PARA O OBJETO ===
                for i = 1, 4 do
                    if hum.Health <= 0 or not luckyBlock.Parent then
                        morreuNoProcesso = true
                        break 
                    end

                    if luckyBlock:FindFirstChild("Handle") then
                        hrp.CFrame = luckyBlock.Handle.CFrame
                    else
                        hrp.CFrame = luckyBlock:GetPivot()
                    end
                    
                    print("➡️ Indo: " .. i .. "/4")
                    task.wait(1)
                end

                if morreuNoProcesso then 
                    print("💀 Morreu na ida! Reiniciando...")
                    task.wait(0.5)
                    continue 
                end

                -- === ETAPA 2: ESPERA DE 6 SEGUNDOS ===
                print("⏳ Aguardando 6 segundos...")
                for i = 1, 60 do
                    if hum.Health <= 0 then
                        morreuNoProcesso = true
                        break 
                    end
                    if not luckyBlock.Parent then
                        break -- Se sumiu (pegou), já pode tentar voltar
                    end
                    task.wait(0.1)
                end

                if morreuNoProcesso then
                    print("💀 Morreu na espera! Reiniciando...")
                    task.wait(0.5)
                    continue
                end

                -- === ETAPA 3: 4 TELEPORTES DE VOLTA PARA O INÍCIO ===
                print("🏠 Iniciando sequência de VOLTA...")
                
                for j = 1, 4 do
                    -- Checa se ainda está vivo para não bugar o retorno
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                         LocalPlayer.Character.HumanoidRootPart.CFrame = startPos
                    end
                    
                    print("⬅️ Voltando: " .. j .. "/4")
                    task.wait(1)
                end
                
                -- Pausa curta antes de procurar o próximo, para garantir que estabilizou
                task.wait(1)
            end
        end
    end
end)
