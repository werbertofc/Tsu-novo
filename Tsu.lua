local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script Inteligente: Teleporte por Proximidade (Raio 1m) ---")

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
-- PARTE 3: LUCKY BLOCK (Lógica Inteligente de Distância)
-- =================================================================
task.spawn(function()
    print("🍀 Monitoramento Inteligente Iniciado!")
    
    while true do
        task.wait(0.1) -- Verificação rápida
        
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
                print("🚀 Lucky Block detectado! Iniciando teleporte inteligente...")
                
                local morreuNoProcesso = false
                
                -- Define a posição alvo
                local targetCFrame
                if luckyBlock:FindFirstChild("Handle") then
                    targetCFrame = luckyBlock.Handle.CFrame
                else
                    targetCFrame = luckyBlock:GetPivot()
                end

                -- === ETAPA 1: IR ATÉ O BLOCO (Checa Distância) ===
                -- 3.5 studs é aproximadamente 1 metro no Roblox
                while (hrp.Position - targetCFrame.Position).Magnitude > 3.5 do
                    
                    -- Se o bloco sumiu ou player morreu, para
                    if hum.Health <= 0 or not luckyBlock.Parent then
                        morreuNoProcesso = true
                        break 
                    end
                    
                    -- Teleporta
                    hrp.CFrame = targetCFrame
                    
                    -- Atualiza a posição alvo caso o bloco se mova
                    if luckyBlock:FindFirstChild("Handle") then
                        targetCFrame = luckyBlock.Handle.CFrame
                    else
                        targetCFrame = luckyBlock:GetPivot()
                    end

                    task.wait() -- Espera o mínimo possível (frame a frame)
                end

                if morreuNoProcesso then 
                    task.wait(0.5)
                    continue 
                end
                
                print("✅ Chegamos perto (Raio < 1m). Parando teleporte.")

                -- === ETAPA 2: ESPERA DE 6 SEGUNDOS ===
                print("⏳ Aguardando 6 segundos...")
                for i = 1, 60 do
                    if hum.Health <= 0 then
                        morreuNoProcesso = true
                        break 
                    end
                    if not luckyBlock.Parent then
                        break -- Pegou o item
                    end
                    task.wait(0.1)
                end

                if morreuNoProcesso then
                    task.wait(0.5)
                    continue
                end

                -- === ETAPA 3: VOLTAR PARA O INÍCIO (Checa Distância) ===
                print("🏠 Voltando para a base segura...")
                
                -- Loop até estar perto do início (Raio de 1 metro)
                while (hrp.Position - startPos.Position).Magnitude > 3.5 do
                    if hum.Health <= 0 then break end
                    
                    hrp.CFrame = startPos
                    task.wait() -- Frame a frame
                end
                
                print("✅ De volta à segurança.")
                task.wait(1)
            end
        end
    end
end)
