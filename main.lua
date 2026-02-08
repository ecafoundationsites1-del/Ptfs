local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- 설정 변수
local MAX_DISTANCE = 500 -- 이 거리보다 멀면 ESP 안 보임
local TEXT_SIZE = 14     -- 글자 크기 축소

local function createESP(part)
    if part:FindFirstChild("ESPHolder") then return end

    local holder = Instance.new("Folder")
    holder.Name = "ESPHolder"
    holder.Parent = part

    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 150, 0, 40)
    bgui.Adornee = part
    bgui.AlwaysOnTop = true
    bgui.LightInfluence = 0
    bgui.Parent = holder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.5 -- 반투명 배경 추가 (가독성)
    label.TextColor3 = Color3.new(1, 1, 1) -- 흰색 글자로 변경
    label.TextSize = TEXT_SIZE
    label.Font = Enum.Font.RobotoMono -- 깔끔한 폰트
    label.Parent = bgui

    local attachment1 = Instance.new("Attachment", part)
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = workspace.Terrain

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.05 -- 선 얇게
    beam.Width1 = 0.05
    beam.Color = ColorSequence.new(Color3.new(0, 1, 1)) -- 하늘색 선
    beam.Transparency = NumberSequence.new(0.5)
    beam.Parent = holder

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent then
            connection:Disconnect()
            holder:Destroy()
            return
        end

        local distance = (part.Position - Camera.CFrame.Position).Magnitude
        
        -- 너무 가깝거나 너무 멀면 숨겨서 겹침 방지
        if distance > MAX_DISTANCE or distance < 2 then
            bgui.Enabled = false
            beam.Enabled = false
        else
            bgui.Enabled = true
            beam.Enabled = true
            local velocity = part.AssemblyLinearVelocity.Magnitude
            label.Text = string.format("[%s]\nSPD: %.1f", part.Name, velocity)
            attachment0.WorldPosition = Camera.CFrame.Position
        end
    end)
end

-- "Nose" 포함 파트 스캔 (중복 방지 로직 포함)
local function scan()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(obj.Name, "Nose") then
            -- 부모가 달라도 이름이 같으면 너무 많으므로, 주요 파트만 선택하거나 처리
            createESP(obj)
        end
    end
end

scan()

-- 카메라 전환 (1번 키)
local watching = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.One then
        if not watching then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name, "Nose") then
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

