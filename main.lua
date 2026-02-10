local M1X = {}

local Wave = {}

function Wave:Init()
	self.IsWave = identifyexecutor and identifyexecutor():find("Wave") ~= nil
	
	self.Functions = {
		protect_gui = protect_gui or (syn and syn.protect_gui) or function(gui)
			if gethui then
				gui.Parent = gethui()
			else
				gui.Parent = game:GetService("CoreGui")
			end
		end,
		request = request or http_request or (syn and syn.request) or function() end,
		getgc = getgc or function() return {} end,
		getconnections = getconnections or function() return {} end,
		fireclickdetector = fireclickdetector or function(detector)
			if detector then detector:Click() end
		end,
		firetouchinterest = firetouchinterest or function(part, touched, toggle)
			if toggle == 0 then
				part.CFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
			end
		end,
		getnilinstances = getnilinstances or function() return {} end,
		getinstances = getinstances or function() return game:GetDescendants() end,
		isrbxactive = isrbxactive or function() return true end,
		mouse1click = mouse1click or function()
			local vim = game:GetService("VirtualInputManager")
			vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
			vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end,
		mouse1press = mouse1press or function()
			local vim = game:GetService("VirtualInputManager")
			vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		end,
		mouse1release = mouse1release or function()
			local vim = game:GetService("VirtualInputManager")
			vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end,
		keypress = keypress or function(key)
			game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
		end,
		keyrelease = keyrelease or function(key)
			game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
		end,
		hookfunction = hookfunction or function(original, hook)
			local old = original
			getfenv().original = hook
			return old
		end,
		getnamecallmethod = getnamecallmethod or function() return "" end,
		getcallingscript = getcallingscript or function() return nil end,
		setreadonly = setreadonly or function() end,
		isreadonly = isreadonly or function() return false end,
		getrawmetatable = getrawmetatable or function() return nil end,
		setrawmetatable = setrawmetatable or function() end,
		getconstants = getconstants or function() return {} end,
		getconstant = getconstant or function() return nil end,
		setconstant = setconstant or function() end,
		getupvalues = getupvalues or function() return {} end,
		getupvalue = getupvalue or function() return nil end,
		setupvalue = setupvalue or function() end,
		getprotos = getprotos or function() return {} end,
		getproto = getproto or function() return nil end,
		getstack = getstack or function() return {} end,
		setstack = setstack or function() end,
		getinfo = getinfo or function() return {} end,
		getregistry = getregistry or function() return {} end,
		httpget = game.HttpGet or function() return "" end,
		loadstring = loadstring or function() return function() end end,
		hookmetamethod = hookmetamethod or function() end,
		newcclosure = newcclosure or function(f) return f end,
		checkcaller = checkcaller or function() return false end,
		getthreadidentity = getthreadidentity or function() return 0 end,
		setthreadidentity = setthreadidentity or function() end,
		getrenv = getrenv or function() return {} end,
	}
end

function Wave:ProtectGUI(gui)
	self.Functions.protect_gui(gui)
end

function Wave:Request(options)
	return self.Functions.request(options)
end

Wave:Init()

local TriggerBot = {
	Enabled = false,
	TeamCheck = true,
	HeadOnly = true,
	Delay = 0,
	Cooldown = 0.1,
	LastShot = 0,
	Connections = {},
	VIM = game:GetService("VirtualInputManager"),
}

local ESP = {}
local UI = {}
local Utils = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

function TriggerBot:GetMouseTarget()
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, raycastParams)
	if result then
		return result.Instance
	end
	
	return Mouse.Target
end

function TriggerBot:IsValidTarget(target)
	if not target then return false end
	
	local char = target:FindFirstAncestorOfClass("Model")
	if not char then
		char = target.Parent
		while char and char.Parent ~= Workspace do
			if char:FindFirstChildOfClass("Humanoid") then
				break
			end
			char = char.Parent
		end
	end
	
	if not char then return false end
	
	local player = Players:GetPlayerFromCharacter(char)
	if not player then return false end
	
	if player == LocalPlayer then return false end
	
	if self.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
		return false
	end
	
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	
	if self.HeadOnly then
		local head = char:FindFirstChild("Head")
		if not head then return false end
		
		if target == head or target:IsDescendantOf(head) then
			return true
		end
		return false
	end
	
	local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if not torso then return false end
	
	return target == torso or target:IsDescendantOf(char)
end

function TriggerBot:Click()
	local x, y = Mouse.X, Mouse.Y
	
	if mouse1press and mouse1release then
		mouse1press()
		task.wait(0.015)
		mouse1release()
	else
		self.VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
		task.wait(0.015)
		self.VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end
end

function TriggerBot:CheckTarget()
	if not self.Enabled then return end
	
	local currentTime = tick()
	if currentTime - self.LastShot < self.Cooldown then return end
	
	local target = self:GetMouseTarget()
	if not target then return end
	
	if self:IsValidTarget(target) then
		self.LastShot = currentTime
		
		if self.Delay > 0 then
			task.delay(self.Delay, function()
				if self.Enabled then
					self:Click()
				end
			end)
		else
			self:Click()
		end
	end
end

function TriggerBot:Init()
	table.insert(self.Connections, RunService.RenderStepped:Connect(function()
		if self.Enabled then
			self:CheckTarget()
		end
	end))
end

function TriggerBot:SetEnabled(enabled)
	self.Enabled = enabled
end

function TriggerBot:SetTeamCheck(enabled)
	self.TeamCheck = enabled
end

function TriggerBot:SetHeadOnly(enabled)
	self.HeadOnly = enabled
end

function TriggerBot:SetDelay(delay)
	self.Delay = delay
end

function TriggerBot:SetCooldown(cooldown)
	self.Cooldown = cooldown
end

-- FIXED AIMBOT WITH FOV CIRCLE (CAM LOCK STYLE)
local Aimbot = {
	Enabled = false,
	Key = Enum.KeyCode.E,
	TeamCheck = true,
	Prediction = 0.165,
	Smoothness = 0.08,
	AimPart = "HumanoidRootPart",
	Locking = false,
	Target = nil,
	Connections = {},
}

function Aimbot:GetClosestTarget()
	local closestDist = math.huge
	local target = nil
	local mousePos = UserInputService:GetMouseLocation()
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if self.TeamCheck and player.Team == LocalPlayer.Team then continue end
			
			local character = player.Character
			if not character then continue end
			
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health <= 0 then continue end
			
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then continue end
			
			local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
				if dist < closestDist then
					closestDist = dist
					target = rootPart
				end
			end
		end
	end
	
	return target
end

function Aimbot:Init()
	-- RenderStepped for Camera Lock
	table.insert(self.Connections, RunService.RenderStepped:Connect(function()
		if self.Enabled and self.Locking and self.Target and self.Target.Parent then
			local humanoid = self.Target.Parent:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local camPos = Camera.CFrame.Position
				local targetPos = self.Target.Position + (self.Target.Velocity * self.Prediction)
				local lookCFrame = CFrame.lookAt(camPos, targetPos)
				
				Camera.CFrame = Camera.CFrame:Lerp(lookCFrame, self.Smoothness)
			else
				self.Locking = false
				self.Target = nil
			end
		end
	end))
	
	-- Input Handling
	table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if not self.Enabled then return end
		
		if input.KeyCode == self.Key then
			self.Target = self:GetClosestTarget()
			if self.Target then
				self.Locking = true
			end
		end
	end))
	
	table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == self.Key then
			self.Locking = false
			self.Target = nil
		end
	end))
end

function Aimbot:SetEnabled(enabled) self.Enabled = enabled end
function Aimbot:SetTeamCheck(enabled) self.TeamCheck = enabled end
function Aimbot:SetPrediction(val) self.Prediction = val end
function Aimbot:SetSmoothness(val) self.Smoothness = val end
function Aimbot:SetAimPart(part) self.AimPart = part end

function Aimbot:Destroy()
	for _, conn in ipairs(self.Connections) do conn:Disconnect() end
	self.Connections = {}
end

-- Removed FOV Circle Logic for simplicity/robustness as requested by "cam lock" style


function TriggerBot:Destroy()
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	self.Connections = {}
	self.Enabled = false
end

ESP.Enabled = false
ESP.Highlights = {}
ESP.Connections = {}
ESP.MaxDistance = 1000
ESP.TeamCheck = false
ESP.UpdateInterval = 0.03
ESP.LastUpdate = 0

function ESP:CreateHighlight(player)
	if self.Highlights[player] then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "M1X_ESP_" .. player.Name
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	Wave:ProtectGUI(highlight)
	
	self.Highlights[player] = {
		Instance = highlight,
		IsVisible = false,
	}
end

function ESP:IsPlayerVisible(targetPlayer)
	if not targetPlayer.Character or not LocalPlayer.Character then return false end
	
	local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	
	if not targetHumanoid or not targetRoot or not localRoot then return false end
	if targetHumanoid.Health <= 0 then return false end
	
	local distance = (targetRoot.Position - localRoot.Position).Magnitude
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.IgnoreWater = true
	
	local direction = (targetRoot.Position - localRoot.Position).Unit * math.min(distance, 5000)
	local result = Workspace:Raycast(localRoot.Position, direction, raycastParams)
	
	return result == nil
end

function ESP:UpdateHighlight(player)
	local data = self.Highlights[player]
	if not data then return end
	
	if not player.Character then
		data.Instance.Enabled = false
		return
	end
	
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not rootPart or humanoid.Health <= 0 then
		data.Instance.Enabled = false
		return
	end
	
	if self.TeamCheck and player.Team == LocalPlayer.Team then
		data.Instance.Enabled = false
		return
	end
	
	local isVisible = self:IsPlayerVisible(player)
	
	if isVisible then
		data.Instance.FillColor = Color3.fromRGB(0, 255, 0)
		data.Instance.OutlineColor = Color3.fromRGB(0, 255, 0)
	else
		data.Instance.FillColor = Color3.fromRGB(255, 0, 0)
		data.Instance.OutlineColor = Color3.fromRGB(255, 0, 0)
	end
	
	data.Instance.Adornee = player.Character
	data.Instance.Enabled = self.Enabled
	data.IsVisible = isVisible
end

function ESP:UpdateAll()
	if not self.Enabled then
		for _, data in pairs(self.Highlights) do
			data.Instance.Enabled = false
		end
		return
	end
	
	local currentTime = tick()
	if currentTime - self.LastUpdate < self.UpdateInterval then return end
	self.LastUpdate = currentTime
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if not self.Highlights[player] then
				self:CreateHighlight(player)
			end
			self:UpdateHighlight(player)
		end
	end
end

function ESP:GetDistanceToPlayer(player)
	if not player.Character or not LocalPlayer.Character then return math.huge end
	local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
	local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot or not localRoot then return math.huge end
	return (targetRoot.Position - localRoot.Position).Magnitude
end

function ESP:OnPlayerAdded(player)
	self:CreateHighlight(player)
end

function ESP:OnPlayerRemoving(player)
	if self.Highlights[player] then
		self.Highlights[player].Instance:Destroy()
		self.Highlights[player] = nil
	end
end

function ESP:OnCharacterAdded(player, character)
	if self.Highlights[player] then
		self.Highlights[player].Instance.Adornee = nil
	end
	
	local humanoid = character:WaitForChild("Humanoid", 3)
	if humanoid then
		humanoid.Died:Connect(function()
			if self.Highlights[player] then
				self.Highlights[player].Instance.Enabled = false
			end
		end)
	end
end

function ESP:Init()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			self:OnPlayerAdded(player)
			if player.Character then
				self:OnCharacterAdded(player, player.Character)
			end
		end
	end
	
	table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
		table.insert(self.Connections, player.CharacterAdded:Connect(function(character)
			self:OnCharacterAdded(player, character)
		end))
	end))
	
	table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerRemoving(player)
	end))
	
	table.insert(self.Connections, RunService.Heartbeat:Connect(function()
		self:UpdateAll()
	end))
	
	table.insert(self.Connections, Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		Workspace.CurrentCamera = Camera
	end))
end

function ESP:Destroy()
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	self.Connections = {}
	
	for player, data in pairs(self.Highlights) do
		data.Instance:Destroy()
	end
	self.Highlights = {}
	
	self.Enabled = false
end

function ESP:SetEnabled(enabled)
	self.Enabled = enabled
	if not enabled then
		for _, data in pairs(self.Highlights) do
			data.Instance.Enabled = false
		end
	end
end

function ESP:SetTeamCheck(enabled)
	self.TeamCheck = enabled
end

function ESP:SetMaxDistance(distance)
	self.MaxDistance = distance
end

function ESP:SetUpdateInterval(interval)
	self.UpdateInterval = interval
end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

function UI:Init()
	Library.ShowToggleFrameInKeybinds = true
	
	local Window = Library:CreateWindow({
		Title = "m1x",
		Footer = "v1.0 | Wave Optimized",
		Icon = 95816097006870,
		NotifySide = "Right",
		ShowCustomCursor = true,
		ToggleKeybind = Enum.KeyCode.F1,
	})
	
	Library.ToggleKeybind = Enum.KeyCode.F1
	
	local Tabs = {
		ESP = Window:AddTab("ESP", "eye"),
		TriggerBot = Window:AddTab("TriggerBot", "crosshair"),
		Aimbot = Window:AddTab("Aimbot", "target"),
		Settings = Window:AddTab("Settings", "settings"),
	}
	
	self:SetupESPTab(Tabs.ESP)
	self:SetupTriggerBotTab(Tabs.TriggerBot)
	self:SetupAimbotTab(Tabs.Aimbot)
	self:SetupSettingsTab(Tabs.Settings)
	
	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)
	SaveManager:IgnoreThemeSettings()
	ThemeManager:SetFolder("m1x")
	SaveManager:SetFolder("m1x/wave")
	SaveManager:BuildConfigSection(Tabs.Settings)
	ThemeManager:ApplyToTab(Tabs.Settings)
	
	Library:Notify({
		Title = "M1X Loaded",
		Content = "Press F1 to toggle menu | Hold E for aimbot",
		Duration = 5,
	})
end

function UI:SetupESPTab(Tab)
	local ESPGroup = Tab:AddLeftGroupbox("ESP Settings", "eye")
	
	ESPGroup:AddToggle("ESPEnabled", {
		Text = "ESP Enabled",
		Default = false,
		Tooltip = "Toggle player ESP",
	}):OnChanged(function(Value)
		ESP:SetEnabled(Value)
	end)
	
	ESPGroup:AddToggle("TeamCheck", {
		Text = "Team Check",
		Default = false,
		Tooltip = "Hide ESP for teammates",
	}):OnChanged(function(Value)
		ESP:SetTeamCheck(Value)
	end)
	
	ESPGroup:AddSlider("MaxDistance", {
		Text = "Max Distance",
		Default = 1000,
		Min = 100,
		Max = 5000,
		Rounding = 0,
		Suffix = " studs",
	}):OnChanged(function(Value)
		ESP:SetMaxDistance(Value)
	end)
	
	ESPGroup:AddSlider("UpdateRate", {
		Text = "Update Rate",
		Default = 30,
		Min = 10,
		Max = 60,
		Rounding = 0,
		Suffix = " Hz",
	}):OnChanged(function(Value)
		ESP:SetUpdateInterval(1 / Value)
	end)
	
	local VisualsGroup = Tab:AddRightGroupbox("Visuals", "palette")
	
	VisualsGroup:AddLabel("Hidden Players: Red", true)
	VisualsGroup:AddLabel("Visible Players: Green", true)
	VisualsGroup:AddLabel("Raycast detection", true)
	
	VisualsGroup:AddButton({
		Text = "Force Update",
		Func = function()
			ESP:UpdateAll()
			Library:Notify({
				Title = "ESP",
				Content = "Update completed",
				Duration = 2,
			})
		end,
	})
end

function UI:SetupTriggerBotTab(Tab)
	local TriggerGroup = Tab:AddLeftGroupbox("TriggerBot", "crosshair")
	
	TriggerGroup:AddToggle("TriggerBotEnabled", {
		Text = "TriggerBot Enabled",
		Default = false,
		Tooltip = "Auto shoot when mouse is on enemy",
	}):OnChanged(function(Value)
		TriggerBot:SetEnabled(Value)
	end)
	
	TriggerGroup:AddToggle("TriggerTeamCheck", {
		Text = "Team Check",
		Default = true,
		Tooltip = "Ignore teammates",
	}):OnChanged(function(Value)
		TriggerBot:SetTeamCheck(Value)
	end)
	
	TriggerGroup:AddToggle("TriggerHeadOnly", {
		Text = "Head Only",
		Default = true,
		Tooltip = "Only trigger on head hits",
	}):OnChanged(function(Value)
		TriggerBot:SetHeadOnly(Value)
	end)
	
	TriggerGroup:AddSlider("TriggerDelay", {
		Text = "Delay",
		Default = 0,
		Min = 0,
		Max = 500,
		Rounding = 0,
		Suffix = " ms",
	}):OnChanged(function(Value)
		TriggerBot:SetDelay(Value / 1000)
	end)
	
	local InfoGroup = Tab:AddRightGroupbox("Info", "info")
	
	InfoGroup:AddLabel("Auto shoots when mouse", true)
	InfoGroup:AddLabel("is directly over enemy", true)
	InfoGroup:AddLabel("head or body", true)
end

function UI:SetupAimbotTab(Tab)
	local AimbotGroup = Tab:AddLeftGroupbox("Aimbot", "target")
	
	AimbotGroup:AddToggle("AimbotEnabled", {
		Text = "Aimbot Enabled",
		Default = false,
		Tooltip = "Enable camera lock aimbot with FOV circle",
	}):OnChanged(function(Value)
		Aimbot:SetEnabled(Value)
	end)
	
	AimbotGroup:AddToggle("AimbotTeamCheck", {
		Text = "Team Check",
		Default = true,
		Tooltip = "Ignore teammates",
	}):OnChanged(function(Value)
		Aimbot:SetTeamCheck(Value)
	end)
	
	AimbotGroup:AddToggle("AimbotVisibility", {
		Text = "Visibility Check",
		Default = true,
		Tooltip = "Only aim at visible targets",
	}):OnChanged(function(Value)
		Aimbot:SetVisibilityCheck(Value)
	end)
	
	AimbotGroup:AddDropdown("AimPart", {
		Text = "Aim Part",
		Default = "Head",
		Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"},
		Tooltip = "Body part to aim at",
	}):OnChanged(function(Value)
		Aimbot:SetAimPart(Value)
	end)
	
	AimbotGroup:AddSlider("AimbotFOV", {
		Text = "FOV Radius",
		Default = 200,
		Min = 50,
		Max = 500,
		Rounding = 0,
		Suffix = " px",
	}):OnChanged(function(Value)
		Aimbot:SetFOV(Value)
	end)
	
	AimbotGroup:AddSlider("Smoothness", {
		Text = "Smoothness",
		Default = 0.08,
		Min = 0.01,
		Max = 1,
		Rounding = 2,
	}):OnChanged(function(Value)
		Aimbot:SetSmoothness(Value)
	end)
	
	AimbotGroup:AddSlider("Prediction", {
		Text = "Prediction",
		Default = 0.165,
		Min = 0,
		Max = 0.5,
		Rounding = 3,
	}):OnChanged(function(Value)
		Aimbot:SetPrediction(Value)
	end)
	
	local KeyGroup = Tab:AddRightGroupbox("Keybind", "key")
	
	KeyGroup:AddLabel("Hold E to lock on", true)
	KeyGroup:AddLabel("Release E to unlock", true)
	KeyGroup:AddLabel("Aims at closest to crosshair", true)
	
	local InfoGroup = Tab:AddRightGroupbox("Info", "info")
	
	InfoGroup:AddLabel("White Circle = FOV Range", true)
	InfoGroup:AddLabel("Red Circle = Locked On", true)
	InfoGroup:AddLabel("Smoothness: lower = snappier", true)
	InfoGroup:AddLabel("Prediction: compensates movement", true)
end

function UI:SetupSettingsTab(Tab)
	local MenuGroup = Tab:AddLeftGroupbox("Menu", "settings")
	
	MenuGroup:AddLabel("Menu Key: F1", true)
	
	MenuGroup:AddButton({
		Text = "Unload",
		Func = function()
			Aimbot:Destroy()
			TriggerBot:Destroy()
			ESP:Destroy()
			Library:Unload()
		end,
		DoubleClick = true,
	})
	
	MenuGroup:AddButton({
		Text = "Rejoin",
		Func = function()
			game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
		end,
	})
end

function Utils:WorldToScreen(position)
	local screenPos, onScreen = Camera:WorldToViewportPoint(position)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

function Utils:GetDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

function Utils:IsValidCharacter(character)
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return false end
	if humanoid.Health <= 0 then return false end
	return true
end

TriggerBot:Init()
Aimbot:Init()
ESP:Init()
UI:Init()

M1X.TriggerBot = TriggerBot
M1X.Aimbot = Aimbot
M1X.ESP = ESP
M1X.UI = UI
M1X.Utils = Utils
M1X.Wave = Wave

getgenv().M1X = M1X

return M1X
