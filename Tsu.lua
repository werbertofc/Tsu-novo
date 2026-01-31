local Workspace = game:GetService("Workspace")

print("--- Iniciando Script de Limpeza ---")

-- --- PARTE 1: Limpeza dentro de 'NewMapFully' ---
local newMap = Workspace:FindFirstChild("NewMapFully")

if newMap then
    -- 1.1 Apagar InvisWalls
    local invisWalls = newMap:FindFirstChild("InvisWalls")
    if invisWalls then
        invisWalls:Destroy()
        print("✅ Sucesso: Pasta 'InvisWalls' apagada.")
    else
        warn("⚠️ Aviso: 'InvisWalls' não encontrada em NewMapFully.")
    end

    -- 1.2 Apagar VIPDoors (NOVO)
    local vipDoors = newMap:FindFirstChild("VIPDoors")
    if vipDoors then
        vipDoors:Destroy()
        print("✅ Sucesso: Pasta 'VIPDoors' apagada.")
    else
        warn("⚠️ Aviso: 'VIPDoors' não encontrada em NewMapFully.")
    end
else
    warn("❌ Erro: A pasta principal 'NewMapFully' não existe no Workspace.")
end

-- --- PARTE 2: Limpeza dentro de 'Live' ---
local liveFolder = Workspace:FindFirstChild("Live")

if liveFolder then
    -- 2.1 Apagar Tsunamis
    local tsunamis = liveFolder:FindFirstChild("Tsunamis")
    if tsunamis then
        tsunamis:Destroy()
        print("✅ Sucesso: Objeto 'Tsunamis' apagado.")
    else
        warn("⚠️ Aviso: 'Tsunamis' não encontrado dentro de Live.")
    end
else
    warn("❌ Erro: A pasta principal 'Live' não existe no Workspace.")
end

print("--- Script de Limpeza Finalizado ---")
