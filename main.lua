local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer

-- ESP 생성 함수
local function createESP(part)
    -- 이미 ESP가 있다면 생성 안 함
    if part:FindFirstChild("ESPHolder") then return end

    local holder = Instance.new("Folder")
    holder.Name = "ESPHolder"
    holder.Parent = part

    -- BillboardGui (텍스트 표시용)
    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.Adornee = part
    bgui.AlwaysOnTop = true
    bgui.StudsOffset = Vector3.new(0, 2, 0)
    bgui.Parent = holder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 0, 0) -- 빨간색
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = bgui

    -- Beam (선 연결용 - 카메라와 연결)
    local attachment1 = Instance.new("Attachment", part)
    local attachment0 = Instance.new("Attachment") 
    attachment0.Parent = workspace.Terrain -- 카메라 위치 대용

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Color = ColorSequence.new(Color3.new(1, 1, 0)) -- 노란색 선
    beam.FaceCamera = true
    beam.Parent = holder

    -- 실시간 업데이트
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent then
            connection:Disconnect()
            holder:Destroy()
            return
        end

        -- 속도 계산 (Velocity)
        local velocity = part.AssemblyLinearVelocity.Magnitude
        label.Text = string.format("Name: %s\nSpeed: %.2f studs/s", part.Name, velocity)

        -- 선을 카메라 위치로 업데이트
        attachment0.WorldPosition = Camera.CFrame.Position
    end)
end

-- "Nose"가 포함된 파트 찾기 및 감시
local function scanNose()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(obj.Name, "Nose") then
            createESP(obj)
        end
    end
end

-- 초기 스캔 및 주기적 체크
scanNose()
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and string.find(obj.Name, "Nose") then
        createESP(obj)
    end
end)

--- [카메라 시점 전환 기능] ---
-- 숫자 1번 키를 누르면 가장 가까운 Nose 파트를 관전합니다.
local UserInputService = game:GetService("UserInputService")
local watching = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.One then
        if not watching then
            -- 가장 가까운 Nose 찾기
            local closest = nil
            local dist = math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name, "Nose") then
                    local d = (obj.Position - Camera.CFrame.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = obj
                    end
                end
            end
            
            if closest then
                Camera.CameraSubject = closest
                watching = true
            end
        else
            -- 다시 내 캐릭터로 카메라 복구
            Camera.CameraSubject = localPlayer.Character:FindFirstChild("Humanoid")
            watching = false
        end
    end
end)

