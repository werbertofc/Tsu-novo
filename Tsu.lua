local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("--- Script Iniciado ---")

-- =================================================================
-- PARTE 1: APAGAR APENAS AS VIP DOORS
-- =================================================================
local newMap = Workspace:FindFirstChild("NewMapFully")

if newMap then
    local vipDoors = newMap:FindFirstChild("VIPDoors")
    if vipDoors then
        vipDoors:Destroy()
        print("✅ Sucesso: Pasta 'VIPDoors' apagada.")
    else
        warn("⚠️ Aviso: 'VIPDoors' não encontrada em NewMapFully.")
    end
else
    warn("❌ Erro: A pasta 'NewMapFully' não foi encontrada.")
end

-- =================================================================
-- PARTE 2: COLETAR DINHEIRO (90 SLOTS)
-- =================================================================
-- Usamos task.spawn para que o loop do dinheiro não trave o resto do jogo
task.spawn(function()
    -- Localiza o Remote apenas uma vez para otimizar
    local collectRemote = ReplicatedStorage:WaitForChild("SharedModules")
        :WaitForChild("Network")
        :WaitForChild("Remotes")
        :WaitForChild("Collect Earnings")

    print("💰 Auto-Collect ativado para 90 slots!")

    while true do
        -- Loop de 1 até 90 (assumindo que os slots são numerados de 1 a 90)
        for i = 1, 90 do
            -- O código original usava "1" (string), então convertemos o número para string
            local args = {tostring(i)} 
            collectRemote:FireServer(unpack(args))
        end
        
        -- Espera 1 segundo antes de coletar tudo novamente
        task.wait(1)
    end
end)
