local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 중복 실행 방지
if _G.PTFS_ESP_LOADED then _G.PTFS_ESP_LOADED = false task.wait(0.1) end
_G.PTFS_ESP_LOADED = true

-- [기존 UI 변수 연결] 
-- 실행 시 이미 생성된 UI가 있다면 해당 ScrollingFrame과 InfoLabel을 연결하세요.
local ScreenGui = game:GetService("CoreGui"):FindFirstChild("PTFS_Fool_ESP") or Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = ScreenGui:FindFirstChild("MainFrame")
local ScrollingFrame = MainFrame and MainFrame:FindFirstChild("ScrollingFrame")
local InfoLabel = MainFrame and MainFrame:FindFirstChild("InfoLabel")

local TargetPlane = nil
local TargetNose = nil

-- 'Nose' 파트를 가진 비행기 목록 갱신
local function updateList()
    if not ScrollingFrame then return end
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    -- 전수 조사: 'Nose'라는 이름을 가진 파트가 있는 모델 찾기
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local nose = obj:FindFirstChild("Nose", true) -- 하위 모든 폴더/파트 중 'Nose' 검색
            
            if nose and nose:IsA("BasePart") then
                local btn = Instance.new("TextButton")
                btn.Parent = ScrollingFrame
                btn.Size = UDim2.new(1, -10, 0, 35)
                btn.Text = "✈️ " .. obj.Name
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.SourceSansBold
                btn.TextSize = 16

                btn.MouseButton1Click:Connect(function()
                    TargetPlane = obj
                    TargetNose = nose
                    if InfoLabel then 
                        InfoLabel.Text = "🎯 추적 대상: " .. obj.Name 
                        InfoLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                    end
                end)
            end
        end
    end
end

-- 섬 이름 판별 함수
local function getIslandName(pos)
    local rayparams = RaycastParams.new()
    rayparams.FilterType = Enum.RaycastFilterType.Blacklist
    rayparams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(pos, Vector3.new(0, -2000, 0), rayparams)
    if result and result.Instance then
        -- 부모의 이름이 섬 이름인 경우가 많음 (PTFS 구조에 따라 수정 가능)
        return result.Instance.Parent.Name or result.Instance.Name
    end
    return "바다 (Ocean)"
end

-- 실시간 카메라 고정 및 정보 업데이트
RunService.RenderStepped:Connect(function()
    if not _G.PTFS_ESP_LOADED then return end
    
    if TargetPlane and TargetNose then
        -- 1. 카메라가 비행기의 'Nose' 파트를 조준
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetNose.Position)
        
        -- 2. 상세 정보 표시
        local speed = math.floor(TargetNose.Velocity.Magnitude * 1.94384)
        local island = getIslandName(TargetNose.Position)
        
        if InfoLabel then
            InfoLabel.Text = string.format("기종: %s\n속도: %d kts | 위치: %s", TargetPlane.Name, speed, island)
        end
    end
end)

-- 실행
updateList()
-- 10초마다 자동으로 새로운 비행기 목록 갱신
task.spawn(function()
    while _G.PTFS_ESP_LOADED do
        task.wait(10)
        updateList()
    end
end)
