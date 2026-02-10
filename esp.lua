local ESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

ESP.Enabled = false
ESP.Highlights = {}
ESP.Connections = {}
ESP.MaxDistance = 1000
ESP.TeamCheck = false
ESP.UpdateInterval = 0.03
ESP.LastUpdate = 0

function ESP:ProtectGUI(gui)
	local protect = protect_gui or (syn and syn.protect_gui) or function(g)
		if gethui then
			g.Parent = gethui()
		else
			g.Parent = game:GetService("CoreGui")
		end
	end
	protect(gui)
end

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
	self:ProtectGUI(highlight)
	
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
	if distance > self.MaxDistance then return false end
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.IgnoreWater = true
	
	local direction = (targetRoot.Position - localRoot.Position).Unit * distance
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

return ESP
