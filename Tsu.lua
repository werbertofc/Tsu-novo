local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService") -- Serviço para velocidade máxima

local LocalPlayer = Players.LocalPlayer

-- ================= CONFIGURAÇÃO DO INÍCIO AUTOMÁTICO =================
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local startPos = rootPart.CFrame 

print("📍 Posição inicial salva!")
print("--- Script: MODO BRAINROT (Velocidade Infinita) ---")

-- ================= CRIANDO O BOTÃO =================
local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner") 
local UIStroke = Instance.new("UIStroke")

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

ScreenGui.Name = "LuckyBlock_Brainrot"
ScreenGui.ResetOnSpawn = false 

Button.Name = "ToggleMode"
Button.Parent = ScreenGui
Button.BackgroundColor3 = Color3.new(1, 0, 0) -- COMEÇA VERMELHO
Button.Position = UDim2.new(0.5, -20, 0.85, 0) 
Button.Size = UDim2.new(0, 50, 0, 50) -- Aumentei um pouco para 50x50
Button.Text = "HUNT\n(MAX)"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.GothamBlack -- Fonte mais grossa
Button.TextSize = 12
Button.Active = true
Button.Draggable = true 

UICorner.Parent = Button
UICorner.CornerRadius = UDim.new(0, 10)
UIStroke.Parent = Button
UIStroke.Thickness = 3
UIStroke.Color = Color3.new(1, 1, 1)

-- VARIÁVEL DE ESTADO
local isFleeing = false 

-- FUNÇÃO DO CLIQUE
Button.MouseButton1Click:Connect(function()
    isFleeing = not isFleeing
    
    if isFleeing then
        Button.BackgroundColor3 = Color3.new(0, 1, 0)
        Button.Text = "SAFE\n(MAX)"
    else
        Button.BackgroundColor3 = Color3.new(1, 0, 0)
        Button.Text = "HUNT\n(MAX)"
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
        -- Tenta coletar o mais rápido possível sem crashar o jogo
        for i = 1, 90 do
            collectRemote:FireServer(tostring(i))
        end
        task.wait(1.5) -- Reduzi um pouco o tempo do dinheiro tbm
    end
end)

-- =================================================================
-- PARTE 3: LUCKY BLOCK (Velocidade da Luz)
-- =================================================================
task.spawn(function()
    print("⚡ Brainrot Teleport Iniciado!")
    
    while true do
        -- RenderStepped:Wait() roda a cada frame da tela (muito mais rápido que task.wait)
        RunService.RenderStepped:Wait()
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char.Humanoid
            
            if hum.Health <= 0 then continue end

            local liveFolder = Workspace:FindFirstChild("Live")
            local friendsFolder = liveFolder and liveFolder:FindFirstChild("Friends")
            local luckyBlock = friendsFolder and friendsFolder:FindFirstChild("OG Lucky Block")

            -- Se o Lucky Block existe...
            if luckyBlock then
                -- LOOP INSANO: Roda a cada frame sem pausa
                while luckyBlock.Parent do
                    if hum.Health <= 0 then break end

                    if isFleeing then
                        -- >>> MODO VERDE (SAFE): TRAVA NO INÍCIO <<<
                        hrp.CFrame = startPos
                        hrp.Velocity = Vector3.new(0,0,0) -- Zera a velocidade para não ser empurrado
                    else
                        -- >>> MODO VERMELHO (HUNT): TRAVA NO OBJETO <<<
                        if luckyBlock:FindFirstChild("Handle") then
                            hrp.CFrame = luckyBlock.Handle.CFrame
                        else
                            hrp.CFrame = luckyBlock:GetPivot()
                        end
                        hrp.Velocity = Vector3.new(0,0,0) -- Anula física para grudar mais
                    end
                    
                    -- NÃO TEM WAIT AQUI! 
                    -- Usamos RenderStepped no topo do loop externo, mas dentro do while
                    -- precisamos de um delay mínimo para não congelar o PC.
                    RunService.RenderStepped:Wait() 
                end
            end
        end
    end
end)
