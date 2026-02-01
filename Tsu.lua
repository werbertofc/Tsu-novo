local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script: 100% Manual (Sem Reset Automático) ---")

-- ================= CRIANDO O BOTÃO NA TELA =================
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner") 
local UIStroke = Instance.new("UIStroke")

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

ScreenGui.Name = "LuckyBlockControl_Manual"
ScreenGui.ResetOnSpawn = false 

Button.Name = "ToggleMode"
Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(1, 0, 0) -- COMEÇA VERMELHO
Button.Position = UDim2.new(0.5, -20, 0.85, 0) 
Button.Size = UDim2.new(0, 40, 0, 40) -- 40x40
Button.Text = "HUNT"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 10
Button.Active = true
Button.Draggable = true 

UICorner.Parent = Button
UICorner.CornerRadius = UDim.new(0, 8)
UIStroke.Parent = Button
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(1, 1, 1)

-- VARIÁVEL DE ESTADO (Fica fora do loop para não resetar nunca)
local isFleeing = false -- Começa no modo caçar, mas mantém o que você escolher

-- FUNÇÃO DO CLIQUE
Button.MouseButton1Click:Connect(function()
    isFleeing = not isFleeing -- Troca o modo
    
    if isFleeing then
        -- MODO FUGIR (Verde)
        Button.BackgroundColor3 = Color3.new(0, 1, 0)
        Button.Text = "SAFE"
    else
        -- MODO CAÇAR (Vermelho)
        Button.BackgroundColor3 = Color3.new(1, 0, 0)
        Button.Text = "HUNT"
    end
end)

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
-- PARTE 2: AUTO COLLECT
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
-- PARTE 3: LUCKY BLOCK (Lógica 100% Manual)
-- =================================================================
task.spawn(function()
    print("🍀 Monitoramento Iniciado!")
    
    while true do
        task.wait(0.1)
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            if hum.Health <= 0 then 
                task.wait(1) 
                continue 
            end

            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            -- O Script só age se o Lucky Block EXISTIR
            if luckyBlock then
                
                -- Enquanto ele existir na pasta...
                while luckyBlock.Parent do
                    if hum.Health <= 0 then break end

                    if isFleeing then
                        -- >>> MODO VERDE: FUGIR <<< (Ativo enquanto objeto existe)
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                             LocalPlayer.Character.HumanoidRootPart.CFrame = startPos
                        end
                        task.wait(0.1) -- Fuga rápida
                    else
                        -- >>> MODO VERMELHO: CAÇAR <<< (Ativo enquanto objeto existe)
                        if luckyBlock:FindFirstChild("Handle") then
                            hrp.CFrame = luckyBlock.Handle.CFrame
                        else
                            hrp.CFrame = luckyBlock:GetPivot()
                        end
                        -- Intervalo de 1 segundo para caça
                        task.wait(1)
                    end
                end
                
                -- Se saiu do While, é porque o objeto sumiu.
                -- O script para de fazer qualquer coisa e volta a esperar o próximo.
                print("✅ Objeto sumiu da pasta. Aguardando o próximo...")
            end
        end
    end
end)
