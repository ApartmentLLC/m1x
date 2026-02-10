local UI = {}

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

function UI:Init(ESP, TriggerBot)
	self.ESP = ESP
	self.TriggerBot = TriggerBot
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
		Settings = Window:AddTab("Settings", "settings"),
	}
	
	self:SetupESPTab(Tabs.ESP)
	self:SetupTriggerBotTab(Tabs.TriggerBot)
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
		Content = "Press F1 to toggle menu",
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
		self.ESP:SetEnabled(Value)
	end)
	
	ESPGroup:AddToggle("TeamCheck", {
		Text = "Team Check",
		Default = false,
		Tooltip = "Hide ESP for teammates",
	}):OnChanged(function(Value)
		self.ESP:SetTeamCheck(Value)
	end)
	
	ESPGroup:AddSlider("MaxDistance", {
		Text = "Max Distance",
		Default = 1000,
		Min = 100,
		Max = 5000,
		Rounding = 0,
		Suffix = " studs",
	}):OnChanged(function(Value)
		self.ESP:SetMaxDistance(Value)
	end)
	
	ESPGroup:AddSlider("UpdateRate", {
		Text = "Update Rate",
		Default = 30,
		Min = 10,
		Max = 60,
		Rounding = 0,
		Suffix = " Hz",
	}):OnChanged(function(Value)
		self.ESP:SetUpdateInterval(1 / Value)
	end)
	
	local VisualsGroup = Tab:AddRightGroupbox("Visuals", "palette")
	
	VisualsGroup:AddLabel("Hidden Players: Red", true)
	VisualsGroup:AddLabel("Visible Players: Green", true)
	VisualsGroup:AddLabel("Raycast detection", true)
	
	VisualsGroup:AddButton({
		Text = "Force Update",
		Func = function()
			self.ESP:UpdateAll()
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
		self.TriggerBot:SetEnabled(Value)
	end)
	
	TriggerGroup:AddToggle("TriggerTeamCheck", {
		Text = "Team Check",
		Default = true,
		Tooltip = "Ignore teammates",
	}):OnChanged(function(Value)
		self.TriggerBot:SetTeamCheck(Value)
	end)
	
	TriggerGroup:AddToggle("TriggerHeadOnly", {
		Text = "Head Only",
		Default = true,
		Tooltip = "Only trigger on head hits",
	}):OnChanged(function(Value)
		self.TriggerBot:SetHeadOnly(Value)
	end)
	
	TriggerGroup:AddSlider("TriggerDelay", {
		Text = "Delay",
		Default = 0,
		Min = 0,
		Max = 500,
		Rounding = 0,
		Suffix = " ms",
	}):OnChanged(function(Value)
		self.TriggerBot:SetDelay(Value / 1000)
	end)
	
	TriggerGroup:AddSlider("TriggerCooldown", {
		Text = "Cooldown",
		Default = 100,
		Min = 50,
		Max = 1000,
		Rounding = 0,
		Suffix = " ms",
	}):OnChanged(function(Value)
		self.TriggerBot:SetCooldown(Value / 1000)
	end)
	
	local InfoGroup = Tab:AddRightGroupbox("Info", "info")
	
	InfoGroup:AddLabel("Auto shoots when mouse", true)
	InfoGroup:AddLabel("is directly over enemy", true)
	InfoGroup:AddLabel("Uses Raycast + Mouse.Target", true)
end

function UI:SetupSettingsTab(Tab)
	local MenuGroup = Tab:AddLeftGroupbox("Menu", "settings")
	
	MenuGroup:AddLabel("Menu Key: F1", true)
	
	MenuGroup:AddButton({
		Text = "Unload",
		Func = function()
			self.TriggerBot:Destroy()
			self.ESP:Destroy()
			Library:Unload()
		end,
		DoubleClick = true,
	})
	
	MenuGroup:AddButton({
		Text = "Rejoin",
		Func = function()
			game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
		end,
	})
end

return UI
