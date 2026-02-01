local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DA ÁREA SEGURA =================
-- Tenta achar o SpawnLocation automático. Se não achar, vai para a posição 0, 50, 0
local SpawnLocation = Workspace:FindFirstChild("SpawnLocation") 
local SAFE_ZONE_CFRAME = SpawnLocation and SpawnLocation.CFrame or CFrame.new(0, 50, 0)
-- ===============================================================

print("--- Script Iniciado: VIP Doors + Auto Collect + Lucky Block ---")

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
-- PARTE 3: LUCKY BLOCK TELEPORT (Monitoramento constante)
-- =================================================================
task.spawn(function()
    print("🍀 Caçador de Lucky Block Ativado!")
    
    local perseguiu = false -- Variável para saber se estavamos perseguindo o bloco

    while true do
        task.wait() -- Roda super rápido para não perder o item
        
        -- Verifica se o personagem existe
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            -- Caminho da pasta: Workspace > Live > Friends > OG Lucky Block
            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                -- CENÁRIO A: O Lucky Block ESTÁ na pasta (Teleportar para ele)
                perseguiu = true
                
                -- Se o bloco tiver um Handle (parte física), teleporta pra ele
                if luckyBlock:FindFirstChild("Handle") then
                    hrp.CFrame = luckyBlock.Handle.CFrame
                elseif luckyBlock:IsA("BasePart") then
                     hrp.CFrame = luckyBlock.CFrame
                else
                    -- Caso seja um modelo sem Handle, tenta ir para a posição dele
                    hrp.CFrame = luckyBlock:GetPivot()
                end
                
            elseif perseguiu then
                -- CENÁRIO B: O Lucky Block SUMIU da pasta e estavamos perseguindo (Pegamos ele!)
                -- Teleportar de volta para a Base/Spawn
                hrp.CFrame = SAFE_ZONE_CFRAME + Vector3.new(0, 5, 0) -- Um pouco acima para não bugar
                print("🏠 Item pego! Voltando para a base segura.")
                perseguiu = false -- Reseta o estado
                task.wait(1) -- Espera um pouco para não teleportar loucamente
            end
        end
    end
end)
