local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 스크립트 중복 실행 방지
if _G.PTFS_ESP_LOADED then _G.PTFS_ESP_LOADED = false task.wait(0.1) end
_G.PTFS_ESP_LOADED = true

-- [UI 설정 및 생성 생략 - 기존 UI 코드 유지하되 아래 로직만 교체하세요]
-- (편의를 위해 핵심 로직 부분만 명확히 다시 짜드립니다)

local TargetPlane = nil

-- 비행기 판별 및 목록 업데이트 로직 강화
local function updateList()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- 전수 조사: 모델 중 좌석(Seat/VehicleSeat)이 있는 것을 비행기로 간주
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj:FindFirstChildOfClass("VehicleSeat") or obj:FindFirstChild("Engine")) then
            -- 너무 멀리 있거나 본인 기체 제외하려면 조건 추가 가능
            local btn = Instance.new("TextButton")
            btn.Parent = ScrollingFrame
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.Text = "[" .. (obj.PrimaryPart and obj.Name or "Unknown") .. "]"
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSansBold

            btn.MouseButton1Click:Connect(function()
                TargetPlane = obj
                InfoLabel.Text = "추적 시작: " .. obj.Name
                InfoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            end)
        end
    end
end

-- 섬 이름 판별 (Raycast 방식 최적화)
local function getIslandName(pos)
    local rayparams = RaycastParams.new()
    rayparams.FilterType = Enum.RaycastFilterType.Blacklist
    rayparams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(pos, Vector3.new(0, -1000, 0), rayparams)
    if result and result.Instance then
        -- PTFS 맵 구조에 따라 result.Instance.Parent.Name 등을 써야 할 수도 있음
        return result.Instance.Name 
    end
    return "바다 위"
end

-- 실시간 추적 및 화면 고정
RunService.RenderStepped:Connect(function()
    if not _G.PTFS_ESP_LOADED then return end
    
    if TargetPlane and (TargetPlane.PrimaryPart or TargetPlane:FindFirstChildWhichIsA("BasePart")) then
        local root = TargetPlane.PrimaryPart or TargetPlane:FindFirstChildWhichIsA("BasePart")
        
        -- 카메라 시선 고정 (핵심: 화면만 돌아감)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, root.Position)
        
        -- 정보 갱신
        local speed = math.floor(root.Velocity.Magnitude * 1.94384)
        local island = getIslandName(root.Position)
        InfoLabel.Text = string.format("기종: %s\n속도: %d kts | 위치: %s", TargetPlane.Name, speed, island)
    end
end)

-- 초기 실행
updateList()

