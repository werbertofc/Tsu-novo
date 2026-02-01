local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
-- Pega a posição atual do jogador assim que o script executa
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame -- Salva a posição exata de onde você ativou o script

print("📍 Posição inicial salva! É para cá que voltaremos.")
-- =====================================================================

print("--- Script Iniciado: VIP Doors + Auto Collect + Teleporte com Delay ---")

-- =================================================================
-- PARTE 1: APAGAR VIP DOORS (Executa uma vez)
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
-- PARTE 2: AUTO COLLECT (Loop de 3 segundos)
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
-- PARTE 3: LUCKY BLOCK (Teleporte -> Espera 6s -> Volta)
-- =================================================================
task.spawn(function()
    print("🍀 Monitoramento de Lucky Block Iniciado!")
    
    while true do
        task.wait(0.2) -- Verifica rapidamente, mas sem travar o jogo
        
        -- Atualiza o personagem caso você tenha morrido/resetado
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            
            -- Verifica o caminho: Workspace > Live > Friends > OG Lucky Block
            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                print("🚀 Lucky Block encontrado! Teleportando...")
                
                -- 1. Teleporta para o Lucky Block
                if luckyBlock:FindFirstChild("Handle") then
                    hrp.CFrame = luckyBlock.Handle.CFrame
                else
                    hrp.CFrame = luckyBlock:GetPivot()
                end
                
                -- 2. Espera 6 segundos LÁ no objeto (como pedido)
                task.wait(6)
                
                -- 3. Teleporta de volta para o início salvo
                print("🏠 Voltando para o início...")
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = startPos
                end
                
                -- 4. Espera um pouquinho antes de checar de novo para não bugar
                task.wait(1)
            end
        end
    end
end)
