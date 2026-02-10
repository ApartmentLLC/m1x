local Utils = {}

local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera

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

function Utils:GetPlayerPosition(player)
	if not player.Character then return nil end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	return root.Position
end

function Utils:RandomString(length)
	length = length or 10
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local result = ""
	for i = 1, length do
		local randomIndex = math.random(1, #chars)
		result = result .. chars:sub(randomIndex, randomIndex)
	end
	return result
end

return Utils
