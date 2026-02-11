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

local ESP = {}
local Misc = {}
local UI = {}
local Utils = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- Misc Module
Misc.FullBrightConnection = nil

function Misc:SetFullBright(enabled)
	if enabled then
		if not self.FullBrightConnection then
			self.FullBrightConnection = RunService.RenderStepped:Connect(function()
				Lighting.ClockTime = 12
			end)
		end
	else
		if self.FullBrightConnection then
			self.FullBrightConnection:Disconnect()
			self.FullBrightConnection = nil
		end
	end
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
		Footer = "v1.0 | Visuals Only",
		Icon = 95816097006870,
		NotifySide = "Right",
		ShowCustomCursor = true,
		ToggleKeybind = Enum.KeyCode.F1,
	})
	
	Library.ToggleKeybind = Enum.KeyCode.F1
	
	local Tabs = {
		Visuals = Window:AddTab("Visuals", "eye"),
		Settings = Window:AddTab("Settings", "settings"),
	}
	
	self:SetupESPTab(Tabs.Visuals)
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
		Content = "Visuals Only Mode Loaded",
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

function UI:SetupSettingsTab(Tab)
	local MenuGroup = Tab:AddLeftGroupbox("Menu", "settings")
	
	MenuGroup:AddLabel("Menu Key: F1", true)
	
	MenuGroup:AddButton({
		Text = "Unload",
		Func = function()
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

ESP:Init()
UI:Init(ESP, Misc)

M1X.ESP = ESP
M1X.Misc = Misc
M1X.UI = UI
M1X.Utils = Utils
M1X.Wave = Wave

getgenv().M1X = M1X

return M1X
