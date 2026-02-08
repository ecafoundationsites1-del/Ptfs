local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local TARGET_PART_NAME = "Nose" 

-- 해당 파트가 속한 최상위 모델 이름을 찾는 함수
local function getRootModelName(obj)
    local current = obj
    local lastModel = obj
    
    -- Workspace 바로 아래에 올 때까지 부모를 타고 올라감
    while current and current.Parent ~= workspace and current.Parent ~= nil do
        if current:IsA("Model") then
            lastModel = current
        end
        current = current.Parent
    end
    return lastModel.Name
end

local function createESP(part)
    if part:FindFirstChild("ESPHolder") then return end

    -- 모델 이름 미리 가져오기
    local rootName = getRootModelName(part)

    local holder = Instance.new("Folder")
    holder.Name = "ESPHolder"
    holder.Parent = part

    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 150, 0, 50)
    bgui.Adornee = part
    bgui.AlwaysOnTop = true
    bgui.Parent = holder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 0) -- 눈에 잘 띄는 노란색
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.Parent = bgui

    local att1 = Instance.new("Attachment", part)
    local att0 = Instance.new("Attachment", workspace.Terrain)
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- 추적 선은 빨간색
    beam.Parent = holder

    RunService.RenderStepped:Connect(function()
        if not part or not part.Parent then 
            holder:Destroy() 
            return 
        end
        
        att0.WorldPosition = Camera.CFrame.Position
        local speed = part.AssemblyLinearVelocity.Magnitude
        
        -- 텍스트 업데이트: [모델 이름] 과 속도 표시
        label.Text = string.format("[%s]\n%.1f studs/s", rootName, speed)
    end)
end

-- 스캔 로직
local function scan()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
            createESP(obj)
        end
    end
end

scan()
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == TARGET_PART_NAME then
        createESP(obj)
    end
end)

-- 1번 키로 카메라 추적
local watching = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.One then
        if not watching then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == TARGET_PART_NAME then
                    Camera.CameraSubject = obj
                    watching = true
                    break
                end
            end
        else
            Camera.CameraSubject = localPlayer.Character:FindFirstChild("Humanoid")
            watching = false
        end
    end
end)
