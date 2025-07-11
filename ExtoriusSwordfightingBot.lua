--[[

EXTORIUS SWORD FIGHTING AI V4

CREDITS: Noxu - Lead Dev of Extorius, Creator

Optimal performance, no effort needed.

]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Swordfighting AI v4 REMAKE | Original by Noxu, remake by script_A.",
	Icon = 0,
	LoadingTitle = "Swordfighting AI V4 REMAKE",
	LoadingSubtitle = "by Script_A",
	ShowText = "Rayfield",
	Theme = "Default",

	ToggleUIKeybind = "K",

	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false,

	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil,
		FileName = "stuff"
	},

	Discord = {
		Enabled = false,
		Invite = "noinvitelink",
		RememberJoins = true
	},

	KeySystem = false,
	KeySettings = {
		Title = "Untitled",
		Subtitle = "Key System",
		Note = "No method of obtaining the key is provided",
		FileName = "Key",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"Hello"}
	}
})

local Tab = Window:CreateTab("Configurations", 534533607)

local players = game.Players
local player = players.LocalPlayer

local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")

local enabled = true

local autoMove = Tab:CreateToggle({
	Name = "Auto-Move",
	CurrentValue = true,
	Flag = "Auto Movement",
	Callback = function(Value)
		enabled = not enabled
	end,
})

local aimUsesOffset = false

local aimUseOffset = Tab:CreateToggle({
	Name = "Aim uses Offset (Broken)",
	CurrentValue = false,
	Flag = "Aim use Offset",
	Callback = function(Value)
		aimUsesOffset = not aimUsesOffset
	end,
})

local autoEquip = true

local autoEq = Tab:CreateToggle({
	Name = "Auto-Equip",
	CurrentValue = true,
	Flag = "Auto-Equip",
	Callback = function(Value)
		autoEquip = not autoEquip
	end,
})

repeat
	wait()
	humanoid = char:FindFirstChildOfClass("Humanoid")
	root = char:FindFirstChild("HumanoidRootPart")
until humanoid and root

local runService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local strafe = 1
local strafeTime = 0.05
local lastStrafe = 0

local strafeOffset = Tab:CreateSlider({
	Name = "Strafe Amount",
	Range = {0, 10},
	Increment = 1,
	Suffix = "BotStrafe",
	CurrentValue = 1,
	Flag = "StrafeAmount", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		strafe = Value
	end,
})

local strafeTime = Tab:CreateSlider({
	Name = "Strafe Time",
	Range = {0, 1},
	Increment = .1,
	Suffix = "Time",
	CurrentValue = 0.05,
	Flag = "StrafeTime", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		strafeTime = Value
	end,
})

local turnStrafeOffset = 1

local turnStrafe = Tab:CreateSlider({
	Name = "Turn Strafe",
	Range = {0, 10},
	Increment = 1,
	Suffix = "StrafeTurnAmount",
	CurrentValue = 1,
	Flag = "Turning Strafe Amount", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		turnStrafeOffset = Value
	end,
})

local aimOffset = 4

local aimOff = Tab:CreateSlider({
	Name = "Aim Offset",
	Range = {-10, 10},
	Increment = 1,
	Suffix = "Offset",
	CurrentValue = 1,
	Flag = "Aim Offset", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		aimOffset = Value
	end,
})

local lungeDistance = 20

local lungeDistanceSlider = Tab:CreateSlider({
	Name = "Distance",
	Range = {0, 100},
	Increment = 1,
	Suffix = "Distance",
	CurrentValue = 20,
	Flag = "Lunge Distance", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Value)
		lungeDistance = Value
	end,
})

local detectionDist = math.huge

local function getnearesttarget()
	local target, detD = nil, detectionDist
	for i, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= char then
			local h = v:FindFirstChildOfClass("Humanoid")
			local r = v:FindFirstChild("HumanoidRootPart")
			if h and r and h.Health > 0 then
				local d = (r.Position - root.Position).Magnitude
				if d < detD then
					detD = d
					target = v
				end
			end
		end
	end
	return target
end

local function findBest(tool, part, offset)
	if not tool or not tool:FindFirstChild("Handle") or not part then return end

	local handle = tool.Handle
	local r = tool:FindFirstAncestorOfClass("Model"):FindFirstChild("HumanoidRootPart")
	if not r then return end

	local swordTipPos = (handle.CFrame * CFrame.new(0, 0, -4)).Position
	local origin = swordTipPos
	local offsets = {
		Vector3.new(0, 0, 0),
		Vector3.new(0.15, 0, 0),
		Vector3.new(0.3, 0, 0),
		Vector3.new(-0.15, 0, 0),
		Vector3.new(-0.3, 0, 0)
	}

	local bestPos, bestDist = nil, math.huge
	local bestIndex = nil
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {tool.Parent}

	local rayResults = {}

	for i, offset in ipairs(offsets) do
		local targetOffsetPos = part.Position + offset
		local direction = (targetOffsetPos - origin).Unit
		local castDir = direction * 100
		local result = workspace:Raycast(origin, castDir, rayParams)

		local visualLength = result and (result.Position - origin).Magnitude or 100
		local midpoint = origin + direction * visualLength / 2

		table.insert(rayResults, {
			result = result,
			direction = direction,
			visualLength = visualLength,
			midpoint = midpoint,
			index = i
		})

		if result then
			local dist = (result.Position - origin).Magnitude
			if dist < bestDist then
				bestDist = dist
				bestPos = result.Position
				bestIndex = i
			end
		end
	end

	--[[for i, ray in ipairs(rayResults) do
		local rayPart = Instance.new("Part")
		rayPart.Anchored = true
		rayPart.CanCollide = false
		rayPart.Size = Vector3.new(0.1, 0.1, ray.visualLength)
		rayPart.CFrame = CFrame.new(ray.midpoint, ray.midpoint + ray.direction)
		rayPart.Material = Enum.Material.Neon
		rayPart.Name = "DebugRay"
		rayPart.Parent = workspace

		if ray.result then
			if i == bestIndex then
				rayPart.Color = Color3.fromRGB(0, 255, 0)
			else
				rayPart.Color = Color3.fromRGB(255, 0, 0)
			end
		else
			rayPart.Color = Color3.fromRGB(100, 100, 100)
		end

		game:GetService("Debris"):AddItem(rayPart, 0.1)
	end]] --this is a debug

	if not aimUsesOffset then
		if bestPos then
			local flatDir = (bestPos - swordTipPos).Unit * Vector3.new(1, 0, 1)
			--bodyGyro.CFrame = CFrame.new(root.Position, root.Position + flatDir) * CFrame.Angles(0,math.rad(offset or 0),0)
			return CFrame.new(root.Position, root.Position + flatDir) * CFrame.Angles(0,math.rad(offset or 0),0)
		else
			local fallbackDir = (part.Position - swordTipPos).Unit * Vector3.new(1, 0, 1)
			--bodyGyro.CFrame = CFrame.new(root.Position, root.Position + fallbackDir) * CFrame.Angles(0,math.rad(offset or 0),0)
			return CFrame.new(root.Position, root.Position + fallbackDir) * CFrame.Angles(0,math.rad(offset or 0),0)
		end
	else
		local preDir = ((r.CFrame * CFrame.new(aimOffset,0,0)).Position - root.Position).Unit * Vector3.new(1,0,1)
		return CFrame.new(root.Position, root.Position + preDir) * CFrame.Angles(0,math.rad(offset or 0),0)
	end
end

local function getClosestBodyPart(char)
	local closestPart = nil
	local closestDist = math.huge
	for i, v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			local dist = (root.Position - v.Position).Magnitude
			if dist < closestDist then
				closestPart = v
				closestDist = dist
			end
		end
	end
	return closestPart
end

delay(0,function()
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(4,4,4) * 10000000
	bodyGyro.P = 100000
	bodyGyro.D = 1
	bodyGyro.Parent = RS

	local jStInd = 0
	local jsDir = "LeftRight"

	local dirChosen = false

	local timer1 = 0
	local timer2 = 0
	local timer3 = 0
	local timer4 = 0
	local lowHealthLunge = 0

	local random1N = 80000

	runService.RenderStepped:Connect(function()
		if enabled then
			local target = getnearesttarget()
			if not target then bodyGyro.Parent = RS return end
			local h, r = target:FindFirstChildOfClass("Humanoid"), target:FindFirstChild("HumanoidRootPart")
			if not h and not r then bodyGyro.Parent = RS return end
			local targetPart = getClosestBodyPart(target)
			bodyGyro.Parent = root
			humanoid.AutoRotate = false
			local dir = ((r.CFrame * CFrame.new(2,0,0).Position) - root.Position).Unit * Vector3.new(1,0,1)
			local dist = (r.Position - root.Position).Magnitude
			local tool = char:FindFirstChildOfClass("Tool")
			local enemyTool = target:FindFirstChildOfClass("Tool")

			local bestCFrame = findBest(tool, targetPart, turnStrafeOffset + (turnStrafeOffset * math.random(1,random1N)) / 5000)
			local c360 = findBest(tool, targetPart, 360)

			--local varedRandom = math.random(1,2)
			local strafeVect3 = Vector3.new(math.random(-strafe,strafe),0,math.random(-strafe,strafe)) * 10

			if math.random(1,20) > 3 then
				if r.Velocity.Magnitude > 0.1 and h.MoveDirection.Magnitude > 0.1 then
					if dist < 27 + math.random() then
						if tick() - lastStrafe > math.random(1,100) / 550 then
							lastStrafe = tick()
							humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + (r.Position - root.Position).Unit:Cross(Vector3.new(0,1,0)) + (strafeVect3/25))
						end
					else
						if tick() - lastStrafe > strafeTime then
							lastStrafe = tick()
							humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + (r.Position - root.Position).Unit:Cross(Vector3.new(0,1,0)) + (strafeVect3/10))
						end
					end
				else
					if tick() - lastStrafe > strafeTime then
						lastStrafe = tick()
						humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + (r.Position - root.Position).Unit:Cross(Vector3.new(0,1,0)) + (strafeVect3/100))
					end
				end
				if bestCFrame then
					random1N = 80000
					bodyGyro.CFrame = bestCFrame
				else
					random1N = 80000
					bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
				end
			else
				if math.random(1,2) == 1 then
					if tick() - timer1 > 0.5 then
						timer1 = tick()
						humanoid:MoveTo(root.Position + root.CFrame.LookVector * -5 + strafeVect3)
						if bestCFrame then
							random1N = 5000000
							bodyGyro.CFrame = bestCFrame
						else
							random1N = 80000
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
						end
					end
				else
					if tick() - timer1 > 0.5 then
						timer1 = tick()
						humanoid:MoveTo(root.Position + root.CFrame.LookVector * -5 + (strafeVect3/10))
						if c360 then
							random1N = 80000
							bodyGyro.CFrame = c360
						else
							random1N = 80000
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(360),0)
						end
					end
				end
			end

			if target:FindFirstChildOfClass("ForceField") or humanoid.Health / humanoid.MaxHealth < 0.68 then
				if dist < 15 then
					if target:FindFirstChildOfClass("ForceField") then
						humanoid:MoveTo(r.Position - (r.Position - root.Position).Unit * 15)
					else
						if math.random(1,25) then
							if tick() - lowHealthLunge > 0.7 then
								lowHealthLunge = tick()
								humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + (r.Position - root.Position).Unit:Cross(Vector3.new(0,1,0)))
							end
						end
					end
				end
			end

			if math.random(1,45) == 1 or r.Position.Y - 0.5 > root.Position.Y or (math.random(1,15) == 1 and dist <= 10 + (r.Velocity.Magnitude / 3)) then
				humanoid.Jump = true
			end

			if (dist <= 15.5 and r.Position.Y - 0.5 > root.Position.Y) and r.Velocity > 0.1 then
				humanoid:MoveTo(root.Position + root.CFrame.LookVector * -1)
			end

			if enemyTool and r.CFrame.LookVector.Unit:Dot((root.Position - r.Position).Unit) > 0.6 then
				enemyTool.Activated:Connect(function()
					if dist < 18 then
						if tick() - timer2 > math.random(1,15) / 100 then
							timer2 = tick()
							humanoid:MoveTo(root.Position + root.CFrame.LookVector * -4)
							humanoid.Jump = true
						end
						humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + (r.Position - root.Position).Unit:Cross(Vector3.new(0,1,0)) + (strafeVect3/25))
						tool:Activate()
					end
				end)
			end

			if dist < lungeDistance or math.random(1,20) == 1 then
				if tool then
					tool:Activate()
				end
			end
		else
			bodyGyro.Parent = RS
			humanoid.AutoRotate = true
		end
	end)
end)

local function respawn()
	char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")

	humanoid.Died:Connect(function()
		game.Players.LocalPlayer.CharacterAdded:Wait()
		respawn()
	end)
end

player.CharacterAdded:Connect(function()
	respawn()
end)

--UIS.InputBegan:Connect(function(key)
--	if key.KeyCode == Enum.KeyCode.R then
--		local focused = UIS:GetFocusedTextBox()
--		if not focused then
--			enabled = not enabled
--		end
--	end
--end)
