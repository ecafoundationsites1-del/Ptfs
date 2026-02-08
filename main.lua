local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 스크립트 중복 실행 방지
if _G.PTFS_ESP_LOADED then return end
_G.PTFS_ESP_LOADED = true

-- [UI 생성]
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local Title = Instance.new("TextLabel")
local InfoLabel = Instance.new("TextLabel")

ScreenGui.Name = "PTFS_Fool_ESP"
ScreenGui.Parent = game:GetService("CoreGui") -- 실행기 호환

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true -- 드래그 가능

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "PTFS 기종 선택 (만우절)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 50)

ScrollingFrame.Parent = MainFrame
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.Size = UDim2.new(1, 0, 0, 300)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 5

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

InfoLabel.Parent = MainFrame
InfoLabel.Position = UDim2.new(0, 0, 0, 340)
InfoLabel.Size = UDim2.new(1, 0, 0, 60)
InfoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InfoLabel.Text = "추적할 비행기를 선택하세요"
InfoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
InfoLabel.TextWrapped = true

-- [로직]
local TargetPlane = nil

-- 육지(섬) 이름 판별 함수
local function getIslandName(position)
    local ray = Ray.new(position, Vector3.new(0, -5000, 0))
    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {workspace.CurrentCamera})
    
    if hit then
        return hit.Name -- 파트의 이름을 섬 이름으로 반환
    end
    return "공해 (바다)"
end

-- 비행기 목록 갱신 함수
local function updateList()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- PTFS에서 비행기는 보통 특정 폴더나 모델 구조를 가짐
    -- 여기서는 엔진이나 좌석이 있는 모델을 비행기로 간주
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and (obj:FindFirstChild("Engine") or obj:FindFirstChild("Seat")) then
            local btn = Instance.new("TextButton")
            btn.Parent = ScrollingFrame
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Text = obj.Name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)

            btn.MouseButton1Click:Connect(function()
                TargetPlane = obj
                InfoLabel.Text = "현재 추적 중: " .. obj.Name
            end)
        end
    end
end

-- 초기 목록 불러오기 및 주기적 갱신
updateList()
task.spawn(function()
    while true do
        task.wait(5)
        updateList()
    end
end)

-- 화면 이동 (RenderStepped)
RunService.RenderStepped:Connect(function()
    if TargetPlane and TargetPlane:FindFirstChildWhichIsA("BasePart") then
        local root = TargetPlane:FindFirstChildWhichIsA("BasePart")
        
        -- 1. 카메라만 그쪽으로 보게 함 (몸은 고정)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, root.Position)
        
        -- 2. 섬 정보 및 속도 업데이트
        local speed = math.floor(root.Velocity.Magnitude * 1.94384)
        local island = getIslandName(root.Position)
        InfoLabel.Text = string.format("추적: %s\n속도: %d kts | 위치: %s", TargetPlane.Name, speed, island)
    elseif TargetPlane then
        TargetPlane = nil
        InfoLabel.Text = "대상 비행기가 사라졌습니다."
    end
end)

print("PTFS ESP UI가 실행되었습니다.")
