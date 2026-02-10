local success, result = pcall(function()
	return loadstring(readfile("m1x/main.lua"))()
end)

if not success then
	warn("[M1X] Load failed: " .. tostring(result))
end
