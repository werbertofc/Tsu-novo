local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
-- Salva a posição assim que o script liga
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script Iniciado: Modo Persistente (4x Teleportes + Anti-Morte) ---")

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
-- PARTE 3: LUCKY BLOCK (Lógica Persistente)
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
            
            -- Se a vida for 0, espera renascer antes de tentar qualquer coisa
            if hum.Health <= 0 then 
                task.wait(1)
                continue 
            end

            -- Busca o objeto
            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            if luckyBlock then
                print("🚀 Lucky Block encontrado! Iniciando sequência de 4 teleportes...")
                
                local morreuNoProcesso = false

                -- === ETAPA 1: 4 TELEPORTES (1s de intervalo) ===
                for i = 1, 4 do
                    -- Verifica se morreu ou se o bloco sumiu antes de teleportar
                    if hum.Health <= 0 or not luckyBlock.Parent then
                        morreuNoProcesso = true
                        break -- Quebra o loop dos teleportes para reiniciar
                    end

                    -- Realiza o teleporte
                    if luckyBlock:FindFirstChild("Handle") then
                        hrp.CFrame = luckyBlock.Handle.CFrame
                    else
                        hrp.CFrame = luckyBlock:GetPivot()
                    end
                    
                    print("Teleporte " .. i .. "/4")
                    task.wait(1) -- Espera 1 segundo entre cada teleporte
                end

                -- Se morreu durante os teleportes, pula pro início do While (reinicia tudo)
                if morreuNoProcesso then 
                    print("💀 Morreu durante os teleportes! Reiniciando ciclo...")
                    task.wait(0.5) -- Espera um pouco pro personagem carregar
                    continue 
                end

                -- === ETAPA 2: ESPERA DE 6 SEGUNDOS (Com checagem de morte) ===
                print("⏳ Aguardando 6 segundos (Monitorando vida)...")
                -- Fazemos um loop de 60 x 0.1s para checar a vida a todo momento
                for i = 1, 60 do
                    if hum.Health <= 0 then
                        morreuNoProcesso = true
                        break -- Morreu? Para de esperar e reinicia
                    end
                    if not luckyBlock.Parent then
                        break -- Bloco sumiu (alguém pegou)? Para de esperar
                    end
                    task.wait(0.1)
                end

                -- Se morreu na espera, reinicia
                if morreuNoProcesso then
                    print("💀 Morreu durante a espera! Reiniciando ciclo...")
                    task.wait(0.5)
                    continue
                end

                -- === ETAPA 3: VOLTAR PARA O INÍCIO ===
                -- Só acontece se você sobreviveu a tudo e o bloco sumiu ou o tempo acabou
                print("🏠 Voltando para a base segura...")
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = startPos
                end
                
                task.wait(1)
            end
        end
    end
end)
