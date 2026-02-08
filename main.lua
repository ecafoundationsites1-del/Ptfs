-- 1. 기존 UI 제거 (중복 실행 방지)
local oldGui = game:GetService("CoreGui"):FindFirstChild("PTFS_Fool_ESP") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PTFS_Fool_ESP")
if oldGui then oldGui:Destroy() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 2. UI 생성 (경로를 PlayerGui로 변경하여 안정성 확보)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PTFS_Fool_ESP"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- CoreGui 대신 PlayerGui 사용
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0) -- 위치 약간 위로 조정
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "PTFS Nose 탐지기"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.Size = UDim2.new(1, 0, 0, 290)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 5, 0) -- 스크롤 가능하게 캔버스 크기 키움
ScrollingFrame.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = Vector2.new(0, 5)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.Position = UDim2.new(0, 0, 0, 340)
InfoLabel.Size = UDim2.new(1, 0, 0, 60)
InfoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
InfoLabel.Text = "Nose 파트를 찾는 중..."
InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
InfoLabel.TextSize = 14
InfoLabel.TextWrapped = true

-- 3. 핵심 로직
local TargetPlane = nil
local TargetNose = nil

local function updateList()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- 'Nose' 파트가 있는 모델을 비행기로 인식
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Nose" then
            local model = obj.Parent
            -- 부모가 모델이 아닐 경우 위로 더 올라가서 모델 찾기
            if not model:IsA("Model") then model = model.Parent end
            
            if model:IsA("Model") then
                local btn = Instance.new("TextButton")
                btn.Parent = ScrollingFrame
                btn.Size = UDim2.new(1, -10, 0, 35)
                btn.Text = "✈️ " .. model.Name
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                
                btn.MouseButton1Click:Connect(function()
                    TargetPlane = model
                    TargetNose = obj
                    InfoLabel.Text = "🎯 추적: " .. model.Name
                end)
            end
        end
    end
end

-- 카메라 추적 및 위치 판별
RunService.RenderStepped:Connect(function()
    if TargetNose then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetNose.Position)
        local speed = math.floor(TargetNose.Velocity.Magnitude * 1.94384)
        
        -- 섬 확인 (Raycast)
        local ray = workspace:Raycast(TargetNose.Position, Vector3.new(0, -2000, 0))
        local land = ray and ray.Instance.Name or "바다"
        
        InfoLabel.Text = string.format("기종: %s\n속도: %d kts | 위치: %s", TargetPlane.Name, speed, land)
    end
end)

updateList()
print("UI 실행 완료")
