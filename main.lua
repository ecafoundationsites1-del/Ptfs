local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- [설정]
local TARGET_NAME = "Nose"
local HUD_COLOR = Color3.fromRGB(0, 255, 100) 

local activeESPs = {}

-- 맵에 있는 섬(장소)들의 위치를 파악하는 함수
local function getNearestIsland(position)
    local nearestIsland = "Unknown Ocean"
    local minDistance = 2000 -- 최대 감지 거리 (이보다 멀면 그냥 바다)

    -- 보통 맵의 섬 이름은 Folder나 특정 모델 안에 텍스트/파트 형태로 있습니다.
    -- 여기서는 예시 사진에 나온 이름들을 기준으로 근처의 큰 지형이나 마커를 찾습니다.
    for _, obj in ipairs(workspace:GetDescendants()) do
        -- 섬 이름이 담긴 오브젝트(주로 Folder 내의 Part나 Model)를 찾음
        if obj:IsA("BasePart") and (obj.Parent.Name == "Islands" or obj:FindFirstChild("TouchInterest")) then
            local dist = (position - obj.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestIsland = obj.Name
            end
        end
    end
    return nearestIsland
end

local function getVehicleModel(part)
	local current = part
	local lastModel = part
	while current and current.Parent ~= workspace and current.Parent ~= nil do
		if current:IsA("Model") then lastModel = current end
		current = current.Parent
	end
	return lastModel
end

local function createESP(part)
	local vehicle = getVehicleModel(part)
	if activeESPs[vehicle] then return end
	activeESPs[vehicle] = true

	local holder = Instance.new("Folder")
	holder.Name = "IslandESP"
	holder.Parent = part

	local bgui = Instance.new("BillboardGui")
	bgui.Size = UDim2.new(0, 200, 0, 60)
	bgui.AlwaysOnTop = true
	bgui.Adornee = part
	bgui.Parent = holder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1 
	label.TextStrokeTransparency = 1 -- 검은 테두리 제거
	label.TextColor3 = HUD_COLOR
	label.TextSize = 14
	label.Font = Enum.Font.RobotoMono
	label.Parent = bgui

	local att1 = Instance.new("Attachment", part)
	local att0 = Instance.new("Attachment", workspace.Terrain)
	
	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Width0 = 0.01
	beam.Width1 = 0.01
	beam.Color = ColorSequence.new(HUD_COLOR)
	beam.Transparency = NumberSequence.new(0.6)
	beam.Parent = holder

	RunService.RenderStepped:Connect(function()
		if not part or not part.Parent or not vehicle.Parent then
			activeESPs[vehicle] = nil
			holder:Destroy()
			return
		end

		att0.WorldPosition = Camera.CFrame.Position
		local speed = part.AssemblyLinearVelocity.Magnitude
		
		-- 섬 위치 파악 (매 프레임 하면 무거우니 0.5초마다 하거나 단순 거리 체크)
		local location = getNearestIsland(part.Position)
		
		-- 출력 형식: [기체이름] 위치: 섬이름 / 속도
		label.Text = string.format("[%s]\nLOC: %s\nSPD: %d", vehicle.Name, location, math.floor(speed))
	end)
end

-- 스캔 로직 (생략 - 이전과 동일)
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and obj.Name == TARGET_NAME then createESP(obj) end
end
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Name == TARGET_NAME then task.wait(0.2) createESP(obj) end
end)
