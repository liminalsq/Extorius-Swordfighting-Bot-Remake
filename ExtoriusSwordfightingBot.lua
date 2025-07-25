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
	Name = "Aim uses Offset",
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

local toolName = "sword" or "foil" -- As "sword" because the script finds the tool by whatever matches this within it's name. Foil is from Fencing.

local label1 = Tab:CreateLabel("In case games have two tools, this is here for you to define your tool by name.") -- I don't know why this is defined lmao.

local toolnameinput = Tab:CreateInput({
	Name = "Tool Name",
	PlaceholderText = "ClassicSword",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		toolName = Text
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

local wiggling = false
local wiggleAmtDistBased = false
local wiggleDistance = 13
local wiggleSpeed = 45
local wiggleAmount = 25

local strafeOffset = Tab:CreateSlider({
	Name = "Strafe Amount",
	Range = {0, 10},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = strafe,
	Flag = "StrafeAmount", 
	Callback = function(Value)
		strafe = Value
	end,
})

local strafeTiming = Tab:CreateSlider({
	Name = "Strafe Time",
	Range = {0, 1},
	Increment = .01,
	Suffix = "Milliseconds",
	CurrentValue = strafeTime,
	Flag = "StrafeTime", 
	Callback = function(Value)
		strafeTime = Value
	end,
})

local wiggleBool = Tab:CreateToggle({
	Name = "Wiggling",
	CurrentValue = wiggling,
	Flag = "Wiggle",
	Callback = function(Value)
		wiggling = not wiggling
	end,
})

--local wiggleAmtDistBased = Tab:CreateToggle({
--	Name = "Wiggle Amount is distance based",
--	CurrentValue = wiggleAmtDistBased,
--	Flag = "WiggleAmtDistBased",
--	Callback = function(Value)
--		wiggleAmtDistBased = not wiggling
--	end,
--})

local wigglingDistance = Tab:CreateSlider({
	Name = "Wiggle Distance",
	Range = {0,100},
	Increment = 1,
	Suffix = "",
	CurrentValue = wiggleDistance,
	Flag = "WiggleDistance",
	Callback = function(Value)
		wiggleDistance = Value
	end
})

local wigglingSpeed = Tab:CreateSlider({
	Name = "Wiggle Speed",
	Range = {0,100},
	Increment = 1,
	Suffix = "",
	CurrentValue = wiggleSpeed,
	Flag = "WiggleSpeed",
	Callback = function(Value)
		wiggleSpeed = Value
	end
})

local wiggleAmt = Tab:CreateSlider({
	Name = "Wiggle Amount",
	Range = {0, 100},
	Increment = 1,
	Suffix = "",
	CurrentValue = wiggleAmount,
	Flag = "WiggleAmount", 
	Callback = function(Value)
		wiggleAmount = Value
	end
})

local turnStrafeOffset = 1

local turnStrafe = Tab:CreateSlider({
	Name = "Turn Strafe",
	Range = {0, 10},
	Increment = 1,
	Suffix = "StrafeTurnAmount",
	CurrentValue = turnStrafeOffset,
	Flag = "Turning Strafe Amount", 
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
	CurrentValue = aimOffset,
	Flag = "Aim Offset", 
	Callback = function(Value)
		aimOffset = Value
	end,
})

local lungeDistance = 20

local lungeDistanceSlider = Tab:CreateSlider({
	Name = "Distance",
	Range = {0, 100},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = lungeDistance,
	Flag = "Lunge Distance", 
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

	if bestPos then
		local flatDir = (bestPos - swordTipPos).Unit * Vector3.new(1, 0, 1)
		--bodyGyro.CFrame = CFrame.new(root.Position, root.Position + flatDir) * CFrame.Angles(0,math.rad(offset or 0),0)
		return CFrame.new(root.Position, root.Position + flatDir) * CFrame.Angles(0,math.rad(offset or 0),0)
	else
		local fallbackDir = (part.Position - swordTipPos).Unit * Vector3.new(1, 0, 1)
		--bodyGyro.CFrame = CFrame.new(root.Position, root.Position + fallbackDir) * CFrame.Angles(0,math.rad(offset or 0),0)
		return CFrame.new(root.Position, root.Position + fallbackDir) * CFrame.Angles(0,math.rad(offset or 0),0)
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
			local dir = ((r.CFrame * CFrame.new(aimOffset,0,0).Position) - root.Position).Unit * Vector3.new(1,0,1)
			local dist = (r.Position - root.Position).Magnitude
			local tool

			if autoEquip then
				local backpack = player:FindFirstChildOfClass("Backpack")
				if backpack and not char:FindFirstChildOfClass("Tool") then
					for _, t in ipairs(backpack:GetChildren()) do
						if t:IsA("Tool") and string.lower(t.Name):find(string.lower(toolName)) then
							delay(0.8, function()
								if t.Parent == backpack then
									humanoid:EquipTool(t)
								end
							end)
							break
						end
					end
				end
			end

			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("Tool") and toolName and string.lower(v.Name):find(string.lower(toolName)) then
					tool = v
					break
				end
			end

			tool = tool or char:FindFirstChildOfClass("Tool")

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
							humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + -(r.CFrame.RightVector * 2 + r.CFrame.LookVector * 2) + (strafeVect3/25))
						end
					else
						if tick() - lastStrafe > strafeTime then
							lastStrafe = tick()
							humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + -(r.CFrame.RightVector * 2 + r.CFrame.LookVector * 2) + (strafeVect3/10))
						end
					end
				else
					if tick() - lastStrafe > strafeTime then
						lastStrafe = tick()
						humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + -(r.CFrame.RightVector * 2 + r.CFrame.LookVector * 2) + (strafeVect3/100))
					end
				end
				if not aimUsesOffset then
					random1N = 80000
					bodyGyro.CFrame = bestCFrame
					if bestCFrame then
						if wiggling then
							if dist <= wiggleDistance then
								random1N = 80000
								bodyGyro.CFrame = bestCFrame * CFrame.Angles(0,math.rad(math.sin(tick() * wiggleSpeed) * wiggleAmount),0)
							else
								random1N = 80000
								bodyGyro.CFrame = bestCFrame
							end
						else
							random1N = 80000
							bodyGyro.CFrame = bestCFrame
						end							
					else
						random1N = 80000
						bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
						if wiggling then
							if dist <= wiggleDistance then
								random1N = 80000
								bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(math.sin(tick() * wiggleSpeed) * wiggleAmount),0)
							else
								random1N = 80000
								bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
							end
						else
							random1N = 80000
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
						end
					end
				else
					random1N = 80000
					bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(offset or 0),0)
					if wiggling then
						random1N = 80000
						if dist <= wiggleDistance then
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(offset or 0),0) * CFrame.Angles(0,math.rad(math.sin(tick() * wiggleSpeed) * wiggleAmount),0)
						else
							random1N = 80000
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
						end
					else
						random1N = 80000
						bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(offset or 0),0)
					end
				end
			else
				if math.random(1,2) == 1 then
					if tick() - timer1 > 0.5 then
						timer1 = tick()
						humanoid:MoveTo(root.Position + root.CFrame.LookVector * -5 + strafeVect3)
						if not aimUsesOffset then
							if bestCFrame then
								random1N = 5000000
								bodyGyro.CFrame = bestCFrame
							else
								random1N = 5000000
								bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir)
							end
						else
							random1N = 5000000
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(offset or 0),0)
						end
					end
				else
					if tick() - timer1 > 0.5 then
						timer1 = tick()
						humanoid:MoveTo(root.Position + root.CFrame.LookVector * -5 + (strafeVect3/10))
						if not aimUsesOffset then
							if c360 then
								random1N = 80000
								bodyGyro.CFrame = c360
							else
								random1N = 80000
								bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(360),0)
							end
						else
							random1N = 80000
							bodyGyro.CFrame = CFrame.new(root.Position, root.Position + dir) * CFrame.Angles(0,math.rad(360),0)
						end
					end
				end
			end

			if target:FindFirstChildOfClass("ForceField") or humanoid.Health / humanoid.MaxHealth < 0.68 or h.Health == math.huge then
				if dist < 25 then
					if target:FindFirstChildOfClass("ForceField") then
						humanoid:MoveTo(r.Position - (r.Position - root.Position).Unit * 25)
					else
						if math.random(1,25) then
							if tick() - lowHealthLunge > 0.7 then
								lowHealthLunge = tick()
								humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + -(r.CFrame.RightVector * 2 + r.CFrame.LookVector * 2))
							end
						end
					end
				end
			end
			
			if math.random(1,45) == 1 or r.Position.Y - 0.5 > root.Position.Y or (math.random(1,15) == 1 and dist <= 10 + -(r.Velocity.Magnitude / 3)) then
				humanoid.Jump = true
			end

			if (dist <= 15.5 and r.Position.Y - 0.5 > root.Position.Y) and r.Velocity.Magnitude > 0.1 then
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
						humanoid:MoveTo((r.Position - (r.Position - root.Position).Unit * 3) + r.Velocity * 0.25 + -(r.CFrame.RightVector * 2 + r.CFrame.LookVector * 2) + (strafeVect3/25))
						if tool then
							tool:Activate()
						end
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
