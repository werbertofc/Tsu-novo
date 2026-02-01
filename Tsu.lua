local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
-- Salva o local seguro assim que você executa o script
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva com sucesso!")
print("--- Script Iniciado: VIP Doors + Auto Collect + Teleporte Triplo ---")

-- =================================================================
-- PARTE 1: APAGAR VIP DOORS (Apenas uma vez)
-- =================================================================
local newMap = Workspace:FindFirstChild("NewMapFully")
if newMap then
    local vipDoors = newMap:FindFirstChild("VIPDoors")
    if vipDoors then
        vipDoors:Destroy()
        print("✅ Sucesso: Pasta 'VIPDoors' apagada.")
    end
end

-- =================================================================
-- PARTE 2: AUTO COLLECT (Loop de 3 segundos - Slots 1 ao 90)
-- =================================================================
task.spawn(function()
    local collectRemote = ReplicatedStorage:WaitForChild("SharedModules")
        :WaitForChild("Network")
        :WaitForChild("Remotes")
        :WaitForChild("Collect Earnings")

    print("💰 Auto-Collect Ativado!")
    while true do
        for i = 1, 90 do
            collectRemote:FireServer(tostring(i))
        end
        task.wait(3)
    end
end)

-- =================================================================
-- PARTE 3: LUCKY BLOCK (Teleporte 3x -> Espera 6s -> Volta)
-- =================================================================
task.spawn(function()
    print("🍀 Monitoramento de Lucky Block Iniciado!")
    
    while true do
        task.wait(0.2) -- Loop rápido de verificação
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            
            -- Caminho: Workspace > Live > Friends > OG Lucky Block
            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                print("🚀 Lucky Block detectado! Forçando teleporte...")

                -- === CORREÇÃO: TELEPORTAR 3 VEZES PARA NÃO VOLTAR ===
                for i = 1, 3 do
                    -- Verifica se o bloco ainda existe antes de tentar ir
                    if luckyBlock.Parent then
                        if luckyBlock:FindFirstChild("Handle") then
                            hrp.CFrame = luckyBlock.Handle.CFrame
                        else
                            hrp.CFrame = luckyBlock:GetPivot()
                        end
                    end
                    -- Espera minúscula para o servidor registrar a posição
                    task.wait(0.1) 
                end
                
                print("⏳ Aguardando 6 segundos no objeto...")
                -- Espera 6 segundos no local para garantir a coleta
                task.wait(6)
                
                -- Volta para o início
                print("🏠 Voltando para o início...")
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = startPos
                end
                
                -- Espera 1 segundo para estabilizar antes de procurar de novo
                task.wait(1)
            end
        end
    end
end)
