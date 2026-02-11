local UI = {}

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

function UI:Init(ESP, Misc)
	self.ESP = ESP
	self.Misc = Misc
	Library.ShowToggleFrameInKeybinds = true
	
	local Window = Library:CreateWindow({
		Title = "m1x",
		Footer = "v1.0 | Visuals & Misc",
		Icon = 95816097006870,
		NotifySide = "Right",
		ShowCustomCursor = true,
		ToggleKeybind = Enum.KeyCode.F1,
	})
	
	Library.ToggleKeybind = Enum.KeyCode.F1
	
	local Tabs = {
		Visuals = Window:AddTab("Visuals", "eye"),
		Misc = Window:AddTab("Misc", "wrench"),
		Settings = Window:AddTab("Settings", "settings"),
	}
	
	self:SetupESPTab(Tabs.Visuals)
	self:SetupMiscTab(Tabs.Misc)
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
		self.ESP:SetEnabled(Value)
	end)
	
	ESPGroup:AddToggle("TeamCheck", {
		Text = "Team Check",
		Default = false,
		Tooltip = "Hide ESP for teammates",
	}):OnChanged(function(Value)
		self.ESP:SetTeamCheck(Value)
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

function UI:SetupMiscTab(Tab)
	local LightingGroup = Tab:AddLeftGroupbox("Lighting", "sun")
	
	LightingGroup:AddToggle("FullBright", {
		Text = "Full Bright",
		Default = false,
		Tooltip = "Sets time to 12:00 PM (Morning/Noon)",
	}):OnChanged(function(Value)
		self.Misc:SetFullBright(Value)
	end)
end

function UI:SetupSettingsTab(Tab)
	local MenuGroup = Tab:AddLeftGroupbox("Menu", "settings")
	
	MenuGroup:AddLabel("Menu Key: F1", true)
	
	MenuGroup:AddButton({
		Text = "Unload",
		Func = function()
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
