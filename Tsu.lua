local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("--- Script Iniciado ---")

-- PARTE 1: APAGAR VIP DOORS
local newMap = Workspace:FindFirstChild("NewMapFully")
if newMap then
    local vipDoors = newMap:FindFirstChild("VIPDoors")
    if vipDoors then
        vipDoors:Destroy()
        print("✅ VIPDoors apagadas.")
    end
end

-- PARTE 2: COLETAR DINHEIRO (Tudo de uma vez a cada 3s)
task.spawn(function()
    local collectRemote = ReplicatedStorage:WaitForChild("SharedModules")
        :WaitForChild("Network")
        :WaitForChild("Remotes")
        :WaitForChild("Collect Earnings")

    while true do
        -- Esse loop roda tão rápido que envia os 90 pedidos quase no mesmo milissegundo
        for i = 1, 90 do
            collectRemote:FireServer(tostring(i))
        end
        
        -- Depois de disparar tudo, ele descansa 3 segundos
        task.wait(3)
    end
end)
